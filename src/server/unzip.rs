use std::{fs, fs::File, io, path::Path, path::PathBuf};
use zip::result::ZipResult;
use zip::ZipArchive;

pub fn unzip(file: &str, output_path_str: &str) -> ZipResult<()> {
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

    let mut files: Vec<String> = Vec::new();
    for i in 0..archive.len() {
        if let Some(mut zip_file) = archive.by_index(i).ok() {
            let file_name = zip_file.name();
            files.push(file_name.to_string());
        }
    }

    files.sort();
    let name = files.get(nth).ok_or(zip::result::ZipError::FileNotFound)?;

    internal_unzip_by_name(&mut archive, output_path, name)
}
fn internal_unzip_nth(
    archive: &mut ZipArchive<File>,
    output_path: &str,
    nth: usize,
) -> ZipResult<String> {
    // TODO : Better way to handle the when the first nth is a folder, we need to skip it.
    let mut file = archive.by_index(nth)?;
    let filepath = file.sanitized_name();
    let mut outpath = PathBuf::new();
    outpath.push(output_path);
    outpath.push(filepath);

    if (&*file.name()).ends_with('/') {
        return Err(zip::result::ZipError::FileNotFound);
    } else {
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

fn internal_unzip_by_name(
    archive: &mut ZipArchive<File>,
    output_path: &str,
    name: &str,
) -> ZipResult<String> {
    // TODO : Better way to handle the when the first nth is a folder, we need to skip it.
    let mut file = archive.by_name(name)?;
    let filepath = file.sanitized_name();
    let mut outpath = PathBuf::new();
    outpath.push(output_path);
    outpath.push(filepath);

    if (&*file.name()).ends_with('/') {
        return Err(zip::result::ZipError::FileNotFound);
    } else {
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
