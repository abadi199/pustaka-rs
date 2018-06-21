extern crate diesel;

use db::DbConn;
use diesel::prelude::*;
use models::*;
use rocket::Route;
use rocket_contrib::Json;
use schema::publication::dsl::*;

#[get("/")]
fn list(connection: DbConn) -> Json<Vec<Publication>> {
    let publications = publication
        .load::<Publication>(&*connection)
        .expect("Error loading publications");
    Json(publications)
}

#[get("/category/<the_category_id>")]
fn by_category(the_category_id: i32, connection: DbConn) -> Json<Vec<Publication>> {
    use schema::publication::dsl as publication;
    use schema::publication_category::dsl as publication_category;

    let categories: Vec<i32> = get_category_and_descendants(the_category_id, &connection)
        .expect("Invalid category id")
        .iter()
        .map(|category| category.id)
        .collect();

    let the_publication_id = publication_category::publication_category
        .filter(publication_category::category_id.eq_any(categories))
        .select(publication_category::publication_id)
        .load::<i32>(&*connection)
        .expect("Error getting publications id");

    let publications = publication::publication
        .filter(publication::id.eq_any(the_publication_id))
        .load::<Publication>(&*connection)
        .expect("Error getting publications");

    Json(publications)
}

fn get_category(category_id: i32, connection: &SqliteConnection) -> QueryResult<Category> {
    use schema::category::dsl as category;

    category::category
        .filter(category::id.eq(category_id))
        .first::<Category>(&*connection)
}

fn get_category_and_descendants(
    category_id: i32,
    connection: &SqliteConnection,
) -> QueryResult<Vec<Category>> {
    let mut categories: Vec<Category> = vec![];

    let parent_category = get_category(category_id, connection)?;
    categories.push(parent_category);

    let mut children = get_descendant(category_id, connection)?;
    categories.append(&mut children);

    Ok(categories)
}

fn get_descendant_rec(
    category_id: i32,
    connection: &SqliteConnection,
) -> QueryResult<Vec<Category>> {
    use schema::category::dsl as category;
    let mut categories = category::category
        .filter(category::parent_id.eq(category_id))
        .load::<Category>(connection)?;

    let mut grandchildren: Vec<Category> = vec![];
    for c in categories.iter() {
        let mut result = get_descendant_rec(c.id, connection);
        match result {
            Ok(mut d) => {
                grandchildren.append(&mut d);
            }
            Err(_) => {}
        }
    }

    categories.append(&mut grandchildren);
    Ok(categories)
}

// #[post("/", data = "<json>")]
// fn create(json: Json<NewCategory>, connection: DbConn) {
//     let new_category = &json.0;
//     diesel::insert_into(category)
//         .values(new_category)
//         .execute(&*connection)
//         .expect("Error inserting category");
// }

// #[put("/", data = "<json>")]
// fn update(json: Json<Category>, connection: DbConn) {
//     let the_category = &json.0;
//     diesel::update(category.filter(id.eq(the_category.id)))
//         .set(the_category)
//         .execute(&*connection)
//         .expect("Error updating category");
// }

// #[delete("/<category_id>")]
// fn delete(category_id: i32, connection: DbConn) {
//     diesel::delete(category.filter(id.eq(category_id)))
//         .execute(&*connection)
//         .expect(&format!("Error deleting category {}", category_id));
// }

// #[get("/<category_id>")]
// fn get(category_id: i32, connection: DbConn) -> Json<Category> {
//     let mut row = category
//         .filter(id.eq(category_id))
//         .limit(1)
//         .load(&*connection)
//         .expect(&format!("Error loading category with id {}", category_id));

//     match row.is_empty() {
//         true => panic!(format!(
//             "category with id of {} can't be found",
//             category_id
//         )),
//         false => Json(row.remove(0)),
//     }
// }

pub fn routes() -> Vec<Route> {
    routes![list, by_category] //, create, delete, get, update]
}
