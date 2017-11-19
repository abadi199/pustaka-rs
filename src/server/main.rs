#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate rocket;
extern crate diesel;
extern crate rocket_contrib;
extern crate pustaka;

use std::path::{Path, PathBuf};
use rocket::response::NamedFile;
use rocket::response::Redirect;

#[get("/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    println!("{:?}", file);
    NamedFile::open(Path::new("app").join(file)).ok()
}

#[get("/")]
fn index() -> Option<NamedFile> {
    NamedFile::open(Path::new("app/index.html")).ok()
}

#[get("/")]
fn redirect_to_app() -> Redirect {
    Redirect::permanent("/app")
}

fn main() {
    rocket::ignite()
        .manage(pustaka::db::create_db_pool())
        .mount("/app", routes![files, index])
        .mount("/api/category", pustaka::api::category::routes())
        .mount("/api/media_type", pustaka::api::media_type::routes())
        .mount("/", routes![redirect_to_app])
        .launch();
}
