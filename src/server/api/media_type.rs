extern crate diesel;

use db::DbConn;
use models::*;
use diesel::prelude::*;
use schema::media_type::dsl::*;
use rocket_contrib::Json;
use rocket::Route;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<MediaType>> {
    let media_types = media_type.load::<MediaType>(&*connection).expect(
        "Error loading media types",
    );
    Json(media_types)
}

#[post("/", data = "<new_media_type>")]
fn create(new_media_type: Json<NewMediaType>, connection: DbConn) -> Json<usize> {
    let result = diesel::insert(&new_media_type.0)
        .into(media_type)
        .execute(&*connection)
        .expect("Error inserting media type");
    Json(result)
}

#[delete("/<media_type_id>")]
fn delete(media_type_id: i32, connection: DbConn) -> Json<bool> {
    diesel::delete(media_type.filter(id.eq(media_type_id)))
        .execute(&*connection)
        .expect(&format!("Error deleting media type {}", media_type_id));

    Json(true)
}

#[get("/<media_type_id>")]
fn get_media_type(media_type_id: i32, connection: DbConn) -> Json<MediaType> {
    let mut row = media_type
        .filter(id.eq(media_type_id))
        .limit(1)
        .load(&*connection)
        .expect(&format!(
            "Error loading media type with id {}",
            media_type_id
        ));

    match row.is_empty() {
        true => {
            panic!(format!(
                "media_type with id of {} can't be found",
                media_type_id
            ))
        }
        false => Json(row.remove(0)),
    }
}

pub fn routes() -> Vec<Route> {
    routes![list, create, delete, get_media_type]
}
