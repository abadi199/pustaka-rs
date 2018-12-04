extern crate diesel;

use actix_web::Error;
use diesel::prelude::*;

use actix::prelude::*;
use db::executor::DbExecutor;
use models::{MediaType, NewMediaType};
use schema::media_type::dsl::*;

pub struct List {}
impl Message for List {
    type Result = Result<Vec<MediaType>, Error>;
}
impl Handler<List> for DbExecutor {
    type Result = Result<Vec<MediaType>, Error>;

    fn handle(&mut self, _msg: List, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let media_types = media_type
            .load::<MediaType>(&*connection)
            .expect("Error loading media_types");
        Ok(media_types)
    }
}

pub struct Create {
    pub new_media_type: NewMediaType,
}
impl Message for Create {
    type Result = Result<(), Error>;
}
impl Handler<Create> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Create, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::insert_into(media_type)
            .values(msg.new_media_type)
            .execute(&*connection)
            .expect("Error inserting media_type");
        Ok(())
    }
}

pub struct Update {
    pub media_type: MediaType,
}
impl Message for Update {
    type Result = Result<(), Error>;
}
impl Handler<Update> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Update, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::update(media_type.filter(id.eq(msg.media_type.id)))
            .set(msg.media_type)
            .execute(&*connection)
            .expect("Error updating media_type");
        Ok(())
    }
}

pub struct Delete {
    pub media_type_id: i32,
}
impl Message for Delete {
    type Result = Result<(), Error>;
}
impl Handler<Delete> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Delete, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::delete(media_type.filter(id.eq(msg.media_type_id)))
            .execute(&*connection)
            .expect(&format!("Error deleting media_type {}", msg.media_type_id));
        Ok(())
    }
}

pub struct Get {
    pub media_type_id: i32,
}
impl Message for Get {
    type Result = Result<MediaType, Error>;
}
impl Handler<Get> for DbExecutor {
    type Result = Result<MediaType, Error>;

    fn handle(&mut self, msg: Get, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let mut row = media_type
            .filter(id.eq(msg.media_type_id))
            .limit(1)
            .load(&*connection)
            .expect(&format!(
                "Error loading media_type with id {}",
                msg.media_type_id
            ));

        match row.is_empty() {
            true => panic!(format!(
                "media_type with id of {} can't be found",
                msg.media_type_id
            )),
            false => Ok(row.remove(0)),
        }
    }
}
