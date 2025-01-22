FROM golang:1.23 AS builder

WORKDIR /app

COPY server/go.mod server/go.sum ./

RUN go mod download

COPY server .

RUN CGO_ENABLED=0 GOOS=linux go build -o main 

FROM debian:12-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

COPY --from=builder /app/main /app/main
COPY webapp/build/web /app/webapp

EXPOSE 3000

ENTRYPOINT ["/app/main"]