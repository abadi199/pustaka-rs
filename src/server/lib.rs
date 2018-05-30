#![feature(plugin)]
#![plugin(rocket_codegen)]

#[macro_use]
extern crate diesel;
#[macro_use]
extern crate serde;
#[macro_use]
extern crate serde_derive;
extern crate rocket;
extern crate rocket_contrib;
extern crate dotenv;
extern crate r2d2;
extern crate r2d2_diesel;

pub mod schema;
pub mod models;
pub mod db;
pub mod api;
