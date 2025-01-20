FROM golang:1.23 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN CGO_ENABLED=0 GOOS=linux go mod download

COPY . .

RUN go build -o main 

FROM debian:12-slim

WORKDIR /app

COPY --from=builder /app/main /app/main

EXPOSE 3000

ENTRYPOINT ["/app/main"]