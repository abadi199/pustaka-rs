extern crate actix;
extern crate futures;
extern crate pustaka;
extern crate strsim;
extern crate walkdir;

use actix::prelude::*;
use futures::future::join_all;
use futures::future::Future;
use pustaka::db::executor::DbExecutor;
use pustaka::scan::{
    actor::msg::{ProcessFile, ScanFolder},
    actor::scanner::{Category, Scanner},
};

fn main() {
    let sys = System::new("pustaka-scanner");
    let pool = pustaka::db::create_db_pool();
    let db = SyncArbiter::start(3, move || DbExecutor(pool.clone()));
    let scanner = SyncArbiter::start(5, move || Scanner {});

    let task = db
        .send(pustaka::db::category::List {})
        .join(scanner.send(ScanFolder {}))
        .and_then(move |(categories, files)| {
            println!("{:?}", files);
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
        })
        .map(|_| {
            println!("The End");
        });

    Arbiter::spawn(task.map_err(|err| println!("{:?}", err)));
    sys.run();
}
