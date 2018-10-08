extern crate diesel;

use actix_web::http::Method;
use actix_web::Json;
use actix_web::{middleware, App, AsyncResponder, FutureResponse, HttpResponse, Path, State};
use db::category::{Create, Delete, Favorite, Get, List, Update};
use futures::Future;
use models::{Category, NewCategory};
use state::AppState;

fn favorite(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Favorite {})
        .from_err()
        .and_then(|res| match res {
            Ok(categories) => Ok(HttpResponse::Ok().json(categories)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(List {})
        .from_err()
        .and_then(|res| match res {
            Ok(categories) => Ok(HttpResponse::Ok().json(categories)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn create(state: State<AppState>, json: Json<NewCategory>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Create {
            new_category: json.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn update(state: State<AppState>, json: Json<Category>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Update {
            category: json.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn delete(state: State<AppState>, category_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Delete {
            category_id: category_id.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(err) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn get(state: State<AppState>, category_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            category_id: category_id.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(category) => Ok(HttpResponse::Ok().json(category)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

pub fn create_app(state: AppState, prefix: &str) -> App<AppState> {
    App::with_state(state)
        .middleware(middleware::Logger::default())
        .prefix(prefix)
        .route("/", Method::GET, list)
        .route("/", Method::POST, create)
        .route("/", Method::PUT, update)
        .route("/{category_id}", Method::DELETE, delete)
        .route("/{category_id}", Method::GET, get)
        .route("/favorite/", Method::GET, favorite)
}
