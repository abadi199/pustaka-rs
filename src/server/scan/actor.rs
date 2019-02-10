use actix::prelude::*;
use config;
use models;
use scan::error::ScannerError;
use std::boxed::Box;
use walkdir::DirEntry;
use walkdir::WalkDir;

#[derive(Debug, Clone)]
pub struct Scanner;

impl Actor for Scanner {
    type Context = SyncContext<Self>;
}

pub struct Scan;
impl Message for Scan {
    type Result = Result<Vec<File>, ScannerError>;
}

// lazy_static! {
//     static ref IGNORED_FN: Vec<Fn(&File) -> bool> = vec![
//         |file| true && true && true && true && true,
//         |file| true,
//         |file| true
//     ];
// }

impl Handler<Scan> for Scanner {
    type Result = Result<Vec<File>, ScannerError>;

    fn handle(&mut self, _msg: Scan, _: &mut Self::Context) -> Self::Result {
        let config = config::get_config();
        Ok(WalkDir::new(&config.publication_path)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(|dir| dir.file_type().is_file())
            .map(|dir| File {
                name: dir.path().to_str().unwrap_or("").to_string(),
                components: dir
                    .path()
                    .iter()
                    .filter_map(|c| c.to_str())
                    .map(|c| c.to_string())
                    .collect(),
            })
            .collect())
    }
}

#[derive(Debug, Clone)]
pub struct Category {
    pub id: i32,
    pub name: String,
}

impl Category {
    pub fn from(category: &models::Category) -> Self {
        // TODO
        Category {
            id: category.id.clone(),
            name: category.name.clone(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct File {
    pub name: String,
    pub components: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct ProcessFile {
    pub categories: Vec<Category>,
    pub file: File,
}
impl Message for ProcessFile {
    type Result = Result<(), ScannerError>;
}
impl Handler<ProcessFile> for Scanner {
    type Result = Result<(), ScannerError>;

    fn handle(&mut self, msg: ProcessFile, _: &mut Self::Context) -> Self::Result {
        // let path = dir.path();
        // let extension = path.extension();
        // let category = process_category(&path, categories);
        // println!("{:?}", msg);
        let file = msg.file;
        let categories = msg.categories;
        let matched_category = process_category(&file, &categories);
        println!("matched_category: {:?}", matched_category);
        Ok(())
    }
}

fn process_category<'a>(
    file: &File,
    categories: &'a [Category],
) -> Result<&'a Category, ScannerError> {
    match categories.len() == 0 {
        true => Err(ScannerError::EmptyCategoryError),
        false => {
            let matched_category = categories
                .iter()
                .map(|category| (rank_category(category, file), category))
                .max_by(|a, b| a.0.partial_cmp(&b.0).unwrap())
                .map(|(_, cat)| cat);
            matched_category.ok_or(ScannerError::NoMatchCategory)
        }
    }
}

fn rank_category(category: &Category, file: &File) -> f64 {
    let highest_score = file
        .components
        .iter()
        .fold(0_f64, |current_highest_score, current| {
            let score = strsim::normalized_damerau_levenshtein(&category.name, &current);
            if score > current_highest_score {
                return score;
            }

            current_highest_score
        });
    highest_score
}
