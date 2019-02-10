extern crate actix;
extern crate futures;
extern crate pustaka;
extern crate strsim;
extern crate walkdir;

use actix::prelude::*;
use futures::future::join_all;
use futures::future::Future;
use pustaka::config;
use pustaka::db::executor::DbExecutor;
use pustaka::models::Category;
use std::fs;
use std::io;
use std::path::Path;
use walkdir::{DirEntry, WalkDir};

fn main() {
    let sys = System::new("pustaka-scanner");
    let pool = pustaka::db::create_db_pool();
    let db = SyncArbiter::start(3, move || DbExecutor(pool.clone()));
    let scanner = SyncArbiter::start(5, move || Scanner {});

    let task = db
        .send(pustaka::db::category::List {})
        .join(scanner.send(Scan {}))
        .and_then(move |(categories, files)| {
            let files = files.unwrap();
            let mut batch = Vec::new();
            let categories: Vec<String> = categories
                .expect("")
                .iter()
                .map(|category| category.name.clone())
                .collect();

            for file in files.iter() {
                batch.push(scanner.send(ProcessFile {
                    categories: categories,
                    file: file.clone(),
                }));
            }
            join_all(batch)
        })
        .map(|res| {
            println!("The End");
        });

    Arbiter::spawn(task.map_err(|err| println!("{:?}", err)));
    sys.run();
}

fn process_file<'a>(categories: &'a [Category], dir: &DirEntry) {
    let path = dir.path();
    let extension = path.extension();
    let category = process_category(&path, categories);
    println!("{:?}", category);
}

fn process_category<'a>(file: &Path, categories: &'a [&str]) -> Result<&'a Category, ScannerError> {
    match categories.len() == 0 {
        true => Err(ScannerError::EmptyCategoryError),
        false => {
            let matched_category = categories
                .iter()
                .map(|category_name| (match_category(category_name, file), category_name))
                .max_by(|a, b| a.0.partial_cmp(&b.0).unwrap())
                .map(|(_, cat)| cat);
            matched_category.ok_or(ScannerError::NoMatchCategory)
        }
    }
}

fn match_category(category_name: &str, file: &Path) -> f64 {
    let highest_score = file
        .components()
        .fold(0_f64, |current_highest_score, current| {
            let score = strsim::normalized_damerau_levenshtein(
                category_name,
                &current.as_os_str().to_str().unwrap_or(""),
            );
            if score > current_highest_score {
                return score;
            }

            current_highest_score
        });
    highest_score
}
