use actix::prelude::Addr;
use db::category::CategoryDbExecutor;

pub struct AppState {
    pub categoryDb: Addr<CategoryDbExecutor>,
}
