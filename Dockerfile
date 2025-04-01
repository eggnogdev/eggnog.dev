FROM docker.io/rust:1-slim-bookworm AS build

ARG pkg=eggnog-dev

WORKDIR /build

COPY . .

RUN --mount=type=cache,target=/build/target \
    --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    set -eux; \
    cargo build --release; \
    objcopy --compress-debug-sections target/release/$pkg ./main

################################################################################

FROM docker.io/debian:bookworm-slim

LABEL org.opencontainers.image.source=https://github.com/eggnogdev/eggnog.dev

WORKDIR /app

COPY --from=build /build/main ./
COPY --from=build /build/html /var/www/html

ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=80

CMD ./main
