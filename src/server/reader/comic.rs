use actix_web::ResponseError;
use config::Config;
use models::{Publication, CBR, CBZ};
use reader::models::Data;
use std::error::Error;
use std::fmt;
use std::io;
use std::path::{Path, PathBuf};
use unrar::Archive;
use unzip;

#[derive(Debug)]
pub enum ComicError {
    RarError,
    ZipError,
    PageError,
    PageNotFound,
    IOError(io::Error),
    InvalidMediaFormatError,
    GenericError(String),
}

impl fmt::Display for ComicError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            ComicError::RarError => write!(f, "RarError"),
            ComicError::ZipError => write!(f, "ZipError"),
            ComicError::PageError => write!(f, "PageError"),
            ComicError::PageNotFound => write!(f, "PageNotFound"),
            ComicError::InvalidMediaFormatError => write!(f, "InvalidMediaFormatError"),
            ComicError::IOError(err) => write!(f, "IOError: {:?}", err),
            ComicError::GenericError(err) => write!(f, "GenericError: {}", &err),
        }
    }
}

impl Error for ComicError {}

impl ResponseError for ComicError {}

const EXTRACT_LOCATION: &str = "cache";

pub fn open(the_publication: &Publication) -> Result<Data, ComicError> {
    use reader::comic::ComicError::*;

    let open_archive = Archive::new(the_publication.file.clone())
        .extract_to(EXTRACT_LOCATION.to_string())
        .map_err(|_err| RarError);

    Ok(Data {
        id: the_publication.id,
        isbn: the_publication.isbn.clone(),
        title: the_publication.title.clone(),
        media_type_id: the_publication.media_type_id,
        author_id: the_publication.author_id,
        thumbnail_url: the_publication.thumbnail_url().clone(),
        file: the_publication.file.clone(),
        media_format: the_publication.media_format.clone(),
        total_pages: open_archive.map(|comic| comic.count()).unwrap_or(0),
    })
}

pub fn page(
    config: &Config,
    the_publication: &Publication,
    page_number: usize,
) -> Result<String, ComicError> {
    let mut extract_location = PathBuf::from(config.pustaka_home.clone());
    extract_location.push(EXTRACT_LOCATION);
    extract_location.push(the_publication.id.to_string());

    let extract_location = extract_location.to_str().ok_or(ComicError::GenericError(
        "Unable to get extract location path".to_string(),
    ))?;

    match the_publication.media_format.as_ref() {
        CBR => page_cbr(the_publication, page_number, extract_location),
        CBZ => page_cbz(the_publication, page_number, extract_location),
        _ => Err(ComicError::InvalidMediaFormatError),
    }
}

fn page_cbz(
    publication: &Publication,
    page_number: usize,
    extract_location: &str,
) -> Result<String, ComicError> {
    unzip::unzip_nth(&publication.file, extract_location, page_number)
        .map_err(|_| ComicError::ZipError)
    // Path::new(extract_location)
    //     .read_dir()
    //     .ok()
    //     .and_then(|mut read_dir| read_dir.nth(page_number))
    //     .and_then(|result| result.ok())
    //     .map(|dir_entry| dir_entry.file_name())
    //     .and_then(|os_string| {
    //         os_string
    //             .as_os_str()
    //             .to_str()
    //             .map(|file_name| file_name.to_string())
    //     })
    //     .ok_or(ComicError::PageError)
    //     .or_else(|_| {
    //         unzip::unzip_nth(&publication.file, extract_location, page_number)
    //             .map_err(|_| ComicError::ZipError)
    //     })
}

fn page_cbr(
    the_publication: &Publication,
    page_number: usize,
    extract_location: &str,
) -> Result<String, ComicError> {
    use reader::comic::ComicError::*;
    let mut open_archive = Archive::new(the_publication.file.clone())
        .extract_to(extract_location.to_string())
        .map_err(|_err| RarError)?;

    match open_archive.nth(page_number) {
        Some(item) => match item {
            Ok(entry) => Ok(format!("{}/{}", EXTRACT_LOCATION, entry.filename)),
            Err(_err) => Err(PageError),
        },
        None => Err(PageNotFound),
    }
}
