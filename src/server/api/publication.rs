extern crate diesel;

use actix_web::http::Method;
use actix_web::{middleware, App, AsyncResponder, FutureResponse, HttpResponse, Path, State};
use db::publication::{Create, Delete, Get, List, Update};
use futures::Future;
use models::{Category, NewCategory};
use state::AppState;

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(List {})
        .from_err()
        .and_then(|res| match res {
            Ok(categories) => Ok(HttpResponse::Ok().json(categories)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

// #[get("/read/<the_publication_id>")]
// fn read(the_publication_id: i32, connection: DbConn) -> Json<reader::Data> {
//     use schema::publication::dsl as publication;

//     let the_publication = publication::publication
//         .filter(publication::id.eq(the_publication_id))
//         .first::<Publication>(&*connection)
//         .expect("Error getting publication");
//     let data = cbr::open(&the_publication).expect("Unable to read publication");
//     println!("Data: {:?}", data);
//     Json(data)
// }

// #[get("/read/<publication_id>/page/<page_number>")]
// fn read_page(publication_id: i32, page_number: usize, connection: DbConn) -> Option<NamedFile> {
//     use schema::publication::dsl as publication;
//     let the_publication = publication::publication
//         .filter(publication::id.eq(publication_id))
//         .first::<Publication>(&*connection)
//         .expect("Invalid publication");

//     let filename = cbr::page(&the_publication, page_number).expect("Unable to read page");
//     println!("Page Filename: {:?}", filename);
//     NamedFile::open(filename).ok()
// }

fn get(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(publication) => Ok(HttpResponse::Ok().json(publication)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

// #[get("/category/<the_category_id>")]
// fn by_category(the_category_id: i32, connection: DbConn) -> Json<Vec<Publication>> {
//     use schema::publication::dsl as publication;
//     use schema::publication_category::dsl as publication_category;

//     let categories: Vec<i32> = get_category_and_descendants(the_category_id, &connection)
//         .expect("Invalid category id")
//         .iter()
//         .map(|category| category.id)
//         .collect();

//     let the_publication_id = publication_category::publication_category
//         .filter(publication_category::category_id.eq_any(categories))
//         .select(publication_category::publication_id)
//         .load::<i32>(&*connection)
//         .expect("Error getting publications id");

//     let publications = publication::publication
//         .filter(publication::id.eq_any(the_publication_id))
//         .load::<Publication>(&*connection)
//         .expect("Error getting publications");

//     Json(publications)
// }

// #[get("/thumbnail/<publication_id>")]
// fn get_thumbnail(publication_id: i32, connection: DbConn) -> Option<NamedFile> {
//     use schema::publication::dsl as publication;
//     let the_publication = publication::publication
//         .filter(publication::id.eq(publication_id))
//         .first::<Publication>(&*connection)
//         .expect("Invalid publication");

//     the_publication
//         .thumbnail
//         .and_then(|tn| NamedFile::open(tn).ok())
// }

// fn get_category(category_id: i32, connection: &SqliteConnection) -> QueryResult<Category> {
//     use schema::category::dsl as category;

//     category::category
//         .filter(category::id.eq(category_id))
//         .first::<Category>(&*connection)
// }

// fn get_category_and_descendants(
//     category_id: i32,
//     connection: &SqliteConnection,
// ) -> QueryResult<Vec<Category>> {
//     let mut categories: Vec<Category> = vec![];

//     let parent_category = get_category(category_id, connection)?;
//     categories.push(parent_category);

//     let mut children = get_descendant_rec(category_id, connection)?;
//     categories.append(&mut children);

//     Ok(categories)
// }

// fn get_descendant_rec(
//     category_id: i32,
//     connection: &SqliteConnection,
// ) -> QueryResult<Vec<Category>> {
//     use schema::category::dsl as category;
//     let mut categories = category::category
//         .filter(category::parent_id.eq(category_id))
//         .load::<Category>(connection)?;

//     let mut grandchildren: Vec<Category> = vec![];
//     for c in categories.iter() {
//         let mut result = get_descendant_rec(c.id, connection);
//         match result {
//             Ok(mut d) => {
//                 grandchildren.append(&mut d);
//             }
//             Err(_) => {}
//         }
//     }

//     categories.append(&mut grandchildren);
//     Ok(categories)
// }

// END HERE

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

pub fn create_app(state: AppState, prefix: &str) -> App<AppState> {
    App::with_state(state)
        .middleware(middleware::Logger::default())
        .prefix(prefix)
        // .route("/", Method::GET, read)
        // .route("/", Method::GET, read_page)
        .route("/", Method::GET, list)
        .route("/{publication_id}", Method::GET, get)
    // .route("/", Method::GET, by_category)
    // .route("/", Method::GET, get_thumbnail)
    // .route("/", Method::GET, get_publication)
}
