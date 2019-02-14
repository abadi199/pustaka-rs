extern crate actix;
extern crate actix_web;
extern crate futures;
extern crate pustaka;
extern crate strsim;
extern crate walkdir;

use actix::prelude::*;
use futures::future::{join_all, AndThen, Future, JoinAll};
use pustaka::config::{self, Config};
use pustaka::db::executor::DbExecutor;
use pustaka::db::{publication, publication_category};
use pustaka::models::{NewPublication, Publication, PublicationCategory, PublicationId};
use pustaka::scan::actor::{
    process_file::ProcessFile,
    scan_folder::ScanFolder,
    {Category, CategoryId, File, FileId, Scanner},
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
            process_files(scanner.clone(), &config, categories, files)
        })
        .and_then(move |res| {
            save_publication(db.clone(), res)
                .and_then(move |res| save_publication_categories(db.clone(), res))
        })
        .map(|res| {
            println!("{:?}", res);
            println!("The End");
        })
        .map_err(|err| println!("{:?}", err));

    Arbiter::spawn(task);
    sys.run();
}

fn process_files(
    scanner: Addr<Scanner>,
    config: &Config,
    categories: Result<Vec<pustaka::models::Category>, actix_web::Error>,
    files: Result<Vec<File>, ScannerError>,
) -> impl Future<Item = Vec<Result<(File, CategoryId), ScannerError>>, Error = actix::MailboxError>
{
    let files = files.unwrap();
    let mut batch = Vec::new();
    let categories: Vec<Category> = categories
        .unwrap_or(vec![])
        .iter()
        .map(&Category::from)
        .collect();

    for file in files.iter() {
        batch.push(scanner.send(ProcessFile {
            config: config.clone(),
            categories: categories.clone(),
            file: file.clone(),
        }));
    }
    join_all(batch)
}

fn save_publication(
    db: Addr<DbExecutor>,
    files: Vec<Result<(File, CategoryId), ScannerError>>,
) -> impl Future<
    Item = Result<Vec<(PublicationId, CategoryId)>, actix_web::Error>,
    Error = actix::MailboxError,
> {
    let mut batch = Vec::new();
    let mut file_map = HashMap::new();
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
                file_map.insert(file.name.clone(), *category_id);
            }
            _ => {}
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
