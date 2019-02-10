use actix::prelude::*;
use config;
use scan::error::ScannerError;
use walkdir::WalkDir;

pub struct Scanner;

impl Actor for Scanner {
    type Context = SyncContext<Self>;
}

pub struct Scan;
impl Message for Scan {
    type Result = Result<Vec<File>, ScannerError>;
}

impl Handler<Scan> for Scanner {
    type Result = Result<Vec<File>, ScannerError>;

    fn handle(&mut self, _msg: Scan, _: &mut Self::Context) -> Self::Result {
        let config = config::get_config();
        Ok(WalkDir::new(&config.publication_path)
            .into_iter()
            .filter_map(|e| e.ok())
            .map(|dir| File { name: dir.name })
            .collect())
    }
}

pub struct Category {
    pub id: i32,
    pub name: String,
}

pub struct File {
    pub name: String,
}

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
        Ok(())
    }
}
