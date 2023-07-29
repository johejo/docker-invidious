FROM crystallang/crystal:1.9.2-alpine as builder
RUN apk add --no-cache sqlite-static yaml-static
WORKDIR /invidious
RUN git clone --depth=1 https://github.com/iv-org/invidious.git . && \
    shards install --production && \
    sed -i -e 's/negotiate_ssl if.*//g' ./lib/pg/src/pq/connection.cr
RUN crystal build ./src/invidious.cr \
      --release \
      --static \
      --warnings all \
      -Ddisable_quic \
      --link-flags "-lxml2 -llzma"

FROM alpine:3.18
RUN apk add --no-cache tini
WORKDIR /invidious
COPY --from=builder /invidious/config/sql ./config/sql
COPY --from=builder /invidious/assets ./assets
COPY --from=builder /invidious/locales ./locales
COPY --from=builder /invidious/invidious ./invidious
ENTRYPOINT [ "tini", "--" ]
CMD [ "/invidious/invidious" ]
