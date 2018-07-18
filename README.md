# Pustaka
*Your Personal Digital Library*

## Development
Requirement:
- Rust Nightly: `2018-05-15`
- sqlite3 + sqlite3-dev: `sudo apt install sqlite3 libsqlite3-dev`
- diesel-cli: `cargo install diesel_cli --no-default-features --features sqlite`

How to run on your development environment:
- Watch for Elm files: `npm run watch`
- Start rocket server: `cargo run --bin pustaka`
- Seed the database : `cargo run --bin seed`