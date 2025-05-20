FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

# Build the application with optimizations
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o auth .

FROM alpine:3.18

WORKDIR /app

# Add ca-certificates for HTTPS and tzdata for timezone information
RUN apk --no-cache add ca-certificates tzdata wget

# Copy the binary from the builder stage
COPY --from=builder /app/auth .

ENV GIN_MODE=release
ENV PORT=3000

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget --spider -q http://localhost:3000/health || exit 1

CMD ["./auth"]
