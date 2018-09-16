#![feature(extern_prelude)]
#![feature(plugin)]
#![plugin(rocket_codegen)]

#[macro_use]
extern crate diesel;
extern crate serde;
#[macro_use]
extern crate serde_derive;
extern crate dotenv;
extern crate r2d2;
extern crate r2d2_diesel;
extern crate rocket;
extern crate rocket_contrib;
extern crate unrar;

pub mod api;
pub mod db;
pub mod models;
pub mod reader;
pub mod schema;
