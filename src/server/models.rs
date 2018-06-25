use schema::{author, category, media_type, publication, publication_category, tag};

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "category"]
pub struct NewCategory {
    pub name: String,
    pub parent_id: Option<i32>,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, AsChangeset)]
#[table_name = "category"]
pub struct Category {
    pub id: i32,
    pub name: String,
    pub parent_id: Option<i32>,
}

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "media_type"]
pub struct NewMediaType {
    pub name: String,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, AsChangeset)]
#[table_name = "media_type"]
pub struct MediaType {
    pub id: i32,
    pub name: String,
}

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "author"]
pub struct NewAuthor {
    pub name: String,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, AsChangeset)]
#[table_name = "author"]
pub struct Author {
    pub id: i32,
    pub name: String,
}

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "publication"]
pub struct NewPublication {
    pub isbn: String,
    pub title: String,
    pub media_type_id: i32,
    pub author_id: i32,
    pub thumbnail: Option<String>,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, Associations)]
#[belongs_to(MediaType, Author)]
#[table_name = "publication"]
pub struct Publication {
    pub id: i32,
    pub isbn: String,
    pub title: String,
    pub media_type_id: i32,
    pub author_id: i32,
    pub thumbnail: Option<String>,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, Associations, Insertable)]
#[belongs_to(Category, foreign_key = "category_id")]
#[table_name = "publication_category"]
#[primary_key(publication_id, category_id)]
pub struct PublicationCategory {
    pub publication_id: i32,
    pub category_id: i32,
}

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "tag"]
pub struct NewTag {
    pub name: String,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, AsChangeset)]
#[table_name = "tag"]
pub struct Tag {
    pub id: i32,
    pub name: String,
}
