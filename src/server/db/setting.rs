extern crate diesel;

use actix::prelude::*;
use actix_web::Error;
use db::executor::DbExecutor;
use diesel::prelude::*;
use models::Setting;
use schema::setting::dsl::*;

pub struct Get {}
impl Message for Get {
    type Result = Result<Setting, Error>;
}

impl Handler<Get> for DbExecutor {
    type Result = Result<Setting, Error>;

    fn handle(&mut self, _msg: Get, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let mut row = setting
            .limit(1)
            .load::<Setting>(&*connection)
            .expect("Error loading setting");

        match row.is_empty() {
            true => panic!("setting can't be found"),
            false => Ok(row.remove(0)),
        }
    }
}
