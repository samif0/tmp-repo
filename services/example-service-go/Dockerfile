# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go module files first and download dependencies
# This is done in a separate layer for better caching
COPY go.mod ./
RUN go mod download

# Copy source code
COPY . .

# Build the application with optimizations
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o example-service .

# Final stage - use a minimal alpine image
FROM alpine:3.18

WORKDIR /app

# Add ca-certificates for HTTPS and tzdata for timezone information
RUN apk --no-cache add ca-certificates tzdata wget

# Copy the binary from the builder stage
COPY --from=builder /app/example-service .

# Set environment variables
ENV GIN_MODE=release
ENV PORT=3000

# Expose the port
EXPOSE 3000

# Set up health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget --spider -q http://localhost:3000/health || exit 1

# Run the binary
CMD ["./example-service"]