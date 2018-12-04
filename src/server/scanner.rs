extern crate actix;
extern crate diesel;
extern crate futures;
extern crate pustaka;
extern crate r2d2;
extern crate r2d2_diesel;
extern crate tokio;

use actix::prelude::{Actor, Addr, Request, Response, SyncArbiter, System};
use futures::future::Future;
use pustaka::config;
use pustaka::db::executor::DbExecutor;
use pustaka::db::publication;
use pustaka::models::{NewPublication, Publication};
use std::fs;
use std::io;
use std::path::Path;

fn main() {
    System::run(|| {
        let pool = pustaka::db::create_db_pool();
        let db = SyncArbiter::start(1, move || DbExecutor(pool.clone()));

        let config = config::get_config();
        println!("Config: {:?}", config);
        let files: Vec<String> = scan_path(config.publication_path).expect("scan_path error");
        let _ = insert_publications(&files, db);
    });
}

fn scan_path(publication_path: String) -> io::Result<Vec<String>> {
    let path = Path::new(&publication_path);

    let files = &mut vec![];
    if path.is_dir() {
        for entry in try!(fs::read_dir(path)) {
            let entry_dir = entry?;
            let dir_path = entry_dir.path();
            let next_path = dir_path.as_path();
            let next_path_str = dir_path.to_str().unwrap_or_default().to_string();
            if next_path.is_dir() {
                let next_files = &mut scan_path(next_path_str)?;
                files.append(next_files);
            } else {
                files.push(next_path_str);
            }
        }
    } else {
        files.push(publication_path.clone());
    }

    Ok(files.to_vec())
}

fn insert_publications<'a>(
    files: &'a [String],
    db: Addr<DbExecutor>,
) -> Result<Vec<NewPublication>, String> {
    let new_publications: Vec<NewPublication> = files
        .iter()
        .map(|file| NewPublication {
            isbn: "".to_string(),
            title: "".to_string(),
            media_type_id: 2,
            author_id: 1,
            thumbnail: None,
            file: file.clone(),
        }).collect();
    let result: Request<DbExecutor, publication::Create> =
        db.send(publication::Create::Batch(new_publications));
    tokio::spawn(
        result
            .and_then(move |_| db.send(publication::Get { publication_id: 1 }))
            .map(|res| {
                println!("Done inserting publication: {:?}", res);
                System::current().stop();
            }).map_err(|_| ()),
    );
    Ok(vec![])
}
