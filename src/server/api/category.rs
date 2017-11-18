use pustaka::db::DbConn;
use pustaka::models::*;
use diesel::prelude::*;
use pustaka::schema::category::dsl::*;
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
