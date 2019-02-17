use actix_web::http::Method;
use actix_web::{
    error::ErrorBadRequest, fs::NamedFile, middleware, App, AsyncResponder, FutureResponse,
    HttpRequest, HttpResponse, Json, Path, Result, State,
};
use config::Config;
use db::publication::{self, Delete, Get, List, ListByCategory, Update};
use futures::Future;
use models::{NewPublication, Publication, CBR, CBZ, EPUB};
use reader::{comic, epub};
use state::AppState;
use std::{
    error::Error,
    fmt::{Display, Formatter},
    io,
    path::PathBuf,
};

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

fn get_thumbnail(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<NamedFile> {
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
        .route("/thumbnail/{publication_id}", Method::GET, get_thumbnail)
        .route("/read/{publication_id}", Method::GET, read)
        .route(
            "/read/{publication_id}/page/{page_number}",
            Method::GET,
            read_page,
        )
        .resource("/download/{publication_id}/{tail:.*}", |r| r.f(download))
}
