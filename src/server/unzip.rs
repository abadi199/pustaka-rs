use std::{fs, fs::File, io, path::Path, path::PathBuf};
use zip::result::ZipResult;
use zip::ZipArchive;

pub fn unzip(file: &str, output_path_str: &str) -> ZipResult<()> {
    println!("Unzipping {} to {}", file, output_path_str);
    let fname = Path::new(file);
    let file = File::open(&fname)?;
    let mut archive = ZipArchive::new(file)?;

    for i in 0..archive.len() {
        internal_unzip_nth(&mut archive, output_path_str, i)?;
    }

    Ok(())
}

pub fn count(file: &str) -> ZipResult<usize> {
    let fname = Path::new(file);
    let file = File::open(&fname)?;
    let archive = ZipArchive::new(file)?;
    Ok(archive.len())
}

pub fn unzip_nth(file: &str, output_path: &str, nth: usize) -> ZipResult<String> {
    let fname = Path::new(file);
    let file = File::open(&fname)?;
    let mut archive = ZipArchive::new(file)?;

    internal_unzip_nth(&mut archive, output_path, nth)
}

fn internal_unzip_nth(
    archive: &mut ZipArchive<File>,
    output_path: &str,
    nth: usize,
) -> ZipResult<String> {
    // TODO : Better way to handle the when the first nth is a folder, we need to skip it.
    let mut file = archive.by_index(nth + 1)?;
    let filepath = file.sanitized_name();
    let mut outpath = PathBuf::new();
    outpath.push(output_path);
    outpath.push(filepath);
    println!("internal_unzip_nth::outpath:{:?}", outpath);

    if (&*file.name()).ends_with('/') {
        return Err(zip::result::ZipError::FileNotFound);
    } else {
        println!(
            "File {} extracted to \"{}\" ({} bytes)",
            nth,
            outpath.as_path().display(),
            file.size()
        );
        if let Some(p) = outpath.parent() {
            if !p.exists() {
                fs::create_dir_all(&p).unwrap();
            }
        }
        let mut outfile = fs::File::create(&outpath).unwrap();
        io::copy(&mut file, &mut outfile).unwrap();
    }

    // Get and Set permissions
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;

        if let Some(mode) = file.unix_mode() {
            fs::set_permissions(&outpath, fs::Permissions::from_mode(mode)).unwrap();
        }
    }

    let outpath_str = outpath
        .to_str()
        .ok_or(zip::result::ZipError::FileNotFound)?;
    Ok(outpath_str.to_string())
}
