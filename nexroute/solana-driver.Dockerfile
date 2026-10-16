# syntax=docker/dockerfile:1.7
# Nexroute: solana-driver image (CoW Solana driver). Built by
# .github/workflows/nexroute-solana-driver.yml and nexroute-release.yml.
#
# Builds ONLY solana-driver (the root Dockerfile compiles every workspace
# binary). cargo-chef splits the build so the dependency compile is its own
# layer: with the GitHub Actions layer cache, a code-only change rebuilds just
# the driver. Rust 1.97.1 = the toolchain the Solana router image uses.
FROM lukemathwalker/cargo-chef:latest-rust-1.97.1-bookworm AS chef
WORKDIR /src

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json --bin solana-driver

FROM chef AS build
COPY --from=planner /src/recipe.json recipe.json
RUN cargo chef cook --release --locked --recipe-path recipe.json --bin solana-driver
COPY . .
RUN cargo build --release --locked -p solana-driver --bin solana-driver \
 && install -D -m 755 target/release/solana-driver /out/solana-driver

FROM debian:bookworm-slim
# Same runtime set as the root Dockerfile's `intermediate` stage: TLS roots,
# tini (PID 1), curl (healthcheck on /healthz; brings libssl3).
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates tini curl \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /out/solana-driver /usr/local/bin/solana-driver
ENTRYPOINT ["tini", "--", "solana-driver"]
