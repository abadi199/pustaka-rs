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
use pustaka::models::{NewPublication, Publication, PublicationCategory, PublicationId};
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
    let db = SyncArbiter::start(1, move || DbExecutor(pool.clone()));
    let db_1 = db.clone();
    let db_2 = db.clone();
    let db_3 = db.clone();

    let scanner = SyncArbiter::start(5, || Scanner {});
    let scanner_1 = scanner.clone();
    let scanner_2 = scanner.clone();
    let config = config::get_config();
    let config_1 = config.clone();
    let config_2 = config.clone();
    let home_path = config.pustaka_home.clone();

    let task = db
        .send(pustaka::db::category::List {})
        .join(scanner.clone().send(ScanFolder {}))
        .and_then(|(categories, files)| process_files(scanner_1, config_1, categories, files))
        .and_then(|res| save_publication(db_1, res))
        .and_then(|res| update_metadata(config_2, scanner_2, res))
        .and_then(|res| update_publication(db_2, res))
        .and_then(|res| save_publication_categories(db_3, res))
        .map(|_| {
            println!("The End");
        })
        .map_err(|err| println!("{:?}", err));

    Arbiter::spawn(task);
    sys.run();
}

fn process_files(
    scanner: Addr<Scanner>,
    config: Config,
    categories: Result<Vec<pustaka::models::Category>, actix_web::Error>,
    files: Result<Vec<File>, ScannerError>,
) -> Box<Future<Item = Vec<Result<(File, CategoryId), ScannerError>>, Error = actix::MailboxError>>
{
    let files = files.unwrap();
    let categories: Vec<Category> = categories
        .unwrap_or(vec![])
        .iter()
        .map(&Category::from)
        .collect();
    let mut batch = Vec::new();
    for file in files.iter() {
        let scanner = scanner.clone();
        let task = scanner.send(ProcessFile {
            config: config.clone(),
            categories: categories.clone(),
            file: file.clone(),
        });
        batch.push(task);
    }
    Box::new(join_all(batch))
}

fn save_publication(
    db: Addr<DbExecutor>,
    files: Vec<Result<(File, CategoryId), ScannerError>>,
) -> Box<
    Future<
        Item = Result<Vec<(Publication, CategoryId)>, actix_web::Error>,
        Error = actix::MailboxError,
    >,
> {
    let mut batch: Vec<NewPublication> = Vec::new();
    let mut file_map: HashMap<String, CategoryId> = HashMap::new();
    for result in files.into_iter() {
        if let Ok((file, category_id)) = result {
            let publication = NewPublication {
                isbn: "".to_string(),
                title: file.name.clone(),
                media_type_id: 1,
                media_format: file.extension.clone(),
                author_id: 1,
                thumbnail: None,
                file: file.path.clone(),
            };

            file_map.insert(publication.file.clone(), category_id);
            batch.push(publication);
        }
    }

    Box::new(db.send(publication::CreateBatch(batch)).map(move |result| {
        result.map(|publications| {
            publications
                .into_iter()
                .map(|publication| {
                    let category_id = file_map.get(&publication.file).unwrap();
                    (publication, *category_id)
                })
                .collect()
        })
    }))
}

fn update_metadata(
    config: Config,
    scanner: Addr<Scanner>,
    result: Result<Vec<(Publication, CategoryId)>, actix_web::Error>,
) -> Box<
    Future<
        Item = Vec<Result<(Publication, CategoryId), ScannerError>>,
        Error = actix::MailboxError,
    >,
> {
    let mut batch = Vec::new();
    let publications = result.unwrap();
    for data in publications.into_iter() {
        let scanner = scanner.clone();
        println!("Publication: {:?}", data.0.file);
        let task = scanner.send(LoadMetadata {
            config: config.clone(),
            publication: data.0,
            category_id: data.1,
        });
        batch.push(task);
    }

    Box::new(join_all(batch))
}

fn update_publication(
    db: Addr<DbExecutor>,
    result: Vec<Result<(Publication, CategoryId), ScannerError>>,
) -> Box<
    Future<
        Item = Vec<Result<(Publication, CategoryId), ScannerError>>,
        Error = actix::MailboxError,
    >,
> {
    let mut batch = Vec::new();
    for data in result.into_iter() {
        let db = db.clone();
        let data = data.unwrap();
        let task = db
            .send(publication::Update {
                publication: data.0.clone(),
            })
            .map(|_| Ok(data));
        batch.push(task)
    }

    Box::new(join_all(batch))
}

fn save_publication_categories(
    db: Addr<DbExecutor>,
    publications: Vec<Result<(Publication, CategoryId), ScannerError>>,
) -> Box<Future<Item = Result<(), actix_web::Error>, Error = actix::MailboxError>> {
    let publication_categories: Vec<PublicationCategory> = publications
        .into_iter()
        .map(|res| {
            let (publication, category_id) = res.unwrap();
            PublicationCategory {
                publication_id: publication.id,
                category_id: category_id,
            }
        })
        .collect();
    Box::new(db.send(publication_category::CreateBatch(publication_categories)))
}
