extern crate diesel;

use actix::prelude::*;
use actix_web::Error;
use db::executor::DbExecutor;
use diesel::prelude::*;

pub struct Run {}
impl Message for Run {
    type Result = Result<(), Error>;
}
impl Handler<Run> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, _: Run, _: &mut Self::Context) -> Self::Result {
        // let connection: &SqliteConnection = &self.0.get()?;

        Ok(())
    }
}
