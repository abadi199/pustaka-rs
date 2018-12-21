use actix_web::ResponseError;
use epub::doc::EpubDoc;
use models::Publication;
use reader::models::Data;
use std::error::Error;
use std::fmt;

#[derive(Debug)]
pub enum EpubError {
    EpubError,
    PageError,
    PageNotFound,
    GenericError(String),
}

impl fmt::Display for EpubError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            EpubError::EpubError => write!(f, "EpubError"),
            EpubError::PageError => write!(f, "PageError"),
            EpubError::PageNotFound => write!(f, "PageNotFound"),
            EpubError::GenericError(err) => write!(f, "GenericError: {}", &err),
        }
    }
}

impl Error for EpubError {}

impl ResponseError for EpubError {}

pub fn open(the_publication: &Publication) -> Result<Data, EpubError> {
    let doc = EpubDoc::new(&the_publication.file).map_err(|e| EpubError::EpubError)?;
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
    })
}

pub fn page(the_publication: &Publication, page_number: usize) -> Result<String, EpubError> {
    // use reader::epub::EpubError::*;

    // let mut open_archive = Archive::new(the_publication.file.clone())
    //     .extract_to(EXTRACT_LOCATION.to_string())
    //     .map_err(|_err| RarError)?;

    // match open_archive.nth(page_number) {
    //     Some(item) => match item {
    //         Ok(entry) => Ok(format!("{}/{}", EXTRACT_LOCATION, entry.filename)),
    //         Err(_err) => Err(PageError),
    //     },
    //     None => Err(PageNotFound),
    // }
    Err(EpubError::GenericError("Not Implemented".to_string()))
}
