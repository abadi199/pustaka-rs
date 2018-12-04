extern crate diesel;

use actix_web::Error;
use diesel::prelude::*;

use actix::prelude::*;
use db::executor::DbExecutor;
use models::{NewTag, Tag};
use schema::tag::dsl::*;

pub struct List {}
impl Message for List {
    type Result = Result<Vec<Tag>, Error>;
}
impl Handler<List> for DbExecutor {
    type Result = Result<Vec<Tag>, Error>;

    fn handle(&mut self, _msg: List, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let tags = tag.load::<Tag>(&*connection).expect("Error loading tags");
        Ok(tags)
    }
}

pub struct Create {
    pub new_tag: NewTag,
}
impl Message for Create {
    type Result = Result<(), Error>;
}
impl Handler<Create> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Create, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::insert_into(tag)
            .values(msg.new_tag)
            .execute(&*connection)
            .expect("Error inserting tag");
        Ok(())
    }
}

pub struct Update {
    pub tag: Tag,
}
impl Message for Update {
    type Result = Result<(), Error>;
}
impl Handler<Update> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Update, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::update(tag.filter(id.eq(msg.tag.id)))
            .set(msg.tag)
            .execute(&*connection)
            .expect("Error updating tag");
        Ok(())
    }
}

pub struct Delete {
    pub tag_id: i32,
}
impl Message for Delete {
    type Result = Result<(), Error>;
}
impl Handler<Delete> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Delete, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::delete(tag.filter(id.eq(msg.tag_id)))
            .execute(&*connection)
            .expect(&format!("Error deleting tag {}", msg.tag_id));
        Ok(())
    }
}

pub struct Get {
    pub tag_id: i32,
}
impl Message for Get {
    type Result = Result<Tag, Error>;
}
impl Handler<Get> for DbExecutor {
    type Result = Result<Tag, Error>;

    fn handle(&mut self, msg: Get, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let mut row = tag
            .filter(id.eq(msg.tag_id))
            .limit(1)
            .load(&*connection)
            .expect(&format!("Error loading tag with id {}", msg.tag_id));

        match row.is_empty() {
            true => panic!(format!("tag with id of {} can't be found", msg.tag_id)),
            false => Ok(row.remove(0)),
        }
    }
}
