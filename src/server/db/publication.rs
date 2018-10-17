extern crate diesel;

use actix_web::Error;
use diesel::prelude::*;

use actix::prelude::*;
use db::executor::DbExecutor;
use models::{Category, NewPublication, Publication};
use schema::publication::dsl::*;

pub struct List {}
impl Message for List {
    type Result = Result<Vec<Publication>, Error>;
}
impl Handler<List> for DbExecutor {
    type Result = Result<Vec<Publication>, Error>;

    fn handle(&mut self, _msg: List, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let publications = publication
            .load::<Publication>(&*connection)
            .expect("Error loading publications");
        Ok(publications)
    }
}

pub enum Create {
    Single(NewPublication),
    Batch(Vec<NewPublication>),
}
impl Message for Create {
    type Result = Result<(), Error>;
}
impl Handler<Create> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Create, _: &mut Self::Context) -> Self::Result {
        println!("Create a new publication");
        let connection: &SqliteConnection = &self.0.get().unwrap();
        match msg {
            Create::Single(new_publication) => {
                diesel::insert_into(publication)
                    .values(new_publication)
                    .execute(&*connection)
                    .expect("Error inserting publication");
                Ok(())
            }
            Create::Batch(new_publications) => {
                diesel::insert_into(publication)
                    .values(new_publications)
                    .execute(&*connection)
                    .expect("Error inserting publication");
                Ok(())
            }
        }
    }
}

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
        let mut row = publication
            .filter(id.eq(msg.publication_id))
            .limit(1)
            .load(&*connection)
            .expect(&format!(
                "Error loading publication with id {}",
                msg.publication_id
            ));

        match row.is_empty() {
            true => panic!(format!(
                "publication with id of {} can't be found",
                msg.publication_id
            )),
            false => Ok(row.remove(0)),
        }
    }
}

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
