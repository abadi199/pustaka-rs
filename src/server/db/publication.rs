extern crate diesel;

use actix_web::Error;
use diesel::prelude::*;

use actix::prelude::*;
use db::executor::DbExecutor;
use models::{Category, NewPublication, Publication, PublicationProgress, RecentPublication};
use schema::publication::dsl::*;

#[derive(Debug)]
pub struct List {}
impl Message for List {
    type Result = Result<Vec<Publication>, Error>;
}
impl Handler<List> for DbExecutor {
    type Result = Result<Vec<Publication>, Error>;

    fn handle(&mut self, _msg: List, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let publications = publication
            .order_by(title.asc())
            .load::<Publication>(&*connection)
            .expect("Error loading publications");
        Ok(publications)
    }
}

#[derive(Debug)]
pub struct Create(pub NewPublication);
impl Message for Create {
    type Result = Result<Publication, Error>;
}
impl Handler<Create> for DbExecutor {
    type Result = Result<Publication, Error>;

    fn handle(&mut self, msg: Create, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let new_publication = msg.0;
        let file_name = new_publication.file.clone();
        diesel::insert_into(publication)
            .values(new_publication)
            .execute(&*connection)
            .expect("Error inserting publication");
        let the_publication = publication
            .filter(file.eq(file_name))
            .first::<Publication>(&*connection)
            .expect("Unable to query new publication");
        Ok(the_publication)
    }
}

#[derive(Debug)]
pub struct CreateBatch(pub Vec<NewPublication>);
impl Message for CreateBatch {
    type Result = Result<Vec<Publication>, Error>;
}
impl Handler<CreateBatch> for DbExecutor {
    type Result = Result<Vec<Publication>, Error>;

    fn handle(&mut self, msg: CreateBatch, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let new_publications = msg.0;
        let mut filenames: Vec<String> = Vec::new();

        for new_publication in new_publications.iter() {
            let existing_publication =
                get_publication_by_file(connection, &new_publication.file).ok();
            if existing_publication.is_none() {
                diesel::insert_into(publication)
                    .values(new_publication)
                    .execute(&*connection)
                    .expect("Error inserting publication");
                filenames.push(new_publication.file.to_string());
            }
        }

        let publications = publication
            .filter(file.eq_any(filenames))
            .load::<Publication>(&*connection)
            .expect("Unable to query new publications");
        Ok(publications)
    }
}

#[derive(Debug)]
pub struct Update {
    pub publication: Publication,
}
impl Message for Update {
    type Result = Result<(), Error>;
}
impl Handler<Update> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Update, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::update(publication.filter(id.eq(msg.publication.id)))
            .set(msg.publication)
            .execute(&*connection)
            .expect("Error updating publication");
        Ok(())
    }
}

#[derive(Debug)]
pub struct UpdateThumbnail {
    pub publication_id: i32,
    pub thumbnail: String,
}
impl Message for UpdateThumbnail {
    type Result = Result<(), Error>;
}
impl Handler<UpdateThumbnail> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: UpdateThumbnail, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::update(publication.filter(id.eq(msg.publication_id)))
            .set(thumbnail.eq(Some(msg.thumbnail)))
            .execute(&*connection)
            .expect("Error updating thumbnail");
        Ok(())
    }
}

#[derive(Debug)]
pub struct DeleteThumbnail {
    pub publication_id: i32,
}
impl Message for DeleteThumbnail {
    type Result = Result<Option<String>, Error>;
}
impl Handler<DeleteThumbnail> for DbExecutor {
    type Result = Result<Option<String>, Error>;

    fn handle(&mut self, msg: DeleteThumbnail, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let the_thumbnail: Option<String> = get_publication(connection, msg.publication_id)
            .map(|the_publication: Publication| the_publication.thumbnail)
            .map_err(actix_web::error::ErrorInternalServerError)?;

        match the_thumbnail {
            Some(_) => {
                diesel::update(publication.filter(id.eq(msg.publication_id)))
                    .set(thumbnail.eq::<Option<&str>>(None))
                    .execute(&*connection)
                    .map_err(actix_web::error::ErrorInternalServerError)?;
                Ok(the_thumbnail)
            }
            None => Ok(the_thumbnail),
        }
    }
}
#[derive(Debug)]
pub struct Delete {
    pub publication_id: i32,
}
impl Message for Delete {
    type Result = Result<(), Error>;
}
impl Handler<Delete> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Delete, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::delete(publication.filter(id.eq(msg.publication_id)))
            .execute(&*connection)
            .expect(&format!(
                "Error deleting publication {}",
                msg.publication_id
            ));
        Ok(())
    }
}

#[derive(Debug)]
pub struct Get {
    pub publication_id: i32,
}
impl Message for Get {
    type Result = Result<Publication, Error>;
}
impl Handler<Get> for DbExecutor {
    type Result = Result<Publication, Error>;

    fn handle(&mut self, msg: Get, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        get_publication(connection, msg.publication_id).map_err(|err| {
            println!("{:?}", err);
            actix_web::error::ErrorInternalServerError(err)
        })
    }
}

#[derive(Debug)]
pub struct AddRecent(pub i32);
impl Message for AddRecent {
    type Result = Result<(), Error>;
}
impl Handler<AddRecent> for DbExecutor {
    type Result = Result<(), Error>;
    fn handle(&mut self, msg: AddRecent, _: &mut Self::Context) -> Self::Result {
        use schema::recent_publication::dsl;
        let connection: &SqliteConnection = &self.0.get().unwrap();
        println!("Inserting into recent_publication: {:?}", msg.0);

        diesel::delete(dsl::recent_publication.filter(dsl::publication_id.eq(msg.0)))
            .execute(&*connection)
            .expect(&format!("Error deleting recent_publication {}", msg.0));

        diesel::insert_into(dsl::recent_publication)
            .values(RecentPublication {
                publication_id: msg.0,
                timestamp: None,
            })
            .execute(&*connection)
            .expect("Error inserting recent_publication");

        Ok(())
    }
}

#[derive(Debug)]
pub struct ListRecent;
impl Message for ListRecent {
    type Result = Result<Vec<Publication>, Error>;
}
impl Handler<ListRecent> for DbExecutor {
    type Result = Result<Vec<Publication>, Error>;
    fn handle(&mut self, msg: ListRecent, _: &mut Self::Context) -> Self::Result {
        use schema::recent_publication::dsl;
        let connection: &SqliteConnection = &self.0.get().unwrap();

        let row: Vec<(Publication, RecentPublication)> = publication
            .inner_join(dsl::recent_publication)
            .load(&*connection)
            .map_err(actix_web::error::ErrorInternalServerError)?;
        Ok(row
            .into_iter()
            .map(|(the_publication, _)| the_publication)
            .collect())
    }
}

#[derive(Debug)]
pub struct ListByCategory {
    pub category_id: i32,
}
impl Message for ListByCategory {
    type Result = Result<Vec<Publication>, Error>;
}
impl Handler<ListByCategory> for DbExecutor {
    type Result = Result<Vec<Publication>, Error>;

    fn handle(&mut self, msg: ListByCategory, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        use schema::publication::dsl as publication;
        use schema::publication_category::dsl as publication_category;

        let categories: Vec<i32> = get_category_and_descendants(msg.category_id, &connection)
            .expect("Invalid category id")
            .iter()
            .map(|category| category.id)
            .collect();

        let the_publication_id = publication_category::publication_category
            .filter(publication_category::category_id.eq_any(categories))
            .select(publication_category::publication_id)
            .load::<i32>(&*connection)
            .expect("Error getting publications id");

        let publications = publication::publication
            .filter(publication::id.eq_any(the_publication_id))
            .order_by(publication::title.asc())
            .load::<Publication>(&*connection)
            .expect("Error getting publications");

        Ok(publications)
    }
}

fn get_category(category_id: i32, connection: &SqliteConnection) -> QueryResult<Category> {
    use schema::category::dsl as category;

    category::category
        .filter(category::id.eq(category_id))
        .first::<Category>(&*connection)
}

fn get_category_and_descendants(
    category_id: i32,
    connection: &SqliteConnection,
) -> QueryResult<Vec<Category>> {
    let mut categories: Vec<Category> = vec![];

    let parent_category = get_category(category_id, connection)?;
    categories.push(parent_category);

    let mut children = get_descendant_rec(category_id, connection)?;
    categories.append(&mut children);

    Ok(categories)
}

fn get_descendant_rec(
    category_id: i32,
    connection: &SqliteConnection,
) -> QueryResult<Vec<Category>> {
    use schema::category::dsl as category;
    let mut categories = category::category
        .filter(category::parent_id.eq(category_id))
        .load::<Category>(connection)?;

    let mut grandchildren: Vec<Category> = vec![];
    for c in categories.iter() {
        let mut result = get_descendant_rec(c.id, connection);
        match result {
            Ok(mut d) => {
                grandchildren.append(&mut d);
            }
            Err(_) => {}
        }
    }

    categories.append(&mut grandchildren);
    Ok(categories)
}

fn get_publication_by_file(
    connection: &SqliteConnection,
    the_file: &str,
) -> Result<Publication, String> {
    let mut row = publication
        .filter(file.eq(the_file))
        .limit(1)
        .load(&*connection)
        .map_err(|_| format!("Error loading publication with file {}", the_file))?;

    match row.is_empty() {
        true => Err(format!(
            "publication with file of {} can't be found",
            the_file
        )),
        false => Ok(row.remove(0)),
    }
}

fn get_publication(
    connection: &SqliteConnection,
    publication_id: i32,
) -> Result<Publication, String> {
    let mut row = publication
        .filter(id.eq(publication_id))
        .limit(1)
        .load(&*connection)
        .map_err(|err| {
            println!("{:?}", err);
            format!("Error loading publication with id {}", publication_id)
        })?;

    match row.is_empty() {
        true => Err(format!(
            "publication with id of {} can't be found",
            publication_id
        )),
        false => Ok(row.remove(0)),
    }
}

#[derive(Debug)]
pub struct UpdateProgress {
    pub publication_id: i32,
    pub progress: f32,
}
impl Message for UpdateProgress {
    type Result = Result<(), Error>;
}
impl Handler<UpdateProgress> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: UpdateProgress, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let option = get_publication_progress(connection, msg.publication_id)?;
        match option {
            Some(_) => update_publication_progress(connection, msg.publication_id, msg.progress),
            None => insert_publication_progress(connection, msg.publication_id, msg.progress),
        }
    }
}

#[derive(Debug)]
pub struct GetProgress {
    pub publication_id: i32,
}
impl Message for GetProgress {
    type Result = Result<f32, Error>;
}
impl Handler<GetProgress> for DbExecutor {
    type Result = Result<f32, Error>;

    fn handle(&mut self, msg: GetProgress, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        get_publication_progress(connection, msg.publication_id).map(|option| {
            option
                .map(|publication_progress| publication_progress.progress)
                .unwrap_or(0f32)
        })
    }
}

fn get_publication_progress(
    connection: &SqliteConnection,
    publication_id: i32,
) -> Result<Option<PublicationProgress>, Error> {
    use schema::publication_progress::dsl;

    let mut row: Vec<PublicationProgress> = dsl::publication_progress
        .filter(dsl::publication_id.eq(publication_id))
        .limit(1)
        .load(&*connection)
        .map_err(actix_web::error::ErrorInternalServerError)?;

    Ok(row.pop())
}

fn insert_publication_progress(
    connection: &SqliteConnection,
    the_publication_id: i32,
    the_progress: f32,
) -> Result<(), Error> {
    use schema::publication_progress::dsl::*;
    diesel::insert_into(publication_progress)
        .values(PublicationProgress {
            publication_id: the_publication_id,
            progress: the_progress,
        })
        .execute(&*connection)
        .expect("Error inserting publication_progress");

    Ok(())
}
fn update_publication_progress(
    connection: &SqliteConnection,
    the_publication_id: i32,
    the_progress: f32,
) -> Result<(), Error> {
    use schema::publication_progress::dsl::*;
    diesel::update(publication_progress.filter(publication_id.eq(the_publication_id)))
        .set(progress.eq(the_progress))
        .execute(&*connection)
        .expect("Error updating publication_progress");
    Ok(())
}
