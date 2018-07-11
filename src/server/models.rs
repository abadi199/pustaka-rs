use schema::{author, category, media_type, publication, publication_category, tag};
use serde::ser::SerializeStruct;
use serde::Serialize;
use serde::Serializer;

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
    pub file: String,
}

#[derive(Identifiable, Debug, Queryable, Deserialize, Associations)]
#[belongs_to(MediaType, Author)]
#[table_name = "publication"]
pub struct Publication {
    pub id: i32,
    pub isbn: String,
    pub title: String,
    pub media_type_id: i32,
    pub author_id: i32,
    pub thumbnail: Option<String>,
    pub file: String,
}

impl Publication {
    pub fn thumbnail_url(&self) -> Option<String> {
        match self.thumbnail {
            Some(_) => Some(format!("/api/publication/thumbnail/{}", &self.id)),
            None => None,
        }
    }
}

impl Serialize for Publication {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        // 3 is the number of fields in the struct.
        let mut state = serializer.serialize_struct("Publication", 6)?;
        state.serialize_field("id", &self.id)?;
        state.serialize_field("isbn", &self.isbn)?;
        state.serialize_field("title", &self.title)?;
        state.serialize_field("media_type_id", &self.media_type_id)?;
        state.serialize_field("author_id", &self.author_id)?;
        match self.thumbnail_url() {
            Some(url) => state.serialize_field("thumbnail_url", &url)?,
            None => state.serialize_field("thumbnail_url", &self.thumbnail)?,
        }
        state.end()
    }
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
