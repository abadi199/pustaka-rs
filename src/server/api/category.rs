extern crate diesel;

use db::DbConn;
use diesel::prelude::*;
use models::*;
use rocket::Route;
use rocket_contrib::Json;
use schema::category::dsl::*;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<Category>> {
    let categories = category
        .load::<Category>(&*connection)
        .expect("Error loading categories");
    Json(categories)
}

#[post("/", data = "<new_category>")]
fn create(new_category: Json<NewCategory>, connection: DbConn) {
    diesel::insert_into(category)
        .values(&new_category.0)
        .execute(&*connection)
        .expect("Error inserting category");
}

#[put("/", data = "<the_category>")]
fn update(the_category: Json<Category>, connection: DbConn) {
    diesel::update(category.filter(id.eq(&the_category.0.id)))
        .set(&the_category.0)
        .execute(&*connection)
        .expect("Error updating category");
}

#[delete("/<category_id>")]
fn delete(category_id: i32, connection: DbConn) {
    diesel::delete(category.filter(id.eq(category_id)))
        .execute(&*connection)
        .expect(&format!("Error deleting category {}", category_id));
}

#[get("/<category_id>")]
fn get(category_id: i32, connection: DbConn) -> Json<Category> {
    let mut row = category
        .filter(id.eq(category_id))
        .limit(1)
        .load(&*connection)
        .expect(&format!("Error loading category with id {}", category_id));

    match row.is_empty() {
        true => panic!(format!(
            "category with id of {} can't be found",
            category_id
        )),
        false => Json(row.remove(0)),
    }
}

pub fn routes() -> Vec<Route> {
    routes![list, create, delete, get, update]
}
