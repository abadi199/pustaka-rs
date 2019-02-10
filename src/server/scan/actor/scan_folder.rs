use actix::prelude::*;
use config;
use scan::actor::msg::ScanFolder;
use scan::actor::scanner::{File, Scanner};
use scan::error::ScannerError;
use walkdir::DirEntry;
use walkdir::WalkDir;

fn ignore_dotfile(dir: &DirEntry) -> bool {
    !dir.file_name().to_str().unwrap_or("").starts_with(".")
}

fn accept_file(dir: &DirEntry) -> bool {
    dir.file_type().is_file()
}

impl Handler<ScanFolder> for Scanner {
    type Result = Result<Vec<File>, ScannerError>;

    fn handle(&mut self, _msg: ScanFolder, _: &mut Self::Context) -> Self::Result {
        let config = config::get_config();
        Ok(WalkDir::new(&config.publication_path)
            .into_iter()
            .filter_map(|e| e.ok())
            .filter(accept_file)
            .filter(ignore_dotfile)
            .map(|dir| File::from(&dir))
            .collect())
    }
}
