extern crate pustaka;

use pustaka::config;
use std::fs;
use std::io;
use std::path::Path;

fn main() {
    let config = config::get_config();
    println!("Config: {:?}", config);
    let _ = scan_path(Path::new(&config.publication_path));
}

fn scan_path(publication_path: &Path) -> io::Result<()> {
    if publication_path.is_dir() {
        for entry in try!(fs::read_dir(publication_path)) {
            let entry_dir = entry?;
            let dir_path = entry_dir.path();
            let next_path = dir_path.as_path();
            if next_path.is_dir() {
                let _ = scan_path(next_path);
            } else {
                println!("{:?}", next_path);
            }
        }
    } else {
        println!("{:?}", publication_path);
    }
    Ok(())
}
