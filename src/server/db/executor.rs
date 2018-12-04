extern crate diesel;

use actix::{Actor, SyncContext};
use diesel::prelude::*;
use r2d2::Pool;
use r2d2_diesel::ConnectionManager;

/// This is db executor actor. We are going to run 3 of them in parallel.
pub struct DbExecutor(pub Pool<ConnectionManager<SqliteConnection>>);

impl Actor for DbExecutor {
    type Context = SyncContext<Self>;
}
