use schema::{category, media_type, author, publication, publication_category};

#[derive(Debug, Insertable)]
#[table_name = "category"]
pub struct NewCategory {
    pub name: String,
    pub parent_id: Option<i32>,
}

#[derive(Debug, Queryable, Serialize, Deserialize)]
pub struct Category {
    pub id: i32,
    pub name: String,
    pub parent_id: Option<i32>,
}

#[derive(Debug, Insertable)]
#[table_name = "media_type"]
pub struct NewMediaType {
    pub name: String,
}

#[derive(Debug, Queryable)]
pub struct MediaType {
    pub id: i32,
    pub name: String,
}

#[derive(Debug, Insertable)]
#[table_name = "author"]
pub struct NewAuthor {
    pub name: String,
}

#[derive(Debug, Queryable)]
struct Author {
    pub id: i32,
    pub name: String,
}

#[derive(Debug, Insertable)]
#[table_name = "publication"]
pub struct NewPublication {
    pub isbn: String,
    pub title: String,
    pub media_type: i32,
    pub author: i32,
}

#[derive(Debug, Queryable)]
pub struct Publication {
    pub id: i32,
    pub isbn: String,
    pub title: String,
    pub media_type: i32,
    pub author: i32,
}
