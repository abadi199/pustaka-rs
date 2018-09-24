extern crate actix;
extern crate actix_web;
extern crate diesel;
extern crate pustaka;

use actix::prelude::*;
use actix_web::dev::Params;
use actix_web::{fs::NamedFile, http, middleware, server, App, HttpRequest, HttpResponse, Result};
use pustaka::db::category::CategoryDbExecutor;
use pustaka::state::AppState;
use std::path::{Path, PathBuf};
// #[get("/<file..>")]
// fn files(file: PathBuf) -> Option<NamedFile> {
//     println!("{:?}", file);
//     NamedFile::open(Path::new("app").join(file)).ok()
// }

fn index(req: &HttpRequest<AppState>) -> Result<NamedFile> {
    let mut path: PathBuf = PathBuf::from("./app");
    let index: PathBuf = PathBuf::from("index.html");
    let file: PathBuf = req.match_info().query("tail").unwrap_or(index.clone());
    println!("file: {:?}", file);
    if file.clone().into_os_string() == "" {
        path.push(index);
    } else {
        path.push(file);
    }

    println!("path: {:?}", path);
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
    let addr = SyncArbiter::start(3, move || CategoryDbExecutor(pool.clone()));

    // start http server
    server::new(move || {
        vec![
            pustaka::api::category::create_app(
                AppState {
                    categoryDb: addr.clone(),
                },
                "/api/category",
            ),
            App::with_state(AppState {
                categoryDb: addr.clone(),
            }).resource(r"/{tail:.*}", |r| r.method(http::Method::GET).f(index)),
        ]
    }).bind("0.0.0.0:8080")
    .unwrap()
    .start();

    println!("Started pustaka server at 0.0.0.0:8080");
    let _ = sys.run();
}
