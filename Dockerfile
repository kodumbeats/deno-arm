FROM rust:buster as build

WORKDIR /build

ENV DENO_BUILD_MODE=release
ENV DENO_VERSION=1.6.0
ENV DENO_BUILD_ARGS="target_cpu=\"arm64\" v8_target_cpu=\"arm64\""
ENV V8_FROM_SOURCE=1

RUN apt-get -qq update \
  && apt-get -yq upgrade \
  && apt-get -yq install curl ca-certificates python2-minimal libglib2.0-dev

RUN curl -fsSL https://github.com/denoland/deno/archive/v${DENO_VERSION}.tar.gz --output deno.tar.gz \
  && mkdir deno \
  && tar -xzf deno.tar.gz -C deno --strip-components 1 \
  && rustup target add aarch64-unknown-linux-gnu
  
WORKDIR /build/deno

RUN V8_FROM_SOURCE=1 cargo build --target=aarch64-unknown-linux-gnu --release --locked

# FROM alpine:3.12 as prod
# 
# ENV DENO_INSTALL_ROOT /usr/local
# ENV DENO_DIR /home/deno
# 
# RUN adduser deno -D
# COPY --chown=deno:deno --from=build /build/deno/target/debug/deno /usr/local/bin/deno
# COPY --chown=deno:deno ./entry.sh /usr/local/bin/entry.sh
# RUN chmod 755 /usr/local/bin/entry.sh
# 
# USER deno
# WORKDIR /home/deno
# 
# ENTRYPOINT ["entry.sh"]
