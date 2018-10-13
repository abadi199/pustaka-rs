use actix_web::http::Method;
use actix_web::{middleware, App, AsyncResponder, FutureResponse, HttpResponse, Json, Path, State};
use db::media_type::{Create, Delete, Get, List, Update};
use futures::Future;
use models::{MediaType, NewMediaType};
use state::AppState;

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(List {})
        .from_err()
        .and_then(|res| match res {
            Ok(media_types) => Ok(HttpResponse::Ok().json(media_types)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn create(state: State<AppState>, json: Json<NewMediaType>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Create {
            new_media_type: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn update(state: State<AppState>, json: Json<MediaType>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Update {
            media_type: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn delete(state: State<AppState>, media_type_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Delete {
            media_type_id: media_type_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn get(state: State<AppState>, media_type_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            media_type_id: media_type_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(media_type) => Ok(HttpResponse::Ok().json(media_type)),
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
        .route("/{media_type_id}", Method::DELETE, delete)
        .route("/{media_type_id}", Method::GET, get)
}
