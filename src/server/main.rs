extern crate actix;
extern crate actix_web;
extern crate diesel;
extern crate pustaka;

use actix::prelude::*;
use actix_web::{fs::NamedFile, http, server, App, HttpRequest, Result};
use http::Method;
use pustaka::api::{author, category, media_type, publication, tag};
use pustaka::db::executor::DbExecutor;
use pustaka::state::AppState;
use std::path::PathBuf;

fn assets(req: &HttpRequest<AppState>) -> Result<NamedFile> {
    let mut path: PathBuf = PathBuf::from("./app/assets");
    let file: PathBuf = req.match_info().query("tail").unwrap();
    println!("file: {:?}", file);
    path.push(file);
    Ok(NamedFile::open(path)?)
}

fn index(_req: &HttpRequest<AppState>) -> Result<NamedFile> {
    let mut path: PathBuf = PathBuf::from("./app");
    let index: PathBuf = PathBuf::from("index.html");
    println!("index");
    path.push(index);

    Ok(NamedFile::open(path)?)
}

fn main() {
    let sys = actix::System::new("pustaka");

    // start db executor
    let pool = pustaka::db::create_db_pool();
    let state = AppState {
        db: SyncArbiter::start(3, move || DbExecutor(pool.clone())),
    };

    // start http server
    server::new(move || {
        vec![
            category::create_app(state.clone(), "/api/category"),
            publication::create_app(state.clone(), "/api/publication"),
            author::create_app(state.clone(), "/api/author"),
            media_type::create_app(state.clone(), "/api/media_type"),
            tag::create_app(state.clone(), "/api/tag"),
            App::with_state(state.clone())
                .resource("/assets/{tail:.*}", |r| r.method(Method::GET).f(assets))
                .resource("/{tail:.*}", |r| r.method(Method::GET).f(index)),
        ]
    })
    .bind("0.0.0.0:8081")
    .unwrap()
    .start();

    println!("Started pustaka server at 0.0.0.0:8081");
    let _ = sys.run();
}
