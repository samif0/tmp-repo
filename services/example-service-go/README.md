# Example Service (Go)

A simple REST API service implemented in Go with Gin framework.

## Endpoints

- `GET /health` - Health check endpoint
- `GET /api/v1/example` - Example API endpoint
- `GET /api/v1/resource` - List resources
- `GET /api/v1/resource/:id` - Get resource by ID
- `POST /api/v1/resource` - Create a new resource
- `PUT /api/v1/resource/:id` - Update resource
- `DELETE /api/v1/resource/:id` - Delete resource

## Development

### Local Development

```bash
# Run locally
go run main.go

# Build the binary
go build -o example-service .
```

### Docker

```bash
# Build Docker image
docker build -t blackflow/example-service-go .

# Run Docker container
docker run -p 3010:3000 blackflow/example-service-go
```

## API Testing

Use the provided test script:

```bash
PORT=3010 ./test-service.sh
```