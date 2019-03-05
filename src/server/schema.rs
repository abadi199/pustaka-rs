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
    favorite_category (category_id) {
        category_id -> Integer,
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
        media_type_id -> Integer,
        media_format -> Text,
        author_id -> Integer,
        thumbnail -> Nullable<Text>,
        file -> Text,
    }
}

table! {
    publication_category (publication_id, category_id) {
        publication_id -> Integer,
        category_id -> Integer,
    }
}

table! {
    publication_progress (publication_id) {
        publication_id -> Integer,
        progress -> Float,
    }
}

table! {
    publication_tag (publication_id, tag_id) {
        publication_id -> Integer,
        tag_id -> Integer,
    }
}

table! {
    tag (id) {
        id -> Integer,
        name -> Text,
    }
}

table! {
    user (id) {
        id -> Integer,
        username -> Text,
    }
}

joinable!(favorite_category -> category (category_id));
joinable!(publication -> author (author_id));
joinable!(publication -> media_type (media_type_id));
joinable!(publication_category -> category (category_id));
joinable!(publication_category -> publication (publication_id));
joinable!(publication_progress -> publication (publication_id));
joinable!(publication_tag -> publication (publication_id));
joinable!(publication_tag -> tag (tag_id));

allow_tables_to_appear_in_same_query!(
    author,
    category,
    favorite_category,
    media_type,
    publication,
    publication_category,
    publication_progress,
    publication_tag,
    tag,
    user,
);
