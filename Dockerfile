FROM debian:9.5-slim as build
SHELL ["/bin/bash", "-c"]

COPY . /app/pustaka
WORKDIR /app/pustaka

# Build Rust
RUN apt-get update && apt-get install -y curl gcc g++ libsqlite3-dev
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN source $HOME/.cargo/env && cargo install diesel_cli --no-default-features --features sqlite
RUN source $HOME/.cargo/env && rustup default nightly-2018-05-15 
RUN source $HOME/.cargo/env && diesel migration run
RUN source $HOME/.cargo/env && cargo run --bin seed 
RUN source $HOME/.cargo/env && cargo build --bin pustaka --target-dir dist

# Build Elm
RUN tar xzvf ./bin/binaries-for-linux.tar.gz -C bin
RUN rm ./bin/binaries-for-linux.tar.gz
RUN ls -al bin
RUN /app/pustaka/bin/elm make src/client/Main.elm --optimize --output app/app.js
