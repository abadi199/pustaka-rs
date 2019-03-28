use dotenv::dotenv;
use std::env;

#[derive(Debug, Clone)]
pub struct Config {
    pub database: String,
    pub publication_path: String,
    pub pustaka_home: String,
}

pub fn get_config() -> Config {
    dotenv().ok();
    Config {
        database: env::var("PUSTAKA_DATABASE_URL").unwrap_or("pustaka.db".to_string()),
        publication_path: env::var("PUSTAKA_PUBLICATION_PATH")
            .expect("Please set PUSTAKA_PUBLICATION_PATH environment"),
        pustaka_home: env::var("PUSTAKA_HOME").unwrap_or("".to_string()),
    }
}
