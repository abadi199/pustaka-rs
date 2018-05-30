extern crate diesel;

use db::DbConn;
use models::*;
use diesel::prelude::*;
use schema::author::dsl::*;
use rocket_contrib::Json;
use rocket::Route;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<Author>> {
    let authors = author.load::<Author>(&*connection).expect(
        "Error loading authors",
    );
    Json(authors)
}

#[post("/", data = "<new_author>")]
fn create(new_author: Json<NewAuthor>, connection: DbConn) -> Json<usize> {
    let result = diesel::insert_into(author)
        .values(&new_author.0)
        .execute(&*connection)
        .expect("Error inserting author");
    Json(result)
}

#[delete("/<author_id>")]
fn delete(author_id: i32, connection: DbConn) -> Json<bool> {
    diesel::delete(author.filter(id.eq(author_id)))
        .execute(&*connection)
        .expect(&format!("Error deleting author {}", author_id));
    Json(true)
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
    routes![list, create, delete, get]
}
