table! {
    author (id) {
        id -> Integer,
        name -> Text,
    }
}

table! {
    category (id) {
        id -> Integer,
        name -> Text,
        parent_id -> Nullable<Integer>,
    }
}

table! {
    media_type (id) {
        id -> Integer,
        name -> Text,
    }
}

table! {
    publication (id) {
        id -> Integer,
        isbn -> Text,
        title -> Text,
        media_type -> Nullable<Integer>,
        author -> Integer,
    }
}

table! {
    publication_category (publication_id, category_id) {
        publication_id -> Integer,
        category_id -> Integer,
    }
}

joinable!(publication -> author (author));
joinable!(publication -> media_type (media_type));
joinable!(publication_category -> category (category_id));
joinable!(publication_category -> publication (publication_id));

allow_tables_to_appear_in_same_query!(
    author,
    category,
    media_type,
    publication,
    publication_category,
);
