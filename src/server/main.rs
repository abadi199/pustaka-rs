#![feature(plugin)]
#![plugin(rocket_codegen)]

mod api;

extern crate rocket;
extern crate diesel;
extern crate rocket_contrib;
extern crate pustaka;

use std::path::{Path, PathBuf};
use rocket::response::NamedFile;

#[get("/")]
fn hello() -> &'static str {
    "Hello, World"
}


#[get("/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    println!("{:?}", file);
    NamedFile::open(Path::new("app").join(file)).ok()
}

#[get("/")]
fn index() -> Option<NamedFile> {
    NamedFile::open(Path::new("app/index.html")).ok()
}

fn main() {
    rocket::ignite()
        .manage(pustaka::db::create_db_pool())
        .mount("/", routes![files, index])
        .mount("/api/category", api::category::routes())
        .launch();
}
