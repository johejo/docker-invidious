FROM crystallang/crystal:1.8.2 as builder
RUN apt-get update && \
    apt-get install -y \
      liblzma-dev \
      libsqlite3-dev \
      --no-install-recommends --no-install-suggests && \
    apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/*
WORKDIR /invidious
RUN git clone --depth=1 https://github.com/iv-org/invidious.git . && \
    shards install --production && \
    sed -i -e 's/(TCPSocket)/(TCPSocket) && @conninfo.sslmode != :disable/g' ./lib/pg/src/pq/connection.cr && \
    crystal build ./src/invidious.cr \
      --release \
      -Ddisable_quic \
      --link-flags "-lxml2 -llzma"

FROM bitnami/minideb
RUN install_packages libxml2 libyaml-0-2 libssl3 libcrypto++8 libevent-2.1-7 libsqlite3-0
WORKDIR /invidious
COPY --from=builder /invidious/config/sql ./config/sql
COPY --from=builder /invidious/assets ./assets
COPY --from=builder /invidious/locales ./locales
COPY --from=builder /invidious/invidious ./invidious
