use dotenv::dotenv;
use std::env;

#[derive(Debug)]
pub struct Config {
    pub database: String,
    pub publication_path: String,
}

pub fn get_config() -> Config {
    dotenv().ok();
    Config {
        database: env::var("DATABASE_URL").expect("DATABASE must be set in .env"),
        publication_path: env::var("PUBLICATION_PATH")
            .expect("PUBLICATION_PATH must be set in .env"),
    }
}
