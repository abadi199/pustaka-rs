use actix::prelude::Addr;
use config::Config;
use db::executor::DbExecutor;

#[derive(Clone)]
pub struct AppState {
    pub db: Addr<DbExecutor>,
    pub config: Config,
}
