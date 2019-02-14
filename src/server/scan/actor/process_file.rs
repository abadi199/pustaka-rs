use actix::prelude::*;
use config::Config;
use scan::actor::{Category, CategoryId, File, Scanner};
use scan::error::ScannerError;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone)]
pub struct ProcessFile {
    pub config: Config,
    pub categories: Vec<Category>,
    pub file: File,
}
impl Message for ProcessFile {
    type Result = Result<(File, CategoryId), ScannerError>;
}

impl Handler<ProcessFile> for Scanner {
    type Result = Result<(File, CategoryId), ScannerError>;

    fn handle(&mut self, msg: ProcessFile, _: &mut Self::Context) -> Self::Result {
        let file = msg.file;
        let categories = msg.categories;
        let matched_category = process_category(&msg.config, &file, &categories)?;
        Ok((file, matched_category.id))
    }
}

fn process_category<'a>(
    config: &Config,
    file: &File,
    categories: &'a [Category],
) -> Result<&'a Category, ScannerError> {
    match categories.len() == 0 {
        true => Err(ScannerError::EmptyCategoryError),
        false => {
            let matched_category = categories
                .iter()
                .map(|category| {
                    (
                        rank_category(&config.publication_path, category, file),
                        category,
                    )
                })
                .max_by(|a, b| a.0.partial_cmp(&b.0).unwrap())
                .map(|(_, cat)| cat);
            matched_category.ok_or(ScannerError::NoMatchCategory)
        }
    }
}

fn rank_category(publication_path: &str, category: &Category, file: &File) -> f64 {
    let file_name = file.name.replace(publication_path, "");
    let file_path = Path::new(&file_name);
    let highest_score = file_path
        .iter()
        .fold(0_f64, |current_highest_score, current| {
            current
                .to_str()
                .map(|current_component| {
                    let score =
                        strsim::normalized_damerau_levenshtein(&category.name, current_component);
                    if score > current_highest_score {
                        return score;
                    }

                    current_highest_score
                })
                .unwrap_or(0_f64)
        });
    highest_score
}
