use actix::prelude::Addr;
use actix_web::http::Method;
use actix_web::{
    dev, error, error::ErrorBadRequest, fs::NamedFile, middleware, multipart, App, AsyncResponder,
    FutureResponse, HttpMessage, HttpRequest, HttpResponse, Json, Path, Result, State,
};
use config::Config;
use db::executor::DbExecutor;
use db::publication::{
    self, Delete, DeleteThumbnail, Get, List, ListByCategory, Update, UpdateThumbnail,
};
use futures::{future, stream, Future, Stream};
use mime;
use models::{NewPublication, Publication, CBR, CBZ, EPUB};
use reader::{comic, epub};
use state::AppState;
use std::{
    error::Error,
    fmt::{Display, Formatter},
    fs, io,
    io::Write,
    path::PathBuf,
};

pub const BASE_PATH: &str = "/api/publication";
const THUMBNAIL_LOCATION: &str = "thumbnail";

#[derive(Debug)]
enum PublicationError {
    InvalidMediaFormat,
    IoError(io::Error),
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
        .and_then(|res| match res {
            Ok(publications) => Ok(HttpResponse::Ok().json(publications)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn create(state: State<AppState>, json: Json<NewPublication>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(publication::Create(json.into_inner()))
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn update(state: State<AppState>, json: Json<Publication>) -> FutureResponse<HttpResponse> {
    println!("{:?}", json);
    state
        .db
        .send(Update {
            publication: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
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
        .and_then(|res| match res {
            Ok(publication) => Ok(HttpResponse::Ok().json(publication)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn read(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(ref publication) => match publication.media_format.as_ref() {
                CBR => read_comic(&publication),
                CBZ => read_cbz(&publication),
                EPUB => read_epub(&publication),
                _ => Ok(HttpResponse::InternalServerError().into()),
            },
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn read_cbz(publication: &Publication) -> Result<HttpResponse, actix_web::Error> {
    comic::open(&publication)
        .map_err(|err| err.into())
        .and_then(|data| Ok(HttpResponse::Ok().json(data)))
}

fn read_comic(publication: &Publication) -> Result<HttpResponse, actix_web::Error> {
    comic::open(&publication)
        .map_err(|err| err.into())
        .and_then(|data| Ok(HttpResponse::Ok().json(data)))
}

fn read_epub(publication: &Publication) -> Result<HttpResponse, actix_web::Error> {
    epub::open(&publication)
        .map_err(|err| err.into())
        .and_then(|data| Ok(HttpResponse::Ok().json(data)))
}

fn read_page(state: State<AppState>, params: Path<(i32, usize)>) -> FutureResponse<NamedFile> {
    let config = state.config.clone();
    state
        .db
        .send(Get {
            publication_id: params.0,
        })
        .from_err()
        .and_then(move |res| {
            res.and_then(|publication| match publication.media_format.as_ref() {
                CBR => read_page_comic(&config, &publication, params.1),
                CBZ => read_page_comic(&config, &publication, params.1),
                _ => Err(ErrorBadRequest(PublicationError::InvalidMediaFormat)),
            })
        })
        .responder()
}

fn read_page_comic(
    config: &Config,
    publication: &Publication,
    page_num: usize,
) -> Result<NamedFile, actix_web::Error> {
    let filename = comic::page(config, &publication, page_num).expect("Unable to read page");
    println!("{:?}", filename);
    let file = NamedFile::open(filename);
    file.map_err(|err| err.into())
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
        .and_then(|res| match res {
            Ok(publications) => Ok(HttpResponse::Ok().json(publications)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn generate_thumbnail(
    state: State<AppState>,
    publication_id: Path<i32>,
) -> FutureResponse<NamedFile> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| {
            res.and_then(|publication| match publication.thumbnail {
                Some(thumbnail) => NamedFile::open(thumbnail).map_err(|err| err.into()),
                None => Err(io::Error::new(
                    io::ErrorKind::InvalidInput,
                    "Publication doesn't have thumbnail",
                )
                .into()),
            })
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
        .send(Get {
            publication_id: publication_id,
        })
        .from_err()
        .and_then(move |res| res.and_then(|publication| download_file(&config, &publication, file)))
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

fn generate_thumbnail_location(home_path: &str, publication_id: i32) -> PathBuf {
    let mut thumbnail_location = PathBuf::from(home_path.clone());
    thumbnail_location.push(THUMBNAIL_LOCATION);
    thumbnail_location.push(publication_id.to_string());

    thumbnail_location
}

fn generate_thumbnail_url(publication_id: i32) -> String {
    format!("{}/thumbnail/{}", BASE_PATH, publication_id.to_string())
}

fn save_file(
    home_path: String,
    publication_id: i32,
    field: multipart::Field<dev::Payload>,
) -> Box<Future<Item = String, Error = error::Error>> {
    let thumbnail_location = generate_thumbnail_location(&home_path, publication_id);
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
                )))
            }
        };
    }

    match fs::create_dir_all(thumbnail_location) {
        Err(e) => return Box::new(future::err(actix_web::error::ErrorInternalServerError(e))),
        Ok(_) => {}
    }

    let mut file_path = generate_thumbnail_location(&home_path, publication_id);
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
        .and_then(move |res| match res {
            Ok(_) => future::result(Ok(generate_thumbnail_url(publication_id))),
            Err(err) => future::err(actix_web::error::ErrorInternalServerError(err)),
        }),
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
    println!("{:?}", req);
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
    state
        .db
        .send(DeleteThumbnail {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
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
        .resource("/download/{publication_id}/{tail:.*}", |r| r.f(download))
}
