use actix_web::{fs::NamedFile, ResponseError};
use epub::doc::EpubDoc;
use models::Publication;
use reader::models::Data;
use std::{
    convert::From,
    error::Error,
    fmt,
    path::{Path, PathBuf},
};
use unzip;
use zip::result::ZipError;

#[derive(Debug)]
pub enum EpubError {
    EpubError(failure::Error),
    PageError,
    PageNotFound,
    FileNotFound,
    ZipError(ZipError),
    GenericError(String),
}

impl From<failure::Error> for EpubError {
    fn from(error: failure::Error) -> Self {
        EpubError::EpubError(error)
    }
}

impl fmt::Display for EpubError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            EpubError::EpubError(err) => write!(f, "EpubError: {}", err),
            EpubError::PageError => write!(f, "PageError"),
            EpubError::PageNotFound => write!(f, "PageNotFound"),
            EpubError::FileNotFound => write!(f, "FileNotFound"),
            EpubError::ZipError(err) => write!(f, "ZipError: {:?}", err),
            EpubError::GenericError(err) => write!(f, "GenericError: {}", &err),
        }
    }
}

impl Error for EpubError {}

impl ResponseError for EpubError {}

pub fn open(the_publication: &Publication) -> Result<Data, EpubError> {
    let doc = EpubDoc::new(&the_publication.file)?;
    println!("{:?}", doc.get_num_pages());
    Ok(Data {
        id: the_publication.id,
        isbn: the_publication.isbn.clone(),
        title: the_publication.title.clone(),
        media_type_id: the_publication.media_type_id,
        author_id: the_publication.author_id,
        thumbnail_url: the_publication.thumbnail_url().clone(),
        file: the_publication.file.clone(),
        total_pages: doc.get_num_pages(),
        media_format: the_publication.media_format.clone(),
    })
}

pub fn page(the_publication: &Publication, page_number: usize) -> Result<String, EpubError> {
    let mut doc = EpubDoc::new(&the_publication.file)?;
    doc.set_current_page(page_number)?;
    doc.get_current_str().map_err(|e| EpubError::EpubError(e))
}

const EXTRACT_LOCATION: &str = "/home/abadi199/Temp/test";

pub fn file(the_publication: &Publication, path: PathBuf) -> Result<NamedFile, EpubError> {
    println!("epub::file {:?}", path);
    let extract_location = &format!("{}/{}", EXTRACT_LOCATION, the_publication.id.to_string());
    let mut filepath = PathBuf::from(extract_location);
    filepath.push(path);
    if !filepath.exists() {
        unzip::unzip(&the_publication.file, extract_location)
            .map_err(|err| EpubError::ZipError(err))?;
    }

    NamedFile::open(filepath).map_err(|_| EpubError::FileNotFound)
}
