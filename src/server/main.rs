extern crate actix;
extern crate actix_web;
extern crate diesel;
extern crate pustaka;

use actix::prelude::*;
use actix_web::{fs::NamedFile, http, server, App, HttpRequest, Result};
use http::Method;
use pustaka::api::{author, category, media_type, publication, tag};
use pustaka::config;
use pustaka::db::executor::DbExecutor;
use pustaka::db::setting;
use pustaka::fs::executor::FsExecutor;
use pustaka::state::AppState;
use std::path::PathBuf;

fn assets(req: &HttpRequest<AppState>) -> Result<NamedFile> {
    let index_html: PathBuf = ["app", "index.html"].iter().collect();
    let file: String = req.match_info().query("tail").unwrap();
    if file.is_empty() {
        return Ok(NamedFile::open(index_html)?);
    } else {
        let path: PathBuf = ["app", &file].iter().collect();
        Ok(NamedFile::open(path).or(NamedFile::open(index_html))?)
    }
}

fn main() { 
    let sys = actix::System::new("pustaka");

    // start db executor
    let config = config::get_config();
    let pool = pustaka::db::create_db_pool(&config.database);

    let state = AppState {
        db: SyncArbiter::start(1, move || DbExecutor(pool.clone())),
        fs: SyncArbiter::start(1, move || FsExecutor()),
        config: config,
    };

    // start http server
    server::new(move || {
        vec![
            category::create_app(state.clone(), "/api/category"),
            publication::create_app(state.clone(), publication::BASE_PATH),
            author::create_app(state.clone(), "/api/author"),
            media_type::create_app(state.clone(), "/api/media_type"),
            tag::create_app(state.clone(), "/api/tag"),
            App::with_state(state.clone())
                .resource("/{tail:.*}", |r| r.method(Method::GET).f(assets)),
        ]
    })
    .bind("0.0.0.0:8081")
    .unwrap()
    .start();

    println!("Started pustaka server at 0.0.0.0:8081");
    let _ = sys.run();
}
