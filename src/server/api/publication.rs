use actix_web::http::Method;
use actix_web::{
    fs::NamedFile, middleware, App, AsyncResponder, FutureResponse, HttpResponse, Json, Path, State,
};
use db::publication::{Create, Delete, Get, List, ListByCategory, Update};
use futures::Future;
use models::{NewPublication, Publication};
use reader::cbr;
use state::AppState;
use std::io;

fn list(state: State<AppState>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(List {})
        .from_err()
        .and_then(|res| match res {
            Ok(publications) => Ok(HttpResponse::Ok().json(publications)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn create(state: State<AppState>, json: Json<NewPublication>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Create {
            new_publication: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn update(state: State<AppState>, json: Json<Publication>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Update {
            publication: json.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn delete(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Delete {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(_) => Ok(HttpResponse::Ok().json(())),
            Err(_err) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn get(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(publication) => Ok(HttpResponse::Ok().json(publication)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn read(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(publication) => cbr::open(&publication)
                .map_err(|err| err.into())
                .and_then(|data| Ok(HttpResponse::Ok().json(data))),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn read_page(
    state: State<AppState>,
    publication_id: Path<i32>,
    page_number: Path<usize>,
) -> FutureResponse<NamedFile> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| {
            res.and_then(|publication| {
                let filename =
                    cbr::page(&publication, page_number.into_inner()).expect("Unable to read page");
                let file = NamedFile::open(filename);
                file.map_err(|err| err.into())
            })
        })
        .responder()
}

fn list_by_category(
    state: State<AppState>,
    category_id: Path<i32>,
) -> FutureResponse<HttpResponse> {
    state
        .db
        .send(ListByCategory {
            category_id: category_id.into_inner(),
        })
        .from_err()
        .and_then(|res| match res {
            Ok(publications) => Ok(HttpResponse::Ok().json(publications)),
            Err(_) => Ok(HttpResponse::InternalServerError().into()),
        })
        .responder()
}

fn get_thumbnail(state: State<AppState>, publication_id: Path<i32>) -> FutureResponse<NamedFile> {
    state
        .db
        .send(Get {
            publication_id: publication_id.into_inner(),
        })
        .from_err()
        .and_then(|res| {
            res.and_then(|publication| match publication.thumbnail {
                Some(thumbnail) => NamedFile::open(thumbnail).map_err(|err| err.into()),
                None => Err(io::Error::new(
                    io::ErrorKind::InvalidInput,
                    "Publication doesn't have thumbnail",
                )
                .into()),
            })
        })
        .responder()
}

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
        .route("/{publication_id}", Method::GET, get)
        .route("/", Method::GET, list)
        .route("/", Method::POST, create)
        .route("/", Method::PUT, update)
        .route("/{publication_id}", Method::DELETE, delete)
        .route("/{publication_id}", Method::GET, get)
        .route("/category/{category_id}", Method::GET, list_by_category)
        .route("/thumbnail/{publication_id}", Method::GET, get_thumbnail)
        .route("/read/{publication_id}", Method::GET, read)
        .route(
            "/read/{publication_id}/page/{page_number}",
            Method::GET,
            read_page,
        )
}
