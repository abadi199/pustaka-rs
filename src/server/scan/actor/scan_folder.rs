use actix::prelude::*;
use scan::actor::{File, Scanner};
use scan::error::ScannerError;
use std::collections::HashSet;
use walkdir::DirEntry;
use walkdir::WalkDir;

lazy_static! {
    static ref ACCEPTED_EXTENSIONS: HashSet<&'static str> = {
        let mut m = HashSet::new();
        m.insert("cbr");
        m.insert("cbz");
        m.insert("epub");
        m.insert("pdf");
        m
    };
}

#[derive(Debug, Clone)]
pub struct ScanFolder {
    pub publication_path: String,
}
impl Message for ScanFolder {
    type Result = Result<Vec<File>, ScannerError>;
}

impl Handler<ScanFolder> for Scanner {
    type Result = Result<Vec<File>, ScannerError>;

    fn handle(&mut self, msg: ScanFolder, _: &mut Self::Context) -> Self::Result {
        Ok(WalkDir::new(&msg.publication_path)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(is_accepted_file)
            .filter(ignore_dotfile)
            .map(|dir| File::from(&dir))
            .collect())
    }
}

fn ignore_dotfile(dir: &DirEntry) -> bool {
    !dir.file_name().to_str().unwrap_or("").starts_with(".")
}

fn is_accepted_file(dir: &DirEntry) -> bool {
    dir.file_type().is_file()
        && dir
            .path()
            .extension()
            .and_then(|ext| ext.to_str())
            .map(|ext| ACCEPTED_EXTENSIONS.contains(ext))
            .unwrap_or(false)
}
