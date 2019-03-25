use actix::prelude::Addr;
use actix_web::http::Method;
use actix_web::{
    dev, error, error::ErrorBadRequest, fs::NamedFile, middleware, multipart, App, AsyncResponder,
    FutureResponse, HttpMessage, HttpRequest, HttpResponse, Json, Path, Result, State,
};
use config::Config;
use db::executor::DbExecutor;
use db::publication::{
    self, AddRecent, Delete, DeleteThumbnail, Get, GetProgress, List, ListByCategory,
    ListRecentlyAdded, ListRecentlyRead, Update, UpdateProgress, UpdateThumbnail,
};
use fs::executor::{DeleteFile, FsExecutor};
use fs::thumbnail;
use futures::{future, Future, IntoFuture, Stream};
use mime;
use models::{NewPublication, Publication, PublicationProgress, CBR, CBZ, EPUB};
use reader::{comic, epub};
use state::AppState;
use std::{
    error::Error,
    fmt::{Display, Formatter},
    fs,
    io::Write,
    path::PathBuf,
};

pub const BASE_PATH: &str = "/api/publication";

#[derive(Debug)]
enum PublicationError {
    InvalidMediaFormat,
}

impl Error for PublicationError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        None
    }
}

impl Display for PublicationError {
    fn fmt(&self, f: &mut Formatter) -> std::fmt::Result {
        write!(f, "{:?}", self)
    }
}

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(List {})
        .from_err()
        .and_then(|res| res)
        .and_then(|publications| Ok(HttpResponse::Ok().json(publications)))
        .responder()
}

fn create(state: State<AppState>, json: Json<NewPublication>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(publication::Create(json.into_inner()))
        .from_err()
        .and_then(|res| res)
        .and_then(|_| Ok(HttpResponse::Ok().json(())))
        .responder()
}

fn update(state: State<AppState>, json: Json<Publication>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Update {
            publication: json.into_inner(),
        })
        .from_err()
        .and_then(|res| res)
        .and_then(|_| Ok(HttpResponse::Ok().json(())))
        .responder()
}

fn update_progress(
    state: State<AppState>,
    json: Json<PublicationProgress>,
) -> FutureResponse<HttpResponse> {
    let json = json.into_inner();
    state
        .db
        .send(UpdateProgress {
            publication_id: json.publication_id,
            progress: json.progress,
        })
        .from_err()
        .and_then(|res| res)
        .and_then(|_| Ok(HttpResponse::Ok().json(())))
        .responder()
}

fn get_progress(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(GetProgress {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| res)
        .and_then(|progress| Ok(HttpResponse::Ok().json(progress)))
        .responder()
}

fn delete(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Delete {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_err) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn get(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| res)
        .map(|publication| HttpResponse::Ok().json(publication))
        .responder()
}

fn read(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    let config = state.config.clone();
    let publication_id = publication_id.into_inner();
    let db = &state.db;
    db.send(Get {
        publication_id: publication_id,
    })
    .join(db.send(AddRecent(publication_id)))
    .from_err()
    .and_then(|res| res)
    .and_then(
        move |(publication, _)| match publication.media_format.as_ref() {
            CBR => read_cbr(&config, &publication),
            CBZ => read_cbz(&config, &publication),
            EPUB => read_epub(&publication),
            _ => Ok(HttpResponse::InternalServerError().into()),
        },
    )
    .responder()
}

fn read_cbz(config: &Config, publication: &Publication) -> Result<HttpResponse, actix_web::Error> {
    comic::open(config, &publication)
        .map_err(|err| err.into())
        .and_then(|data| Ok(HttpResponse::Ok().json(data)))
}

fn read_cbr(config: &Config, publication: &Publication) -> Result<HttpResponse, actix_web::Error> {
    comic::open(config, &publication)
        .map_err(|err| err.into())
        .and_then(|data| Ok(HttpResponse::Ok().json(data)))
}

fn read_epub(publication: &Publication) -> Result<HttpResponse, actix_web::Error> {
    epub::open(&publication)
        .map_err(|err| err.into())
        .and_then(|data| Ok(HttpResponse::Ok().json(data)))
}

fn read_page(state: State<AppState>, params: Path<(i32, usize)>) -> FutureResponse<NamedFile> {
    let publication_id = params.0;
    let config = state.config.clone();
    let db = &state.db;

    db.send(Get {
        publication_id: publication_id,
    })
    .from_err()
    .and_then(|res| res)
    .and_then(move |publication| match publication.media_format.as_ref() {
        CBR => read_page_comic(&config, &publication, params.1),
        CBZ => read_page_comic(&config, &publication, params.1),
        _ => Err(ErrorBadRequest(PublicationError::InvalidMediaFormat)),
    })
    .map_err(|err| {
        println!("Error: {:?}", err);
        err
    })
    .responder()
}

fn read_page_comic(
    config: &Config,
    publication: &Publication,
    page_num: usize,
) -> Result<NamedFile, actix_web::Error> {
    let filename = comic::page(config, &publication, page_num).expect("Unable to read page");
    let file = NamedFile::open(filename);
    file.map_err(|err| {
        println!("File Error: {:?}", err);
        err.into()
    })
}

fn list_by_category(
    state: State<AppState>,
    category_id: Path<i32>,
) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(ListByCategory {
            category_id: category_id.into_inner(),
        })
        .from_err()
        .and_then(|res| res)
        .and_then(|publications| Ok(HttpResponse::Ok().json(publications)))
        .responder()
}

fn list_recently_added(
    state: State<AppState>,
    path: Path<(i32, i64)>,
) -> FutureResponse<HttpResponse> {
    let (category_id, count) = path.into_inner();
    state
        .db
        .send(ListRecentlyAdded { category_id, count })
        .from_err()
        .and_then(|res| res)
        .and_then(|publications| Ok(HttpResponse::Ok().json(publications)))
        .responder()
}

fn list_recently_read(state: State<AppState>, count: Path<i64>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(ListRecentlyRead {
            count: count.into_inner(),
        })
        .from_err()
        .and_then(|res| res)
        .and_then(|publications| Ok(HttpResponse::Ok().json(publications)))
        .responder()
}

fn generate_thumbnail(
    state: State<AppState>,
    publication_id: Path<i32>,
) -> FutureResponse<NamedFile> {
    let publication_id = publication_id.into_inner();
    state
        .db
        .send(Get { publication_id })
        .from_err()
        .and_then(|res| res)
        .and_then(move |publication| match publication.thumbnail {
            Some(thumbnail) => NamedFile::open(thumbnail).map_err(|err| err.into()),
            None => Err(actix_web::error::ErrorInternalServerError(
                "This publication doesn't have thumbnail",
            )),
        })
        .responder()
}

fn download(req: &HttpRequest<AppState>) -> FutureResponse<NamedFile> {
    let publication_id: i32 = req.match_info().query("publication_id").unwrap();
    let file: PathBuf = req.match_info().query("tail").unwrap();
    let state: &AppState = req.state();
    let config = state.config.clone();
    req.state()
        .db
        .send(Get { publication_id })
        .from_err()
        .and_then(|res| res)
        .and_then(move |publication| download_file(&config, &publication, file))
        .responder()
}

fn download_file(
    config: &Config,
    the_publication: &Publication,
    path: PathBuf,
) -> Result<NamedFile> {
    if the_publication.media_format == EPUB {
        return epub::file(config, the_publication, path).map_err(|err| err.into());
    }

    Err(ErrorBadRequest(PublicationError::InvalidMediaFormat))
}

fn generate_thumbnail_url(publication_id: i32) -> String {
    format!("{}/thumbnail/{}", BASE_PATH, publication_id.to_string())
}

fn save_file(
    home_path: String,
    publication_id: i32,
    field: multipart::Field<dev::Payload>,
) -> Box<Future<Item = String, Error = error::Error>> {
    let thumbnail_location = thumbnail::generate_thumbnail_location(&home_path, publication_id);
    let file_name: &str;
    {
        let content_type = field.content_type();
        file_name = match (content_type.type_(), content_type.subtype()) {
            (mime::IMAGE, mime::PNG) => "thumbnail.png",
            (mime::IMAGE, mime::BMP) => "thumbnail.bmp",
            (mime::IMAGE, mime::JPEG) => "thumbnail.jpg",
            (mime::IMAGE, mime::GIF) => "thumbnail.gif",
            _ => {
                return Box::new(future::err(actix_web::error::ErrorInternalServerError(
                    format!("Unsupported mime type: {:?}", content_type),
                )));
            }
        };
    }

    match fs::create_dir_all(thumbnail_location) {
        Err(e) => return Box::new(future::err(actix_web::error::ErrorInternalServerError(e))),
        Ok(_) => {}
    }

    let mut file_path = thumbnail::generate_thumbnail_location(&home_path, publication_id);
    file_path.push(file_name);

    let mut file = match fs::File::create(file_path.clone()) {
        Ok(file) => file,
        Err(e) => return Box::new(future::err(actix_web::error::ErrorInternalServerError(e))),
    };

    Box::new(
        field
            .fold(0i64, move |acc, bytes| {
                let rt = file
                    .write_all(bytes.as_ref())
                    .map(|_| acc + bytes.len() as i64)
                    .map_err(|e| error::MultipartError::Payload(error::PayloadError::Io(e)));
                future::result(rt)
            })
            .map(move |_| file_path.to_str().unwrap_or("").to_string())
            .map_err(|e| error::ErrorInternalServerError(e)),
    )
}

fn update_publication_thumbnail(
    db: Addr<DbExecutor>,
    publication_id: i32,
    file_path: String,
) -> Box<Future<Item = String, Error = error::Error>> {
    Box::new(
        db.send(UpdateThumbnail {
            publication_id: publication_id,
            thumbnail: file_path,
        })
        .from_err()
        .and_then(|res| res)
        .and_then(move |_| future::result(Ok(generate_thumbnail_url(publication_id)))),
    )
}

fn handle_multipart_item(
    home_path: String,
    publication_id: i32,
    item: multipart::MultipartItem<dev::Payload>,
) -> Box<Stream<Item = String, Error = error::Error>> {
    match item {
        multipart::MultipartItem::Field(field) => {
            Box::new(save_file(home_path, publication_id, field).into_stream())
        }
        multipart::MultipartItem::Nested(mp) => Box::new(
            mp.map_err(error::ErrorInternalServerError)
                .map(move |item| handle_multipart_item(home_path.clone(), publication_id, item))
                .flatten(),
        ),
    }
}

fn upload(req: HttpRequest<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    let state = req.state();
    let config = state.config.clone();
    let db = state.db.clone();
    let publication_id: i32 = publication_id.into_inner();
    Box::new(
        req.multipart()
            .map_err(error::ErrorInternalServerError)
            .map(move |item| {
                handle_multipart_item(config.pustaka_home.clone(), publication_id, item)
            })
            .flatten()
            .collect()
            .and_then(move |file_path| match file_path.last() {
                Some(file_path) => {
                    update_publication_thumbnail(db, publication_id, file_path.to_string())
                }
                None => Box::new(future::err(error::ErrorInternalServerError(
                    "No file found",
                ))),
            })
            .map(|image_url| HttpResponse::Ok().json(image_url))
            .map_err(|e| {
                println!("failed: {}", e);
                e
            }),
    )
}

fn delete_thumbnail(
    req: HttpRequest<AppState>,
    publication_id: Path<i32>,
) -> FutureResponse<HttpResponse> {
    let state = req.state();
    let db = state.db.clone();
    let fs = state.fs.clone();
    let publication_id = publication_id.into_inner();
    let delete_thumbnail_from_db: Box<Future<Item = Option<String>, Error = actix_web::Error>> =
        Box::new(
            db.send(DeleteThumbnail {
                publication_id: publication_id,
            })
            .into_future()
            .map_err(actix_web::error::ErrorInternalServerError)
            .and_then(|res| res.into_future()),
        );

    delete_thumbnail_from_db
        .and_then(|res| delete_thumbnail_file(fs, res))
        .map_err(actix_web::error::ErrorInternalServerError)
        .and_then(|res| Ok(HttpResponse::Ok().json(res).into()))
        .responder()
}

fn delete_thumbnail_file(
    fs: Addr<FsExecutor>,
    option: Option<String>,
) -> Box<Future<Item = (), Error = actix_web::Error>> {
    match option {
        Some(thumbnail_path) => Box::new(
            fs.send(DeleteFile {
                path: thumbnail_path,
            })
            .into_future()
            .from_err()
            .and_then(|res| {
                res.map_err(actix_web::error::ErrorInternalServerError)
                    .into_future()
            }),
        ),
        None => Box::new(future::ok(())),
    }
}

pub fn create_app(state: AppState, prefix: &str) -> App<AppState> {
    App::with_state(state)
        .middleware(middleware::Logger::default())
        .prefix(prefix)
        .route("/{publication_id}", Method::GET, get)
        .route("/", Method::GET, list)
        .route("/", Method::POST, create)
        .route("/", Method::PUT, update)
        .route("/{publication_id}", Method::DELETE, delete)
        .route("/{publication_id}", Method::GET, get)
        .route("/category/{category_id}", Method::GET, list_by_category)
        .route(
            "/recently_added/category_id/{category_id}/count/{count}",
            Method::GET,
            list_recently_added,
        )
        .route(
            "/recently_read/count/{count}",
            Method::GET,
            list_recently_read,
        )
        .route(
            "/thumbnail/{publication_id}",
            Method::GET,
            generate_thumbnail,
        )
        .route("/read/{publication_id}", Method::GET, read)
        .route(
            "/read/{publication_id}/page/{page_number}",
            Method::GET,
            read_page,
        )
        .route("/thumbnail/{publication_id}", Method::POST, upload)
        .route(
            "/thumbnail/{publication_id}",
            Method::DELETE,
            delete_thumbnail,
        )
        .route("/progress/", Method::PUT, update_progress)
        .route("/progress/{publication_id}", Method::GET, get_progress)
        .resource("/download/{publication_id}/{tail:.*}", |r| r.f(download))
}
