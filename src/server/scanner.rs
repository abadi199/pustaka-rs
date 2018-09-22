extern crate pustaka;

use pustaka::config;
use std::fs;
use std::path::Path;

fn main() {
    let config = config::get_config();
    println!("Config: {:?}", config);

    let path = Path::new(&config.publication_path);
    for entry in fs::read_dir(path)? {
        let entry = entry;
        println!("{:?}", entry.path());
    }
}
