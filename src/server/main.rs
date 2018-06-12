#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate diesel;
extern crate pustaka;
extern crate rocket;
extern crate rocket_contrib;

use rocket::response::NamedFile;
use rocket::response::Redirect;
use std::path::{Path, PathBuf};

#[get("/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    println!("{:?}", file);
    NamedFile::open(Path::new("app").join(file)).ok()
}

#[get("/")]
#[error(404)]
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
        .mount("/api/author", pustaka::api::author::routes())
        .mount("/api/tag", pustaka::api::tag::routes())
        .mount("/", routes![redirect_to_app])
        .catch(errors![index])
        .launch();
}
