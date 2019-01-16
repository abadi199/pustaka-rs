#![allow(proc_macro_derive_resolution_fallback)]
#[macro_use]
extern crate diesel;
extern crate serde;
#[macro_use]
extern crate serde_derive;
extern crate actix;
extern crate actix_web;
extern crate dotenv;
extern crate epub;
extern crate futures;
extern crate r2d2;
extern crate r2d2_diesel;
extern crate unrar;
extern crate zip;
#[macro_use]
extern crate diesel_derive_enum;

pub mod api;
pub mod config;
pub mod db;
pub mod models;
pub mod reader;
pub mod schema;
pub mod state;
pub mod unzip;
