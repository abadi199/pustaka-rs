extern crate diesel;

use actix_web::http::Method;
use actix_web::{
    fs::NamedFile, middleware, App, AsyncResponder, Error, FutureResponse, HttpResponse, Json,
    Path, Result, State,
};
use db::publication::{Create, Delete, Get, List, Update};
use futures::Future;
use models::{NewPublication, Publication};
use reader::cbr;
use state::AppState;

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(List {})
        .from_err()
        .and_then(|res| match res {
            Ok(publications) => Ok(HttpResponse::Ok().json(publications)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn create(state: State<AppState>, json: Json<NewPublication>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Create {
            new_publication: json.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn update(state: State<AppState>, json: Json<Publication>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Update {
            publication: json.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

fn delete(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Delete {
            publication_id: publication_id.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(err) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

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

fn read(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        }).from_err()
        .and_then(|res| match res {
            Ok(publication) => {
                let data = cbr::open(&publication).expect("Unable to read poblication");
                Ok(HttpResponse::Ok().json(data))
            }
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        }).responder()
}

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
fn read_page(
    state: State<AppState>,
    publication_id: Path<i32>,
    page_number: Path<usize>,
) -> FutureResponse<NamedFile> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        }).from_err()
        .and_then(|res| {
            res.and_then(|publication| {
                let filename =
                    cbr::page(&publication, page_number.into_inner()).expect("Unable to read page");
                let file = NamedFile::open(filename);
                file.map_err(|err| err.into())
            })
        }).responder()
}

// #[get("/publication/<the_publication_id>")]
// fn by_publication(the_publication_id: i32, connection: DbConn) -> Json<Vec<Publication>> {
//     use schema::publication::dsl as publication;
//     use schema::publication_publication::dsl as publication_publication;

//     let publications: Vec<i32> = get_publication_and_descendants(the_publication_id, &connection)
//         .expect("Invalid publication id")
//         .iter()
//         .map(|publication| publication.id)
//         .collect();

//     let the_publication_id = publication_publication::publication_publication
//         .filter(publication_publication::publication_id.eq_any(publications))
//         .select(publication_publication::publication_id)
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

// fn get_publication(publication_id: i32, connection: &SqliteConnection) -> QueryResult<Publication> {
//     use schema::publication::dsl as publication;

//     publication::publication
//         .filter(publication::id.eq(publication_id))
//         .first::<Publication>(&*connection)
// }

// fn get_publication_and_descendants(
//     publication_id: i32,
//     connection: &SqliteConnection,
// ) -> QueryResult<Vec<Publication>> {
//     let mut publications: Vec<Publication> = vec![];

//     let parent_publication = get_publication(publication_id, connection)?;
//     publications.push(parent_publication);

//     let mut children = get_descendant_rec(publication_id, connection)?;
//     publications.append(&mut children);

//     Ok(publications)
// }

// fn get_descendant_rec(
//     publication_id: i32,
//     connection: &SqliteConnection,
// ) -> QueryResult<Vec<Publication>> {
//     use schema::publication::dsl as publication;
//     let mut publications = publication::publication
//         .filter(publication::parent_id.eq(publication_id))
//         .load::<Publication>(connection)?;

//     let mut grandchildren: Vec<Publication> = vec![];
//     for c in publications.iter() {
//         let mut result = get_descendant_rec(c.id, connection);
//         match result {
//             Ok(mut d) => {
//                 grandchildren.append(&mut d);
//             }
//             Err(_) => {}
//         }
//     }

//     publications.append(&mut grandchildren);
//     Ok(publications)
// }

// END HERE

// #[post("/", data = "<json>")]
// fn create(json: Json<NewPublication>, connection: DbConn) {
//     let new_publication = &json.0;
//     diesel::insert_into(publication)
//         .values(new_publication)
//         .execute(&*connection)
//         .expect("Error inserting publication");
// }

// #[put("/", data = "<json>")]
// fn update(json: Json<Publication>, connection: DbConn) {
//     let the_publication = &json.0;
//     diesel::update(publication.filter(id.eq(the_publication.id)))
//         .set(the_publication)
//         .execute(&*connection)
//         .expect("Error updating publication");
// }

// #[delete("/<publication_id>")]
// fn delete(publication_id: i32, connection: DbConn) {
//     diesel::delete(publication.filter(id.eq(publication_id)))
//         .execute(&*connection)
//         .expect(&format!("Error deleting publication {}", publication_id));
// }

// #[get("/<publication_id>")]
// fn get(publication_id: i32, connection: DbConn) -> Json<Publication> {
//     let mut row = publication
//         .filter(id.eq(publication_id))
//         .limit(1)
//         .load(&*connection)
//         .expect(&format!("Error loading publication with id {}", publication_id));

//     match row.is_empty() {
//         true => panic!(format!(
//             "publication with id of {} can't be found",
//             publication_id
//         )),
//         false => Json(row.remove(0)),
//     }
// }

pub fn create_app(state: AppState, prefix: &str) -> App<AppState> {
    App::with_state(state)
        .middleware(middleware::Logger::default())
        .prefix(prefix)
        .route("/{publication_id}", Method::GET, read)
        .route(
            "/{publication_id}/page/{page_number}",
            Method::GET,
            read_page,
        ).route("/", Method::GET, list)
        .route("/", Method::POST, create)
        .route("/", Method::PUT, update)
        .route("/{publication_id}", Method::DELETE, delete)
        .route("/{publication_id}", Method::GET, get)
    // .route("/", Method::GET, by_publication)
    // .route("/", Method::GET, get_thumbnail)
    // .route("/", Method::GET, get_publication)
}
