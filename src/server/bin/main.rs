#![feature(plugin)]
#![plugin(rocket_codegen)]

extern crate rocket;

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
    rocket::ignite().mount("/", routes![files, index]).mount("/api", routes![hello]).launch();
}
