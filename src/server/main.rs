extern crate actix;
extern crate actix_web;
extern crate diesel;
extern crate pustaka;

use actix::prelude::*;
use actix_web::{fs::NamedFile, http, server, App, HttpRequest, Result};
use http::Method;
use pustaka::api::{category, publication};
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

// #[get("/")]
// fn redirect_to_app() -> Redirect {
// Redirect::permanent("/app")
// }

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
            App::with_state(state.clone())
                .resource("/assets/{tail:.*}", |r| r.method(Method::GET).f(assets))
                .resource("/{tail:.*}", |r| r.method(Method::GET).f(index)),
        ]
    }).bind("0.0.0.0:8080")
    .unwrap()
    .start();

    println!("Started pustaka server at 0.0.0.0:8080");
    let _ = sys.run();
}
