use models::Publication;
use reader::models::Data;
use unrar::Archive;

#[derive(Debug)]
pub enum CbrError {
    RarError,
    PageError,
    PageNotFound,
    GenericError(String),
}

pub fn open(the_publication: &Publication) -> Result<Data, CbrError> {
    use reader::cbr::CbrError::*;

    let open_archive = Archive::new(the_publication.file.clone())
        .extract_to("/home/abadi199/Temp/test".to_string())
        .map_err(|_err| RarError)?;

    Ok(Data {
        id: the_publication.id,
        isbn: the_publication.isbn.clone(),
        title: the_publication.title.clone(),
        media_type_id: the_publication.media_type_id,
        author_id: the_publication.author_id,
        thumbnail_url: the_publication.thumbnail_url().clone(),
        file: the_publication.file.clone(),
        total_pages: open_archive.count(),
    })
}

pub fn page(the_publication: &Publication, page_number: usize) -> Result<String, CbrError> {
    use reader::cbr::CbrError::*;

    let mut open_archive = Archive::new(the_publication.file.clone())
        .extract_to("/home/abadi199/Temp/test".to_string())
        .map_err(|_err| RarError)?;

    match open_archive.nth(page_number) {
        Some(item) => match item {
            Ok(entry) => Ok(format!("/home/abadi199/Temp/test/{}", entry.filename)),
            Err(_err) => Err(PageError),
        },
        None => Err(PageNotFound),
    }
}
