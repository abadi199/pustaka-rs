use std::path::PathBuf;

const THUMBNAIL_LOCATION: &str = "thumbnail";

pub fn generate_thumbnail_location(home_path: &str, publication_id: i32) -> PathBuf {
    let mut thumbnail_location = PathBuf::from(home_path.clone());
    thumbnail_location.push(THUMBNAIL_LOCATION);
    thumbnail_location.push(publication_id.to_string());

    thumbnail_location
}
