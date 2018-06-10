extern crate diesel;

use db::DbConn;
use diesel::prelude::*;
use models::*;
use rocket::Route;
use rocket_contrib::Json;
use schema::tag::dsl::*;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<Tag>> {
    let tags = tag.load::<Tag>(&*connection).expect("Error loading tags");
    Json(tags)
}

#[post("/", data = "<json>")]
fn create(json: Json<NewTag>, connection: DbConn) {
    let new_tag = &json.0;
    diesel::insert_into(tag)
        .values(new_tag)
        .execute(&*connection)
        .expect("Error inserting tag");
}

#[put("/", data = "<json>")]
fn update(json: Json<Tag>, connection: DbConn) {
    let the_tag = &json.0;
    diesel::update(tag.filter(id.eq(the_tag.id)))
        .set(the_tag)
        .execute(&*connection)
        .expect("Error updating tag");
}

#[delete("/<tag_id>")]
fn delete(tag_id: i32, connection: DbConn) {
    diesel::delete(tag.filter(id.eq(tag_id)))
        .execute(&*connection)
        .expect(&format!("Error deleting tag {}", tag_id));
}

#[get("/<tag_id>")]
fn get(tag_id: i32, connection: DbConn) -> Json<Tag> {
    let mut row = tag
        .filter(id.eq(tag_id))
        .limit(1)
        .load(&*connection)
        .expect(&format!("Error loading tag with id {}", tag_id));

    match row.is_empty() {
        true => panic!(format!("tag with id of {} can't be found", tag_id)),
        false => Json(row.remove(0)),
    }
}

pub fn routes() -> Vec<Route> {
    routes![list, create, delete, get, update]
}
