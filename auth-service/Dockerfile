# syntax=docker/dockerfile:1
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go mod init auth-service && go mod tidy
RUN go build -o auth-service main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/auth-service .
EXPOSE 8080
CMD ["./auth-service"]
