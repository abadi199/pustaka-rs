extern crate diesel;
extern crate pustaka;

use diesel::prelude::*;
use pustaka::*;
use pustaka::models::*;

fn main() {
    let connection = db::create_db_pool().get().unwrap();

    category(&*connection);
    media_type(&*connection);
    author(&*connection);
    publication(&*connection);
}

fn category(connection: &SqliteConnection) {
    use schema::category::dsl::category;

    diesel::delete(category).execute(&*connection).expect(
        "Error deleting categories",
    );

    let categories = vec!["Fiction".to_string(), "Non Fiction".to_string()];
    for name in categories {
        diesel::insert_into(category)
            .values(&NewCategory {
                name: name,
                parent_id: None,
            })
            .execute(connection)
            .expect("Error inserting category");
    }
}

fn media_type(connection: &SqliteConnection) {
    use schema::media_type::dsl::media_type;

    diesel::delete(media_type).execute(&*connection).expect(
        "Error deleting media_types",
    );
    let media_types = vec![
        "book".to_string(),
        "comic".to_string(),
        "magazine".to_string(),
        "audiobook".to_string(),
        "manga".to_string(),
        "hardcopy".to_string(),
    ];
    for name in media_types {
        diesel::insert_into(media_type)
            .values(&NewMediaType { name: name })
            .execute(connection)
            .expect("Error inserting media_type");
    }

}

fn author(connection: &SqliteConnection) {
    use schema::author::dsl::author;

    diesel::delete(author).execute(&*connection).expect(
        "Error deleting authors",
    );
}


fn publication(connection: &SqliteConnection) {
    use schema::publication::dsl::publication;

    diesel::delete(publication).execute(&*connection).expect(
        "Error deleting publication",
    );
}
