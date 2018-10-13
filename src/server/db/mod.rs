use diesel::prelude::*;
use dotenv::dotenv;
use r2d2::Pool;
use r2d2_diesel::ConnectionManager;
use std::env;

pub mod author;
pub mod category;
pub mod executor;
pub mod publication;

pub fn create_db_pool() -> Pool<ConnectionManager<SqliteConnection>> {
    dotenv().ok();

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    let manager = ConnectionManager::<SqliteConnection>::new(database_url);
    Pool::builder()
        .build(manager)
        .expect("Failed to create pool.")
}
