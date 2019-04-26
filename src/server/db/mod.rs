use diesel::prelude::*;
use r2d2::Pool;
use r2d2_diesel::ConnectionManager;

pub mod author;
pub mod category;
pub mod executor;
pub mod media_type;
pub mod migration;
pub mod publication;
pub mod publication_category;
pub mod setting;
pub mod tag;

pub fn create_db_pool(database_url: &str) -> Pool<ConnectionManager<SqliteConnection>> {
    let manager = ConnectionManager::<SqliteConnection>::new(database_url);
    Pool::builder()
        .build(manager)
        .expect("Failed to create pool.")
}
