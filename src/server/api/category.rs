use db::DbConn;
use models::*;
use diesel::prelude::*;
use schema::category::dsl::*;
use rocket_contrib::Json;
use rocket::Route;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<Category>> {
    let categories = category.load::<Category>(&*connection).expect(
        "Error loading categories",
    );
    Json(categories)
}

pub fn routes() -> Vec<Route> {
    routes![list]
}
