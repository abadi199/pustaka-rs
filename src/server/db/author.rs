extern crate diesel;

use actix_web::Error;
use diesel::prelude::*;

use actix::prelude::*;
use db::executor::DbExecutor;
use models::{Author, NewAuthor};
use schema::author::dsl::*;

pub struct List {}
impl Message for List {
    type Result = Result<Vec<Author>, Error>;
}
impl Handler<List> for DbExecutor {
    type Result = Result<Vec<Author>, Error>;

    fn handle(&mut self, _msg: List, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let authors = author
            .load::<Author>(&*connection)
            .expect("Error loading authors");
        Ok(authors)
    }
}

pub struct Create {
    pub new_author: NewAuthor,
}
impl Message for Create {
    type Result = Result<(), Error>;
}
impl Handler<Create> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Create, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::insert_into(author)
            .values(msg.new_author)
            .execute(&*connection)
            .expect("Error inserting author");
        Ok(())
    }
}

pub struct Update {
    pub author: Author,
}
impl Message for Update {
    type Result = Result<(), Error>;
}
impl Handler<Update> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Update, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::update(author.filter(id.eq(msg.author.id)))
            .set(msg.author)
            .execute(&*connection)
            .expect("Error updating author");
        Ok(())
    }
}

pub struct Delete {
    pub author_id: i32,
}
impl Message for Delete {
    type Result = Result<(), Error>;
}
impl Handler<Delete> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Delete, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::delete(author.filter(id.eq(msg.author_id)))
            .execute(&*connection)
            .expect(&format!("Error deleting author {}", msg.author_id));
        Ok(())
    }
}

pub struct Get {
    pub author_id: i32,
}
impl Message for Get {
    type Result = Result<Author, Error>;
}
impl Handler<Get> for DbExecutor {
    type Result = Result<Author, Error>;

    fn handle(&mut self, msg: Get, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let mut row = author
            .filter(id.eq(msg.author_id))
            .limit(1)
            .load(&*connection)
            .expect(&format!("Error loading author with id {}", msg.author_id));

        match row.is_empty() {
            true => panic!(format!(
                "author with id of {} can't be found",
                msg.author_id
            )),
            false => Ok(row.remove(0)),
        }
    }
}
