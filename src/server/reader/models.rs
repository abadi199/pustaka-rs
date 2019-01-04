#[derive(Serialize, Deserialize, Debug)]
pub struct Data {
    pub id: i32,
    pub isbn: String,
    pub title: String,
    pub media_type_id: i32,
    pub author_id: i32,
    pub thumbnail_url: Option<String>,
    pub file: String,
    pub total_pages: usize,
    pub media_format: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Page {
    pub page_number: i32,
    pub url: Vec<String>,
}
