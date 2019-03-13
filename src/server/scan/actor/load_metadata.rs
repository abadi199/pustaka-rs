use actix::prelude::*;
use actix_web::client;
use models::{CategoryId, NewPublication};
use scan::actor::{File, Scanner};
use scan::error::ScannerError;

pub struct LoadMetadata {
    pub file: File,
    pub category_id: CategoryId,
}

impl Message for LoadMetadata {
    type Result = Result<(NewPublication, CategoryId), ScannerError>;
}

impl Handler<LoadMetadata> for Scanner {
    type Result = Result<(NewPublication, CategoryId), ScannerError>;

    fn handle(&mut self, msg: LoadMetadata, _: &mut Self::Context) -> Self::Result {
        let file = msg.file;
        let category_id = msg.category_id;
        let publication = NewPublication {
            isbn: "".to_string(),
            title: file.name.clone(),
            media_type_id: 1,
            media_format: file.extension.clone(),
            author_id: 1,
            thumbnail: None,
            file: file.path.clone(),
        };

        Ok((publication, category_id))
    }
}
