use actix::prelude::*;
use scan::actor::scanner::{Category, File};
use scan::error::ScannerError;

#[derive(Debug, Clone)]
pub struct ScanFolder;
impl Message for ScanFolder {
    type Result = Result<Vec<File>, ScannerError>;
}

#[derive(Debug, Clone)]
pub struct ProcessFile {
    pub categories: Vec<Category>,
    pub file: File,
}
impl Message for ProcessFile {
    type Result = Result<(), ScannerError>;
}
