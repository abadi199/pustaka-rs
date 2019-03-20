use custom_error::custom_error;
use image::{imageops, GenericImageView};
use std::path::PathBuf;

const THUMBNAIL_LOCATION: &str = "thumbnail";

custom_error! {pub ThumbnailError
    Image{ source: image::ImageError} = "Unable to process image",
    Io{ source: std::io::Error} = "Unable to access thumbnail file",
}

pub fn generate_thumbnail_location(home_path: &str, publication_id: i32) -> PathBuf {
    let mut thumbnail_location = PathBuf::from(home_path.clone());
    thumbnail_location.push(THUMBNAIL_LOCATION);
    thumbnail_location.push(publication_id.to_string());

    thumbnail_location
}

pub fn resize(file: &str) -> Result<String, ThumbnailError> {
    let img = image::open(file)?;
    let height = img.height();
    let width = img.width();
    let nheight = 300;
    let nwidth = nheight * width / height;
    imageops::resize(&img, nwidth, nheight, image::FilterType::CatmullRom).save(file)?;
    Ok(file.to_string())
}
