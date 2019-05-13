use actix::prelude::*;
use config::Config;
use fs::thumbnail;
use models::{CategoryId, Publication, CBR, CBZ, EPUB, PDF};
use reader::comic;
use scan::actor::Scanner;
use scan::error::ScannerError;

pub struct LoadMetadata {
    pub config: Config,
    pub publication: Publication,
    pub category_id: CategoryId,
}

impl Message for LoadMetadata {
    type Result = Result<(Publication, CategoryId), ScannerError>;
}

impl Handler<LoadMetadata> for Scanner {
    type Result = Result<(Publication, CategoryId), ScannerError>;

    fn handle(&mut self, msg: LoadMetadata, _: &mut Self::Context) -> Self::Result {
        let publication = msg.publication;
        let thumbnail = get_thumbnail(&msg.config, &publication);
        let updated_publication = Publication {
            thumbnail,
            ..publication
        };
        Ok((updated_publication, msg.category_id))
    }
}

fn get_thumbnail(config: &Config, publication: &Publication) -> Option<String> {
    match publication.media_format.as_ref() {
        CBR => get_thumbnail_cbr(config, publication),
        CBZ => get_thumbnail_cbz(config, publication),
        EPUB => None,
        PDF => None,
        _ => None,
    }
}

fn get_thumbnail_cbr(config: &Config, publication: &Publication) -> Option<String> {
    let thumbnail_location =
        thumbnail::generate_thumbnail_location(&config.pustaka_home, publication.id);
    let thumbnail_location = thumbnail_location.to_str()?;
    let thumbnail_path = comic::page_cbr(&publication.file, 0, thumbnail_location).ok();
    match thumbnail_path {
        Some(thumbnail_path) => thumbnail::resize(&thumbnail_path).ok(),
        None => None,
    }
}

fn get_thumbnail_cbz(config: &Config, publication: &Publication) -> Option<String> {
    let thumbnail_location =
        thumbnail::generate_thumbnail_location(&config.pustaka_home, publication.id);
    let thumbnail_location = thumbnail_location.to_str()?;
    let thumbnail_path = comic::page_cbz(&publication.file, 0, thumbnail_location).ok();
    match thumbnail_path {
        Some(thumbnail_path) => thumbnail::resize(&thumbnail_path).ok(),
        None => None,
    }
}
