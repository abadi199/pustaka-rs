extern crate diesel;

// use db::DbConn;
// use models::*;
use actix_web::http::Method;
use actix_web::Json;
use actix_web::{middleware, App, AsyncResponder, FutureResponse, HttpResponse, Path, State};
use db::category::Create;
use db::category::Favorite;
use db::category::List;
use futures::Future;
use models::NewCategory;
use state::AppState;

fn favorite(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .categoryDb
        .send(Favorite {})
        .from_err()
        .and_then(|res| match res {
            Ok(categories) => Ok(HttpResponse::Ok().json(categories)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .categoryDb
        .send(List {})
        .from_err()
        .and_then(|res| match res {
            Ok(categories) => Ok(HttpResponse::Ok().json(categories)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn create(state: State<AppState>, json: Json<NewCategory>) -> FutureResponse<HttpResponse> {
    state
        .categoryDb
        .send(Create {
            new_category: json.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

// #[put("/", data = "<json>")]
// fn update(json: Json<Category>, connection: DbConn) {
//     let the_category = &json.0;
//     diesel::update(category.filter(id.eq(the_category.id)))
//         .set(the_category)
//         .execute(&*connection)
//         .expect("Error updating category");
// }

// #[delete("/<category_id>")]
// fn delete(category_id: i32, connection: DbConn) {
//     diesel::delete(category.filter(id.eq(category_id)))
//         .execute(&*connection)
//         .expect(&format!("Error deleting category {}", category_id));
// }

// #[get("/<category_id>")]
// fn get(category_id: i32, connection: DbConn) -> Json<Category> {
//     let mut row = category
//         .filter(id.eq(category_id))
//         .limit(1)
//         .load(&*connection)
//         .expect(&format!("Error loading category with id {}", category_id));

//     match row.is_empty() {
//         true => panic!(format!(
//             "category with id of {} can't be found",
//             category_id
//         )),
//         false => Json(row.remove(0)),
//     }
// }

pub fn create_app(state: AppState, prefix: &str) -> App<AppState> {
    App::with_state(state)
        .middleware(middleware::Logger::default())
        .prefix(prefix)
        .resource("/", |r| r.method(Method::GET).with(list))
        .resource("/", |r| r.method(Method::POST).with(create))
        .resource("/favorite", |r| r.method(Method::GET).with(favorite))
}
