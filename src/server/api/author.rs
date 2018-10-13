use actix_web::http::Method;
use actix_web::{middleware, App, AsyncResponder, FutureResponse, HttpResponse, Json, Path, State};
use db::author::{Create, Delete, Get, List, Update};
use futures::Future;
use models::{Author, NewAuthor};
use state::AppState;

// #[get("/")]
// fn list(connection: DbConn) -> Json<Vec<Author>> {
//     let authors = author
//         .load::<Author>(&*connection)
//         .expect("Error loading authors");
//     Json(authors)
// }

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(List {})
        .from_err()
        .and_then(|res| match res {
            Ok(authors) => Ok(HttpResponse::Ok().json(authors)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn create(state: State<AppState>, json: Json<NewAuthor>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Create {
            new_author: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn update(state: State<AppState>, json: Json<Author>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Update {
            author: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn delete(state: State<AppState>, author_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Delete {
            author_id: author_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn get(state: State<AppState>, author_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            author_id: author_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(author) => Ok(HttpResponse::Ok().json(author)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

pub fn create_app(state: AppState, prefix: &str) -> App<AppState> {
    App::with_state(state)
        .middleware(middleware::Logger::default())
        .prefix(prefix)
        .route("/", Method::GET, list)
        .route("/", Method::POST, create)
        .route("/", Method::PUT, update)
        .route("/{author_id}", Method::DELETE, delete)
        .route("/{author_id}", Method::GET, get)
}
