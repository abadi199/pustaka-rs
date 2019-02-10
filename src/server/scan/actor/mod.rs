use actix::prelude::*;
use config;
use models;
use scan::error::ScannerError;
use std::boxed::Box;
use walkdir::DirEntry;
use walkdir::WalkDir;

pub mod actor;
pub mod msg;
pub mod process_file;
pub mod scan_folder;

#[derive(Debug, Clone)]
pub struct Scanner;

impl Actor for Scanner {
    type Context = SyncContext<Self>;
}

#[derive(Debug, Clone)]
pub struct Category {
    pub id: i32,
    pub name: String,
}

impl Category {
    pub fn from(category: &models::Category) -> Self {
        Self {
            id: category.id.clone(),
            name: category.name.clone(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct File {
    pub name: String,
    pub extension: String,
    pub components: Vec<String>,
}
impl File {
    pub fn from(dir: &DirEntry) -> Self {
        Self {
            name: dir.path().to_str().unwrap_or("").to_string(),
            extension: dir
                .path()
                .extension()
                .and_then(|s| s.to_str())
                .unwrap_or("")
                .to_string(),
            components: dir
                .path()
                .iter()
                .filter_map(|c| c.to_str())
                .map(|c| c.to_string())
                .collect(),
        }
    }
}
