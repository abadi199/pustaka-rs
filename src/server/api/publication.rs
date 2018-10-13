use actix_web::http::Method;
use actix_web::{
    fs::NamedFile, middleware, App, AsyncResponder, FutureResponse, HttpResponse, Json, Path, State,
};
use db::publication::{Create, Delete, Get, List, ListByCategory, Update};
use futures::Future;
use models::{NewPublication, Publication};
use reader::cbr;
use state::AppState;
use std::io;

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
        .send(Create {
            new_publication: json.into_inner(),
        })
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
            Ok(publication) => cbr::open(&publication)
                .map_err(|err| err.into())
                .and_then(|data| Ok(HttpResponse::Ok().json(data))),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn read_page(state: State<AppState>, params: Path<(i32, usize)>) -> FutureResponse<NamedFile> {
    println!("read_page");
    state
        .db
        .send(Get {
            publication_id: params.0,
        })
        .from_err()
        .and_then(move |res| {
            res.and_then(|publication| {
                let filename = cbr::page(&publication, params.1).expect("Unable to read page");
                let file = NamedFile::open(filename);
                file.map_err(|err| err.into())
            })
        })
        .responder()
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
}
