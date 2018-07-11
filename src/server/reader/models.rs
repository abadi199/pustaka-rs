#[derive(Serialize, Deserialize, Debug)]
pub struct Data {
    pub id: i32,
    pub isbn: String,
    pub title: String,
    pub media_type_id: i32,
    pub author_id: i32,
    pub thumbnail: Option<String>,
    pub file: String,
}
