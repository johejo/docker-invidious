FROM crystallang/crystal:1.10.1-alpine as builder
RUN apk add --no-cache sqlite-static yaml-static
WORKDIR /invidious
RUN git clone --depth=1 https://github.com/iv-org/invidious.git . && \
    shards install --production && \
    crystal build ./src/invidious.cr \
      --release \
      --static \
      --warnings all \
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
