use actix_web::http::Method;
use actix_web::{middleware, App, AsyncResponder, FutureResponse, HttpResponse, Json, Path, State};
use db::tag::{Create, Delete, Get, List, Update};
use futures::Future;
use models::{NewTag, Tag};
use state::AppState;

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(List {})
        .from_err()
        .and_then(|res| match res {
            Ok(tags) => Ok(HttpResponse::Ok().json(tags)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn create(state: State<AppState>, json: Json<NewTag>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Create {
            new_tag: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn update(state: State<AppState>, json: Json<Tag>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Update {
            tag: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn delete(state: State<AppState>, tag_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Delete {
            tag_id: tag_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn get(state: State<AppState>, tag_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            tag_id: tag_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(tag) => Ok(HttpResponse::Ok().json(tag)),
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
        .route("/{tag_id}", Method::DELETE, delete)
        .route("/{tag_id}", Method::GET, get)
}
