use actix::{prelude::*, Actor, SyncContext};
use std::{fs, io, path::Path};

pub struct FsExecutor();

impl Actor for FsExecutor {
    type Context = SyncContext<Self>;
}

pub struct DeleteFile {
    pub path: String,
}
impl Message for DeleteFile {
    type Result = Result<(), io::Error>;
}
impl Handler<DeleteFile> for FsExecutor {
    type Result = Result<(), io::Error>;

    fn handle(&mut self, msg: DeleteFile, _: &mut Self::Context) -> Self::Result {
        println!("Deleting file: {:?}", msg.path);
        let path = Path::new(&msg.path);
        fs::remove_file(path)?;
        Ok(())
    }
}
