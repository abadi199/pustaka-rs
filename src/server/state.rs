use actix::prelude::Addr;
use db::executor::DbExecutor;

#[derive(Clone)]
pub struct AppState {
    pub db: Addr<DbExecutor>,
}
