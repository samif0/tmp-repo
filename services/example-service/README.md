# Example Service

This is an example backend service for the Blackflow architecture.

## Local Development

### Prerequisites
- Node.js (v16+)
- npm or yarn

### Setup
1. Install dependencies:
```bash
cd services/example-service
npm install
```

2. Start the service in development mode:
```bash
npm run dev
```

3. The service will be available at http://localhost:3000

## Testing the API

You can test the service using curl, Postman, or any API client.

### Health Check
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2023-05-19T12:34:56.789Z"
}
```

### Example API Endpoint
```bash
curl http://localhost:3000/api/v1/example
```

Expected response:
```json
{
  "message": "Example API response",
  "timestamp": "2023-05-19T12:34:56.789Z"
}
```

### Resource API Endpoints

GET all resources:
```bash
curl http://localhost:3000/api/v1/resource
```

GET specific resource:
```bash
curl http://localhost:3000/api/v1/resource/1
```

Create a new resource:
```bash
curl -X POST http://localhost:3000/api/v1/resource \
  -H "Content-Type: application/json" \
  -d '{"name": "New Resource"}'
```

Update a resource:
```bash
curl -X PUT http://localhost:3000/api/v1/resource/1 \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Resource"}'
```

Delete a resource:
```bash
curl -X DELETE http://localhost:3000/api/v1/resource/1
```

## Docker Testing

1. Build the Docker image:
```bash
cd /root/blackflow
docker build -t example-service ./services/example-service
```

2. Run the container:
```bash
docker run -p 3010:3000 example-service
```

3. Test the API as described above, but using port 3010:
```bash
curl http://localhost:3010/health
```

## Testing with Docker Compose

1. Start all services using Docker Compose:
```bash
cd /root/blackflow
docker-compose up -d
```

2. Test the example service directly:
```bash
curl http://localhost:3010/health
```

3. Test via Nginx (if configured):
```bash
curl http://localhost/api/example/health
```

## Integration Testing

Once the service is integrated with the main application, you can test it through the frontend by making requests to:

- `/api/example/resource` - This will be routed to the example service's `/api/v1/resource` endpoint
