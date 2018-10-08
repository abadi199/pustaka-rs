extern crate diesel;

use actix_web::Error;
use diesel::prelude::*;

use actix::prelude::*;
use db::executor::DbExecutor;
use models::{NewPublication, Publication};
use schema::publication::dsl::*;

pub struct List {}
impl Message for List {
    type Result = Result<Vec<Publication>, Error>;
}

pub struct Create {
    pub new_publication: NewPublication,
}
impl Message for Create {
    type Result = Result<(), Error>;
}

pub struct Update {
    pub publication: Publication,
}
impl Message for Update {
    type Result = Result<(), Error>;
}

pub struct Delete {
    pub publication_id: i32,
}
impl Message for Delete {
    type Result = Result<(), Error>;
}

pub struct Get {
    pub publication_id: i32,
}
impl Message for Get {
    type Result = Result<Publication, Error>;
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

impl Handler<Create> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Create, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::insert_into(publication)
            .values(msg.new_publication)
            .execute(&*connection)
            .expect("Error inserting publication");
        Ok(())
    }
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
