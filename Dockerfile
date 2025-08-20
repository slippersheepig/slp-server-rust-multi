ARG RUST_MUSL_IMAGE=ghcr.io/rust-cross/rust-musl-cross:x86_64-musl
ARG TARGET_TRIPLE=x86_64-unknown-linux-musl
ARG SRC_ARCHIVE_URL=https://github.com/spacemeowx2/slp-server-rust/archive/refs/heads/master.tar.gz

FROM ${RUST_MUSL_IMAGE} AS builder
WORKDIR /src

ARG SRC_ARCHIVE_URL
ARG TARGET_TRIPLE

ADD ${SRC_ARCHIVE_URL} /tmp/src.tar.gz

RUN mkdir -p /src && \
    tar -xzf /tmp/src.tar.gz -C /src --strip-components=1

ENV RUSTFLAGS="-C target-feature=+crt-static"

RUN cargo build --release --target ${TARGET_TRIPLE}

RUN mkdir -p /out && \
    cp "target/${TARGET_TRIPLE}/release/slp-server-rust" /out/slp-server-rust

FROM alpine

COPY --from=builder /out/slp-server-rust /usr/local/bin/slp-server-rust

ENTRYPOINT ["/usr/local/bin/slp-server-rust"]
