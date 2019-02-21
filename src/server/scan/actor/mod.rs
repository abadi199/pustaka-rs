use actix::prelude::*;
use models;
use walkdir::DirEntry;

pub mod load_metadata;
pub mod process_file;
pub mod scan_folder;

#[derive(Debug, Clone, Copy)]
pub struct Scanner;

impl Actor for Scanner {
    type Context = SyncContext<Self>;
}
pub type CategoryId = i32;
#[derive(Debug, Clone)]
pub struct Category {
    pub id: CategoryId,
    pub name: String,
}

impl Category {
    pub fn from(category: &models::Category) -> Self {
        Self {
            id: category.id,
            name: category.name.clone(),
        }
    }
}

pub type FileId = i32;
#[derive(Debug, Clone)]
pub struct File {
    pub name: String,
    pub extension: String,
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
        }
    }
}
