FROM node:8.16.0-jessie as build
SHELL ["/bin/bash", "-c"]
WORKDIR /app/pustaka/

# Build Rust
RUN apt-get update && apt-get install -y curl gcc g++ libsqlite3-dev
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN source $HOME/.cargo/env && cargo install diesel_cli --no-default-features --features sqlite

COPY diesel.toml  /app/pustaka/
COPY migrations/ /app/pustaka/migrations/
RUN source $HOME/.cargo/env && DATABASE_URL=/app/pustaka/pustaka.db diesel migration run

COPY Cargo.lock Cargo.toml /app/pustaka/
COPY src/server/ /app/pustaka/src/server/
RUN source $HOME/.cargo/env && cargo build --bins --release
RUN DATABASE_URL=/app/pustaka/pustaka.db PUSTAKA_PUBLICATION_PATH=/app/pustaka/ /app/pustaka/target/release/seed

# Build Elm
COPY package.json package-lock.json tsconfig.json elm.json /app/pustaka/
COPY src/client/ /app/pustaka/src/client/
RUN npm install
RUN npm run prod:client

FROM debian:jessie-slim
RUN apt-get update && apt-get install -y libsqlite3-dev
COPY --from=build /app/pustaka/pustaka.db /app/pustaka/target/release/pustaka /app/pustaka/target/release/scanner /app/pustaka/
COPY --from=build /app/pustaka/app/ /app/pustaka/app/
WORKDIR /app/pustaka/
EXPOSE 8081
CMD ["./pustaka"]