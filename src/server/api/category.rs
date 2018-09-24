extern crate diesel;

// use db::DbConn;
// use models::*;
use actix::prelude::*;
use actix_web::{AsyncResponder, FutureResponse, HttpResponse, Path, State};

use db::category::Favorite;
use futures::future;
use futures::Future;
use state::AppState;
// use rocket::Route;
// use rocket_contrib::Json;

// #[get("/")]
// fn list(connection: DbConn) -> Json<Vec<Category>> {
//     let categories = category
//         .load::<Category>(&*connection)
//         .expect("Error loading categories");
//     Json(categories)
// }

// #[post("/", data = "<json>")]
// fn create(json: Json<NewCategory>, connection: DbConn) {
//     let new_category = &json.0;
//     diesel::insert_into(category)
//         .values(new_category)
//         .execute(&*connection)
//         .expect("Error inserting category");
// }

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

pub fn favorite(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .categoryDb
        .send(Favorite {})
        .from_err()
        .and_then(|res| match res {
            Ok(categories) => Ok(HttpResponse::Ok().json(categories)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

pub fn handlers((path, state): (Path<String>, State<AppState>)) -> FutureResponse<HttpResponse> {
    match path.as_str() {
        "favorite" => favorite(state),
        _ => future::ok(HttpResponse::NotFound().into()).responder(),
    }
}
