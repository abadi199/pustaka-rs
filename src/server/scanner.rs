extern crate actix;
extern crate actix_web;
extern crate futures;
extern crate pustaka;
extern crate strsim;
extern crate walkdir;

use actix::prelude::*;
use futures::future::{join_all, JoinAll};
use futures::future::{AndThen, Future};
use pustaka::db::executor::DbExecutor;
use pustaka::db::{publication, publication_category};
use pustaka::models::{NewPublication, PublicationCategory};
use pustaka::scan::actor::{
    process_file::ProcessFile,
    scan_folder::ScanFolder,
    {Category, CategoryId, File, FileId, Scanner},
};
use pustaka::scan::error::ScannerError;

fn main() {
    let sys = System::new("pustaka-scanner");
    let pool = pustaka::db::create_db_pool();
    let db = SyncArbiter::start(3, move || DbExecutor(pool.clone()));
    let scanner = SyncArbiter::start(5, || Scanner {});

    let task = db
        .send(pustaka::db::category::List {})
        .join(scanner.clone().send(ScanFolder {}))
        .and_then(move |(categories, files)| process_files(scanner.clone(), categories, files))
        .and_then(move |files| save_publication(db.clone(), files))
        .map(|res| {
            println!("{:?}", res);
            println!("The End");
        });

    Arbiter::spawn(task.map_err(|err| println!("{:?}", err)));
    sys.run();
}

fn process_files(
    scanner: Addr<Scanner>,
    categories: Result<Vec<pustaka::models::Category>, actix_web::Error>,
    files: Result<Vec<File>, ScannerError>,
) -> JoinAll<Vec<Request<Scanner, ProcessFile>>> {
    let files = files.unwrap();
    let mut batch = Vec::new();
    let categories: Vec<Category> = categories
        .unwrap_or(vec![])
        .iter()
        .map(&Category::from)
        .collect();

    for file in files.iter() {
        batch.push(scanner.send(ProcessFile {
            categories: categories.clone(),
            file: file.clone(),
        }));
    }
    join_all(batch)
}

fn save_publication(
    db: Addr<DbExecutor>,
    files: Vec<Result<(File, CategoryId), ScannerError>>,
) -> Request<DbExecutor, publication::CreateBatch> {
    let mut batch = Vec::new();
    for result in files.iter() {
        match result {
            Ok((file, category_id)) => {
                let publication = NewPublication {
                    isbn: "".to_string(),
                    title: file.name.clone(),
                    media_type_id: 1,
                    media_format: file.extension.clone(),
                    author_id: 1,
                    thumbnail: None,
                    file: file.name.clone(),
                };
                batch.push(publication);
            }
            _ => {}
        }
    }

    db.send(publication::CreateBatch {
        new_publications: batch,
    })
}

fn save_publication_categories() {
    let publication_categories: Vec<PublicationCategory> = publications
        .expect("")
        .iter()
        .map(|publication| PublicationCategory {
            publication_id: publication.id,
            category_id: 1,
        })
        .collect();
    db.send(publication_category::CreateBatch {
        new_publication_categories: publication_categories,
    })
}
