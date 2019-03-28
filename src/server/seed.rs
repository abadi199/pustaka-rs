extern crate csv;
extern crate diesel;
extern crate pustaka;
extern crate serde_derive;

use diesel::prelude::*;
use pustaka::models::*;
use pustaka::*;

fn main() {
    let config = pustaka::config::get_config();
    let connection = db::create_db_pool(&config.database).get().unwrap();
    insert_category(&*connection);
    insert_media_type(&*connection);
    insert_author(&*connection);
    insert_favorite_category(&*connection);
}

fn insert_favorite_category(connection: &SqliteConnection) {
    use schema::favorite_category::dsl::*;

    diesel::delete(favorite_category)
        .execute(&*connection)
        .expect("Error deleting favorite categories");

    let favorites = vec![
        "Comics/Graphic novel".to_string(),
        "Fantasy".to_string(),
        "Science fiction".to_string(),
        "Programming".to_string(),
        "Picture book".to_string(),
    ];

    for favorite_category_name in favorites {
        let category =
            get_category(&favorite_category_name, connection).expect("Error getting category");

        diesel::insert_into(favorite_category)
            .values(&FavoriteCategory {
                category_id: category.id,
            })
            .execute(connection)
            .expect("Error inserting category");
    }
}

fn insert_category(connection: &SqliteConnection) {
    use schema::category::dsl::*;

    diesel::delete(category)
        .execute(&*connection)
        .expect("Error deleting categories");

    let categories = vec!["Fiction".to_string(), "Non Fiction".to_string()];
    for category_name in categories {
        diesel::insert_into(category)
            .values(&NewCategory {
                name: category_name,
                parent_id: None,
            })
            .execute(connection)
            .expect("Error inserting category");
    }

    let fiction: Category = category
        .filter(name.eq("Fiction"))
        .first(connection)
        .expect("Error finding Fiction id");

    let non_fiction: Category = category
        .filter(name.eq("Non Fiction"))
        .first(connection)
        .expect("Error finding Non Fiction id");

    let fictions = vec![
        "Classic".to_string(),
        "Comics/Graphic novel".to_string(),
        "Crime/detective".to_string(),
        "Fable".to_string(),
        "Fairy tale".to_string(),
        "Fan fiction".to_string(),
        "Fantasy".to_string(),
        "Folklore".to_string(),
        "Historical fiction".to_string(),
        "Horror".to_string(),
        "Humor".to_string(),
        "Legend".to_string(),
        "Magical realism".to_string(),
        "Meta fiction".to_string(),
        "Mystery".to_string(),
        "Mythology".to_string(),
        "Mythopoeia".to_string(),
        "Picture book".to_string(),
        "Realistic fiction".to_string(),
        "Science fiction".to_string(),
        "Short story".to_string(),
        "Suspense/thriller".to_string(),
        "Tall tale".to_string(),
        "Western".to_string(),
    ];
    for category_name in fictions {
        diesel::insert_into(category)
            .values(&NewCategory {
                name: category_name,
                parent_id: Some(fiction.id),
            })
            .execute(connection)
            .expect("Error inserting category");
    }

    let non_fictions = vec![
        "Biography".to_string(),
        "Essay".to_string(),
        "Owner's Manual".to_string(),
        "Journalism".to_string(),
        "Lab Report".to_string(),
        "Memoir".to_string(),
        "Narrative nonfiction".to_string(),
        "Reference book".to_string(),
        "Self-help book".to_string(),
        "Speech".to_string(),
        "Textbook".to_string(),
        "Programming".to_string(),
    ];
    for category_name in non_fictions {
        diesel::insert_into(category)
            .values(&NewCategory {
                name: category_name,
                parent_id: Some(non_fiction.id),
            })
            .execute(connection)
            .expect("Error inserting category");
    }
}

fn insert_media_type(connection: &SqliteConnection) {
    use schema::media_type::dsl::media_type;

    diesel::delete(media_type)
        .execute(&*connection)
        .expect("Error deleting media_types");
    let media_types = vec![
        "ebook".to_string(),
        "comic".to_string(),
        "magazine".to_string(),
        "audiobook".to_string(),
        "manga".to_string(),
        "paperback".to_string(),
        "hardcover".to_string(),
    ];
    for name in media_types {
        diesel::insert_into(media_type)
            .values(&NewMediaType { name: name })
            .execute(connection)
            .expect("Error inserting media_type");
    }
}

fn insert_author(connection: &SqliteConnection) {
    use schema::author::dsl::author;

    diesel::delete(author)
        .execute(&*connection)
        .expect("Error deleting authors");

    let authors = vec![
        "Unknown".to_string(),
        "Richard Feldman".to_string(),
        "J.K. Rowling".to_string(),
        "James S.A. Corey".to_string(),
    ];
    for name in authors {
        diesel::insert_into(author)
            .values(&NewAuthor { name: name })
            .execute(connection)
            .expect("Error inserting author");
    }
}

fn get_category(the_name: &str, connection: &SqliteConnection) -> QueryResult<Category> {
    use schema::category::dsl::*;
    category
        .filter(name.eq(the_name))
        .first::<Category>(connection)
}
