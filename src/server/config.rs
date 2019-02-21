use dotenv::dotenv;
use std::env;

#[derive(Debug, Clone)]
pub struct Config {
    pub database: String,
    pub publication_path: String,
    pub pustaka_home: String,
    pub comicvine_api_key: Option<String>,
}

pub fn get_config() -> Config {
    dotenv().ok();
    Config {
        database: env::var("DATABASE_URL").expect("DATABASE must be set in .env"),
        publication_path: env::var("PUBLICATION_PATH")
            .expect("PUBLICATION_PATH must be set in .env"),
        pustaka_home: env::var("PUSTAKA_HOME").unwrap_or(".pustaka".to_string()),
        comicvine_api_key: env::var("COMICVINE_API_KEY").ok(),
    }
}
