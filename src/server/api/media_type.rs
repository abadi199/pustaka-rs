extern crate diesel;

use db::DbConn;
use diesel::prelude::*;
use models::*;
use rocket::Route;
use rocket_contrib::Json;
use schema::media_type::dsl::*;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<MediaType>> {
    let media_types = media_type
        .load::<MediaType>(&*connection)
        .expect("Error loading media types");
    Json(media_types)
}

#[post("/", data = "<json>")]
fn create(json: Json<NewMediaType>, connection: DbConn) {
    let new_media_type = &json.0;
    diesel::insert_into(media_type)
        .values(new_media_type)
        .execute(&*connection)
        .expect("Error inserting media type");
}

#[put("/", data = "<json>")]
fn update(json: Json<MediaType>, connection: DbConn) {
    let the_media_type = &json.0;
    diesel::update(media_type.filter(id.eq(the_media_type.id)))
        .set(the_media_type)
        .execute(&*connection)
        .expect("Error updating media type");
}

#[delete("/<media_type_id>")]
fn delete(media_type_id: i32, connection: DbConn) {
    diesel::delete(media_type.filter(id.eq(media_type_id)))
        .execute(&*connection)
        .expect(&format!("Error deleting media type {}", media_type_id));
}

#[get("/<media_type_id>")]
fn get(media_type_id: i32, connection: DbConn) -> Json<MediaType> {
    let mut row = media_type
        .filter(id.eq(media_type_id))
        .limit(1)
        .load(&*connection)
        .expect(&format!(
            "Error loading media type with id {}",
            media_type_id
        ));

    match row.is_empty() {
        true => panic!(format!(
            "media_type with id of {} can't be found",
            media_type_id
        )),
        false => Json(row.remove(0)),
    }
}

pub fn routes() -> Vec<Route> {
    routes![list, create, delete, get, update]
}
