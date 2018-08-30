FROM alpine:3.6 as build

COPY . /app/pustaka
WORKDIR /app/pustaka

# Build Rust
RUN apk --no-cache add curl
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN rustup override set nightly-2018-05-15
RUN cargo run --bin seed
RUN cargo build --bin pustaka --target-dir dist

# Build Elm
RUN tar xzvf ./bin/elm-2a3965-static-linux-x64.tar.gz -C bin
RUN rm ./bin/elm-2a3965-static-linux-x64.tar.gz
RUN ls -al bin
RUN /app/pustaka/bin/elm make src/client/Main.elm --optimize --output app/app.js
