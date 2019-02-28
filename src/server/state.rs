use actix::prelude::Addr;
use config::Config;
use db::executor::DbExecutor;
use fs::executor::FsExecutor;

#[derive(Clone)]
pub struct AppState {
    pub db: Addr<DbExecutor>,
    pub fs: Addr<FsExecutor>,
    pub config: Config,
}
