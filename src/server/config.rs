use dotenv::dotenv;
use std::env;

#[derive(Debug)]
pub struct Config {
    pub publication_path: String,
}

pub fn get_config() -> Config {
    dotenv().ok();
    Config {
        publication_path: env::var("PUBLICATION_PATH").expect("PUBLICATION_PATH must be set"),
    }
}
