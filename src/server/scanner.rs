extern crate actix;
extern crate futures;
extern crate pustaka;
extern crate strsim;

use actix::prelude::*;
use futures::future::Future;
use pustaka::config;
use pustaka::db::executor::DbExecutor;
use pustaka::models::Category;
use std::fs::{self, DirEntry};
use std::io;
use std::path::Path;

#[derive(Debug)]
enum ScannerError {
    EmptyCategoryError,
    NoMatchCategory,
}

fn main() {
    let sys = System::new("pustaka-scanner");
    let pool = pustaka::db::create_db_pool();
    let db_addr = SyncArbiter::start(2, move || DbExecutor(pool.clone()));

    let list_category_future = db_addr.send(pustaka::db::category::List {});
    Arbiter::spawn(
        list_category_future
            .map(|res| {
                println!("{:?}", res);
            })
            .map_err(|err| println!("{:?}", err)),
    );
    sys.run();
}

struct Scanner {};

impl Actor for Scanner {
    type Context = SyncContext<Self>;
}

struct Scan {}
impl Message for Scan {
    type Result = Result<(), Error>;
}

impl Handle<Scan> for Scanner {
    type Result = Result<(), Error>;

    fn handle(&mut self, _msg: Scan, _: &mut Self::Context ) -> Self::Result {
        // TODO
    }
}

fn scanning() {
    println!("Scanning folder...");
    let config = config::get_config();
    println!("{:?}", config);
    let path = Path::new(&config.publication_path);
    let categories: &[Category] = &[
        Category {
            id: 1,
            name: "Comics".to_string(),
            parent_id: None,
        },
        Category {
            id: 1,
            name: "Programming".to_string(),
            parent_id: None,
        },
    ];
    visit_dirs(path, &|dir| process_file(categories, dir)).expect("Unable to scan directory");
}

fn process_file<'a>(categories: &'a [Category], dir: &DirEntry) {
    let path = dir.path();
    let extension = path.extension();
    let category = process_category(&path, categories);
    println!("{:?}", category);
}

fn process_category<'a>(
    file: &Path,
    categories: &'a [Category],
) -> Result<&'a Category, ScannerError> {
    match categories.len() == 0 {
        true => Err(ScannerError::EmptyCategoryError),
        false => {
            let matched_category = categories
                .iter()
                .map(|category| (match_category(category, file), category))
                .max_by(|a, b| a.0.partial_cmp(&b.0).unwrap())
                .map(|(_, cat)| cat);
            matched_category.ok_or(ScannerError::NoMatchCategory)
        }
    }
}

fn match_category(category: &Category, file: &Path) -> f64 {
    let highest_score = file
        .components()
        .fold(0_f64, |current_highest_score, current| {
            let score = strsim::normalized_damerau_levenshtein(
                &category.name,
                &current.as_os_str().to_str().unwrap_or(""),
            );
            if score > current_highest_score {
                return score;
            }

            current_highest_score
        });
    highest_score
}

fn visit_dirs(dir: &Path, cb: &Fn(&DirEntry)) -> io::Result<()> {
    if dir.is_dir() {
        for entry in fs::read_dir(dir)? {
            let entry = entry?;
            let path = entry.path();
            if path.is_dir() {
                visit_dirs(&path, cb)?;
            } else {
                cb(&entry);
            }
        }
    }
    Ok(())
}
