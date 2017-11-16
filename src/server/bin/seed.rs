extern crate diesel;
extern crate pustaka_lib;

use diesel::prelude::*;
use pustaka_lib::*;
use pustaka_lib::models::*;

fn main() {
    let connection = create_db_pool().get().unwrap();

    category(&*connection);
    media_type(&*connection);
    author(&*connection);
    publication(&*connection);
}

fn category(connection: &SqliteConnection) {
    use schema::category::dsl::category;

    diesel::delete(category)
        .execute(&*connection)
        .expect("Error deleting categories");
    diesel::insert(&NewCategory {
        name: "Fiction".to_string(),
        parent_id: None,
    }).into(category)
        .execute(&*connection)
        .expect("Error inserting category");
}

fn media_type(connection: &SqliteConnection) {
    use schema::media_type::dsl::media_type;

    diesel::delete(media_type)
        .execute(&*connection)
        .expect("Error deleting media_types");
    diesel::insert(&NewMediaType {
        name: "ebook".to_string(),
    }).into(media_type)
        .execute(&*connection)
        .expect("Error inserting media_type");
}

fn author(connection: &SqliteConnection) {
    use schema::author::dsl::author;

    diesel::delete(author)
        .execute(&*connection)
        .expect("Error deleting authors");
}

fn publication(connection: &SqliteConnection) {
    use schema::publication::dsl::publication;

    diesel::delete(publication)
        .execute(&*connection)
        .expect("Error deleting publication");
}
