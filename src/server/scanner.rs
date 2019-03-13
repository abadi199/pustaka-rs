extern crate actix;
extern crate actix_web;
extern crate futures;
extern crate pustaka;
extern crate strsim;
extern crate walkdir;

use actix::prelude::*;
use futures::future::{join_all, Future};
use pustaka::config::{self, Config};
use pustaka::db::executor::DbExecutor;
use pustaka::db::{publication, publication_category};
use pustaka::models::{NewPublication, PublicationCategory, PublicationId};
use pustaka::scan::actor::{
    load_metadata::LoadMetadata,
    process_file::ProcessFile,
    scan_folder::ScanFolder,
    {Category, CategoryId, File, Scanner},
};
use pustaka::scan::error::ScannerError;
use std::collections::HashMap;

fn main() {
    let sys = System::new("pustaka-scanner");
    let pool = pustaka::db::create_db_pool();
    let db = SyncArbiter::start(3, move || DbExecutor(pool.clone()));
    let scanner = SyncArbiter::start(5, || Scanner {});
    let config = config::get_config();

    let task = db
        .send(pustaka::db::category::List {})
        .join(scanner.clone().send(ScanFolder {}))
        .and_then(move |(categories, files)| {
            process_files_and_load_metadata(scanner.clone(), &config, categories, files)
        })
        .and_then(move |res| {
            save_publication(db.clone(), res)
                .and_then(move |res| save_publication_categories(db.clone(), res))
        })
        .map(|res| {
            println!("The End");
        })
        .map_err(|err| println!("{:?}", err));

    Arbiter::spawn(task);
    sys.run();
}

fn process_files_and_load_metadata(
    scanner: Addr<Scanner>,
    config: &Config,
    categories: Result<Vec<pustaka::models::Category>, actix_web::Error>,
    files: Result<Vec<File>, ScannerError>,
) -> impl Future<
    Item = Vec<Result<(NewPublication, CategoryId), ScannerError>>,
    Error = actix::MailboxError,
> {
    let files = files.unwrap();
    let categories: Vec<Category> = categories
        .unwrap_or(vec![])
        .iter()
        .map(&Category::from)
        .collect();
    let mut batch = Vec::new();
    for file in files.iter() {
        let scanner_clone = scanner.clone();
        let task = scanner
            .send(ProcessFile {
                config: config.clone(),
                categories: categories.clone(),
                file: file.clone(),
            })
            .and_then(move |res| {
                let (file, category_id) = res.unwrap();
                scanner_clone.send(LoadMetadata {
                    file: file,
                    category_id: category_id,
                })
            });
        batch.push(task);
    }
    join_all(batch)
}

fn save_publication(
    db: Addr<DbExecutor>,
    files: Vec<Result<(NewPublication, CategoryId), ScannerError>>,
) -> impl Future<
    Item = Result<Vec<(PublicationId, CategoryId)>, actix_web::Error>,
    Error = actix::MailboxError,
> {
    let mut batch: Vec<NewPublication> = Vec::new();
    let mut file_map: HashMap<String, CategoryId> = HashMap::new();
    for result in files.into_iter() {
        if let Ok((publication, category_id)) = result {
            file_map.insert(publication.file.clone(), category_id);
            batch.push(publication);
        }
    }

    db.send(publication::CreateBatch(batch)).map(move |result| {
        result.map(|publications| {
            publications
                .into_iter()
                .map(|publication| {
                    let category_id = file_map.get(&publication.file).unwrap();
                    (publication.id, *category_id)
                })
                .collect()
        })
    })
}

fn save_publication_categories(
    db: Addr<DbExecutor>,
    publications: Result<Vec<(PublicationId, CategoryId)>, actix_web::Error>,
) -> impl Future<Item = Result<(), actix_web::Error>, Error = actix::MailboxError> {
    let publication_categories: Vec<PublicationCategory> = publications
        .unwrap()
        .iter()
        .map(|(publication_id, category_id)| PublicationCategory {
            publication_id: *publication_id,
            category_id: *category_id,
        })
        .collect();
    db.send(publication_category::CreateBatch(publication_categories))
}
