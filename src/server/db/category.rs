extern crate diesel;

use actix_web::Error;
use diesel::prelude::*;
use r2d2::Pool;
use r2d2_diesel::ConnectionManager;

use actix::prelude::*;
use models::{Category, FavoriteCategory, NewCategory};
use schema::category::dsl::*;

/// This is db executor actor. We are going to run 3 of them in parallel.
pub struct CategoryDbExecutor(pub Pool<ConnectionManager<SqliteConnection>>);

pub struct Favorite {}
pub struct List {}
pub struct Create {
    pub new_category: NewCategory,
}

impl Message for Favorite {
    type Result = Result<Vec<Category>, Error>;
}

impl Message for List {
    type Result = Result<Vec<Category>, Error>;
}

impl Message for Create {
    type Result = Result<(), Error>;
}

impl Actor for CategoryDbExecutor {
    type Context = SyncContext<Self>;
}

impl Handler<Favorite> for CategoryDbExecutor {
    type Result = Result<Vec<Category>, Error>;

    fn handle(&mut self, _msg: Favorite, _: &mut Self::Context) -> Self::Result {
        use schema::favorite_category::dsl::favorite_category;
        let connection: &SqliteConnection = &self.0.get().unwrap();

        let favorite_category_ids: Vec<i32> = favorite_category
            .load::<FavoriteCategory>(&*connection)
            .expect("Error loading favorite categories")
            .iter()
            .map(|fav| fav.category_id)
            .collect();

        Ok(category
            .filter(id.eq_any(favorite_category_ids))
            .load::<Category>(&*connection)
            .expect("Error getting categories"))
    }
}

impl Handler<List> for CategoryDbExecutor {
    type Result = Result<Vec<Category>, Error>;

    fn handle(&mut self, _msg: List, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let categories = category
            .load::<Category>(&*connection)
            .expect("Error loading categories");
        Ok(categories)
    }
}

impl Handler<Create> for CategoryDbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Create, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::insert_into(category)
            .values(msg.new_category)
            .execute(&*connection)
            .expect("Error inserting category");
        Ok(())
    }
}
