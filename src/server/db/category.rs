extern crate diesel;

use actix_web::Error;
use diesel::prelude::*;

use actix::prelude::*;
use db::executor::DbExecutor;
use models::{Category, FavoriteCategory, NewCategory};
use schema::category::dsl::*;

pub struct Favorite {}
impl Message for Favorite {
    type Result = Result<Vec<Category>, Error>;
}
impl Handler<Favorite> for DbExecutor {
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

pub struct List {}
impl Message for List {
    type Result = Result<Vec<Category>, Error>;
}
impl Handler<List> for DbExecutor {
    type Result = Result<Vec<Category>, Error>;

    fn handle(&mut self, _msg: List, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let categories = category
            .load::<Category>(&*connection)
            .expect("Error loading categories");
        Ok(categories)
    }
}

pub struct Create {
    pub new_category: NewCategory,
}
impl Message for Create {
    type Result = Result<(), Error>;
}
impl Handler<Create> for DbExecutor {
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

pub struct Update {
    pub category: Category,
}
impl Message for Update {
    type Result = Result<(), Error>;
}
impl Handler<Update> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Update, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::update(category.filter(id.eq(msg.category.id)))
            .set(msg.category)
            .execute(&*connection)
            .expect("Error updating category");
        Ok(())
    }
}

pub struct Delete {
    pub category_id: i32,
}
impl Message for Delete {
    type Result = Result<(), Error>;
}
impl Handler<Delete> for DbExecutor {
    type Result = Result<(), Error>;

    fn handle(&mut self, msg: Delete, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        diesel::delete(category.filter(id.eq(msg.category_id)))
            .execute(&*connection)
            .expect(&format!("Error deleting category {}", msg.category_id));
        Ok(())
    }
}

pub struct Get {
    pub category_id: i32,
}
impl Message for Get {
    type Result = Result<Category, Error>;
}
impl Handler<Get> for DbExecutor {
    type Result = Result<Category, Error>;

    fn handle(&mut self, msg: Get, _: &mut Self::Context) -> Self::Result {
        let connection: &SqliteConnection = &self.0.get().unwrap();
        let mut row = category
            .filter(id.eq(msg.category_id))
            .limit(1)
            .load(&*connection)
            .expect(&format!(
                "Error loading category with id {}",
                msg.category_id
            ));

        match row.is_empty() {
            true => panic!(format!(
                "category with id of {} can't be found",
                msg.category_id
            )),
            false => Ok(row.remove(0)),
        }
    }
}
