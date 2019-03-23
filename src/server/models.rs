use schema::{
    author, category, favorite_category, media_type, publication, publication_category,
    publication_progress, recent_publication, tag,
};
use serde::ser::SerializeStruct;
use serde::Serialize;
use serde::Serializer;

pub const CBR: &str = "cbr";
pub const CBZ: &str = "cbz";
pub const EPUB: &str = "epub";

pub type CategoryId = i32;

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "category"]
pub struct NewCategory {
    pub name: String,
    pub parent_id: Option<i32>,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, AsChangeset, Clone)]
#[table_name = "category"]
pub struct Category {
    pub id: CategoryId,
    pub name: String,
    pub parent_id: Option<i32>,
}

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "media_type"]
pub struct NewMediaType {
    pub name: String,
}

pub type MediaTypeId = i32;

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, AsChangeset)]
#[table_name = "media_type"]
pub struct MediaType {
    pub id: MediaTypeId,
    pub name: String,
}

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "author"]
pub struct NewAuthor {
    pub name: String,
}

pub type AuthorId = i32;

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, AsChangeset)]
#[table_name = "author"]
pub struct Author {
    pub id: AuthorId,
    pub name: String,
}

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "publication"]
pub struct NewPublication {
    pub isbn: String,
    pub title: String,
    pub media_type_id: i32,
    pub media_format: String,
    pub author_id: i32,
    pub thumbnail: Option<String>,
    pub file: String,
}

pub type PublicationId = i32;

#[derive(Identifiable, Debug, Queryable, Deserialize, Associations, AsChangeset, Clone)]
#[belongs_to(MediaType)]
#[belongs_to(Author)]
#[table_name = "publication"]
pub struct Publication {
    pub id: PublicationId,
    pub isbn: String,
    pub title: String,
    pub media_type_id: i32,
    pub media_format: String,
    pub author_id: i32,
    pub thumbnail: Option<String>,
    pub file: String,
}

impl Publication {
    pub fn thumbnail_url(&self) -> Option<String> {
        match self.thumbnail {
            Some(ref file) if file == "" => None,
            Some(_) => Some(Self::generate_url(self.id)),
            None => None,
        }
    }

    fn generate_url(publication_id: i32) -> String {
        format!("/api/publication/thumbnail/{}", publication_id)
    }
}

impl Serialize for Publication {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        let mut state = serializer.serialize_struct("Publication", 8)?;
        state.serialize_field("id", &self.id)?;
        state.serialize_field("isbn", &self.isbn)?;
        state.serialize_field("title", &self.title)?;
        state.serialize_field("media_type_id", &self.media_type_id)?;
        state.serialize_field("author_id", &self.author_id)?;
        state.serialize_field("file", &self.file)?;
        state.serialize_field("media_format", &self.media_format)?;
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
    pub publication_id: PublicationId,
    pub category_id: CategoryId,
}

#[derive(Debug, Insertable, Deserialize)]
#[table_name = "tag"]
pub struct NewTag {
    pub name: String,
}

pub type TagId = i32;

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, AsChangeset)]
#[table_name = "tag"]
pub struct Tag {
    pub id: TagId,
    pub name: String,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, Associations, Insertable)]
#[belongs_to(Category, foreign_key = "category_id")]
#[table_name = "favorite_category"]
#[primary_key(category_id)]
pub struct FavoriteCategory {
    pub category_id: CategoryId,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, Associations, Insertable)]
#[table_name = "publication_progress"]
#[primary_key(publication_id)]
pub struct PublicationProgress {
    pub publication_id: i32,
    pub progress: f32,
}

#[derive(Identifiable, Debug, Queryable, Serialize, Deserialize, Associations, Insertable)]
#[table_name = "recent_publication"]
#[primary_key(publication_id)]
pub struct RecentPublication {
    pub publication_id: i32,
    pub timestamp: Option<chrono::NaiveDateTime>,
}
