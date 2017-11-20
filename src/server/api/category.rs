extern crate diesel;

use db::DbConn;
use models::*;
use diesel::prelude::*;
use schema::category::dsl::*;
use rocket_contrib::Json;
use rocket::Route;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<Category>> {
    let categories = category.load::<Category>(&*connection).expect(
        "Error loading categories",
    );
    Json(categories)
}

#[post("/", data = "<new_category>")]
fn create(new_category: Json<NewCategory>, connection: DbConn) -> Json<usize> {
    let result = diesel::insert(&new_category.0)
        .into(category)
        .execute(&*connection)
        .expect("Error inserting category");
    Json(result)
}

#[delete("/<category_id>")]
fn delete(category_id: i32, connection: DbConn) -> Json<bool> {
    diesel::delete(category.filter(id.eq(category_id)))
        .execute(&*connection)
        .expect(&format!("Error deleting category {}", category_id));

    Json(true)
}

#[get("/<category_id>")]
fn get_category(category_id: i32, connection: DbConn) -> Json<Category> {
    let mut row = category
        .filter(id.eq(category_id))
        .limit(1)
        .load(&*connection)
        .expect(&format!("Error loading category with id {}", category_id));

    match row.is_empty() {
        true => {
            panic!(format!(
                "category with id of {} can't be found",
                category_id
            ));
        }
        false => Json(row.remove(0)),
    }
}

pub fn routes() -> Vec<Route> {
    routes![list, create, delete]
}
