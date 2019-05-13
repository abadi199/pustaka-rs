use actix_web::{fs::NamedFile, ResponseError};
use config::Config;
use models::Publication;
use reader::models::Data;
use std::{convert::From, error::Error, fmt, path::PathBuf};
use unzip;
use zip::result::ZipError;

#[derive(Debug)]
pub enum PdfError {
    PdfError(failure::Error),
    PageError,
    PageNotFound,
    FileNotFound,
    ZipError(ZipError),
    GenericError(String),
}

impl From<failure::Error> for PdfError {
    fn from(error: failure::Error) -> Self {
        PdfError::PdfError(error)
    }
}

impl fmt::Display for PdfError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            PdfError::PdfError(err) => write!(f, "PdfError: {}", err),
            PdfError::PageError => write!(f, "PageError"),
            PdfError::PageNotFound => write!(f, "PageNotFound"),
            PdfError::FileNotFound => write!(f, "FileNotFound"),
            PdfError::ZipError(err) => write!(f, "ZipError: {:?}", err),
            PdfError::GenericError(err) => write!(f, "GenericError: {}", &err),
        }
    }
}

impl Error for PdfError {}

impl ResponseError for PdfError {}

pub fn open(the_publication: &Publication) -> Result<Data, PdfError> {
    Ok(Data {
        id: the_publication.id,
        isbn: the_publication.isbn.clone(),
        title: the_publication.title.clone(),
        media_type_id: the_publication.media_type_id,
        author_id: the_publication.author_id,
        has_thumbnail: the_publication.has_thumbnail().clone(),
        file: the_publication.file.clone(),
        total_pages: None,
        media_format: the_publication.media_format.clone(),
    })
}

pub fn page(_: &Publication, _: usize) -> Result<String, PdfError> {
    Err(PdfError::GenericError(
        "Reading page is not supported for PDF".to_string(),
    ))
}

const EXTRACT_LOCATION: &str = "cache";

pub fn file(
    config: &Config,
    the_publication: &Publication,
    path: PathBuf,
) -> Result<NamedFile, PdfError> {
    let mut extract_location = PathBuf::from(config.pustaka_home.clone());
    extract_location.push(EXTRACT_LOCATION);
    extract_location.push(the_publication.id.to_string());

    let mut filepath = PathBuf::from(extract_location.clone());
    filepath.push(path);

    if !filepath.exists() {
        let extract_location_str: &str = extract_location.to_str().ok_or(
            PdfError::GenericError("Unable to get extract location path".to_string()),
        )?;
        unzip::unzip(&the_publication.file, extract_location_str)
            .map_err(|err| PdfError::ZipError(err))?;
    }

    NamedFile::open(filepath).map_err(|_| PdfError::FileNotFound)
}
