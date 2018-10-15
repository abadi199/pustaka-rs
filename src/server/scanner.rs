extern crate actix;
extern crate pustaka;

use pustaka::config;
use std::fs;
use std::io;
use std::path::Path;

fn main() {
    let sys = actix::System::new("pustaka");
    let pool = pustaka::db::create_db_pool();

    let config = config::get_config();
    println!("Config: {:?}", config);
    let files = scan_path(config.publication_path);
    println!("{:?}", files);
}

fn scan_path(publication_path: String) -> io::Result<Vec<String>> {
    let path = Path::new(&publication_path);

    let files = &mut vec![];
    if path.is_dir() {
        for entry in try!(fs::read_dir(path)) {
            let entry_dir = entry?;
            let dir_path = entry_dir.path();
            let next_path = dir_path.as_path();
            let next_path_str = dir_path.to_str().unwrap_or_default().to_string();
            if next_path.is_dir() {
                let next_files = &mut scan_path(next_path_str)?;
                files.append(next_files);
            } else {
                files.push(next_path_str);
            }
        }
    } else {
        files.push(publication_path.clone());
    }
    Ok(files.to_vec())
}
