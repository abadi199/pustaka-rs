extern crate diesel;

use db::DbConn;
use diesel::prelude::*;
use models::*;
use rocket::Route;
use rocket_contrib::Json;
use schema::author::dsl::*;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<Author>> {
    let authors = author
        .load::<Author>(&*connection)
        .expect("Error loading authors");
    Json(authors)
}

#[post("/", data = "<json>")]
fn create(json: Json<NewAuthor>, connection: DbConn) {
    let new_author = &json.0;
    diesel::insert_into(author)
        .values(new_author)
        .execute(&*connection)
        .expect("Error inserting author");
}

#[put("/", data = "<json>")]
fn update(json: Json<Author>, connection: DbConn) {
    let the_author = &json.0;
    diesel::update(author.filter(id.eq(the_author.id)))
        .set(the_author)
        .execute(&*connection)
        .expect("Error updating author");
}

#[delete("/<author_id>")]
fn delete(author_id: i32, connection: DbConn) {
    diesel::delete(author.filter(id.eq(author_id)))
        .execute(&*connection)
        .expect(&format!("Error deleting author {}", author_id));
}

#[get("/<author_id>")]
fn get(author_id: i32, connection: DbConn) -> Json<Author> {
    let mut row = author
        .filter(id.eq(author_id))
        .limit(1)
        .load(&*connection)
        .expect(&format!("Error loading author with id {}", author_id));

    match row.is_empty() {
        true => panic!(format!("Author with id of {} can't be found", author_id)),
        false => Json(row.remove(0)),
    }
}

pub fn routes() -> Vec<Route> {
    routes![list, create, delete, get, update]
}
