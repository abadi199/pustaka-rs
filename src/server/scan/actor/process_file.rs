use actix::prelude::*;
use scan::actor::{Category, CategoryId, File, Scanner};
use scan::error::ScannerError;

#[derive(Debug, Clone)]
pub struct ProcessFile {
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
        let matched_category = process_category(&file, &categories)?;
        Ok((file, matched_category.id))
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
