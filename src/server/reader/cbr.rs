use models::Publication;
use reader::models::Data;
use unrar::archive::OpenArchive;
use unrar::error::UnrarError;
use unrar::Archive;

#[derive(Debug)]
pub enum CbrError {
    RarError(UnrarError<OpenArchive>),
    GenericError(String),
}

pub fn read(the_publication: &Publication) -> Result<Data, CbrError> {
    use reader::cbr::CbrError::RarError;

    let open_archive = Archive::new(the_publication.file.clone())
        .extract_to("/home/abadi199/Temp/test".to_string())
        .map_err(|err| RarError(err))?;

    let pages = open_archive.map(|f| {
        println!("content: {:?}", f);
    });

    Ok(Data {
        id: the_publication.id,
        isbn: the_publication.isbn.clone(),
        title: the_publication.title.clone(),
        media_type_id: the_publication.media_type_id,
        author_id: the_publication.author_id,
        thumbnail_url: the_publication.thumbnail.clone(),
        file: the_publication.file.clone(),
        total_pages: pages.count(),
    })
}
