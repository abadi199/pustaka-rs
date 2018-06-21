extern crate diesel;
extern crate pustaka;

use diesel::prelude::*;
use pustaka::models::*;
use pustaka::*;

fn main() {
    let connection = db::create_db_pool().get().unwrap();

    insert_category(&*connection);
    insert_media_type(&*connection);
    insert_author(&*connection);
    insert_publication(&*connection);
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

fn insert_publication(connection: &SqliteConnection) {
    use schema::publication::dsl::*;
    use schema::publication_category::dsl::publication_category;

    diesel::delete(publication_category)
        .execute(&*connection)
        .expect("Error deleting publication category");

    diesel::delete(publication)
        .execute(&*connection)
        .expect("Error deleting publication");

    // Book Types
    let book_type = get_media_type("book", connection).expect("Error getting Book type");

    // Categories
    let fiction_category =
        get_category("Fiction", connection).expect("Error getting Fiction category");
    let science_fiction_category =
        get_category("Science fiction", connection).unwrap_or(fiction_category);

    // Authors
    let unknown_author: Author =
        get_author("Unknown", connection).expect("Error getting Unknown author");
    let james_sa_corey = get_author("James S.A. Corey", connection).unwrap_or(unknown_author);

    // Publication
    let publications = vec![
        (
            NewPublication {
                isbn: "978-0-316-12908-4".to_string(),
                title: "Leviathan Wakes".to_string(),
                media_type_id: book_type.id,
                author_id: james_sa_corey.id,
            },
            science_fiction_category.id,
        ),
        (
            NewPublication {
                isbn: "978-1-84149-990-1".to_string(),
                title: "Caliban's War".to_string(),
                media_type_id: book_type.id,
                author_id: james_sa_corey.id,
            },
            science_fiction_category.id,
        ),
    ];

    for (the_publication, category_id) in publications {
        let the_isbn = &the_publication.isbn.clone();
        diesel::insert_into(publication)
            .values(the_publication)
            .execute(connection)
            .expect("Error inserting publication");
        match get_publication(the_isbn, connection) {
            Ok(new_publication) => {
                diesel::insert_into(publication_category)
                    .values(PublicationCategory {
                        publication_id: new_publication.id,
                        category_id: category_id,
                    })
                    .execute(connection)
                    .expect("Error inserting publication category");
            }
            Err(..) => {}
        }
    }

    fn get_publication(the_isbn: &str, connection: &SqliteConnection) -> QueryResult<Publication> {
        use schema::publication::dsl::*;
        publication
            .filter(isbn.eq(the_isbn))
            .first::<Publication>(connection)
    }

    fn get_category(the_name: &str, connection: &SqliteConnection) -> QueryResult<Category> {
        use schema::category::dsl::*;
        category
            .filter(name.eq(the_name))
            .first::<Category>(connection)
    }

    fn get_media_type(the_name: &str, connection: &SqliteConnection) -> QueryResult<MediaType> {
        use schema::media_type::dsl::*;
        media_type
            .filter(name.eq(the_name))
            .first::<MediaType>(connection)
    }

    fn get_author(the_name: &str, connection: &SqliteConnection) -> QueryResult<Author> {
        use schema::author::dsl::*;
        author.filter(name.eq(the_name)).first::<Author>(connection)
    }
}
