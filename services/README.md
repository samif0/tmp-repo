# Blackflow Services Architecture

This directory contains backend services that run alongside the main Next.js application. Each service is containerized and deployed together with the main application.

## Service Architecture

Services are deployed in a private subnet (Docker network) and communicate with the frontend through Nginx as a reverse proxy. The architecture follows these principles:

- Each service runs in its own Docker container
- Services communicate through a private Docker network
- The frontend communicates with services through Nginx
- Services can talk to each other directly through the private network

## Adding a New Service

To add a new service to the architecture:

1. Create a new directory for your service in the `services/` directory
2. Implement your service using your preferred framework and/or language(Express.js, FastAPI, etc.)
3. Create a Dockerfile for your service
4. Update the main `docker-compose.yml` file to include your service
5. Update the Nginx configuration in `scripts/nginx/create-server-blocks.sh` to route to your service
6. Update the deployment scripts if necessary

## Service Directory Structure

A typical service should follow this structure:

```
services/
  service-name/
    Dockerfile
    package.json (or equivalent)
    src/
      main.## (main entry point)
      api/
        resource.## (resource endpoints)
```

## Service Communication

Services can communicate with each other using the service name as the hostname:

```javascript
// From one service to another
const response = await fetch('http://another-service:3000/api/resource');
```

The frontend should communicate with services through the Nginx proxy:

```javascript
// From frontend to service
const response = await fetch('/api/service-name/resource');
```

## Database and Dependencies

Services that need a database or other dependencies should:

1. Define these dependencies in the `docker-compose.yml` file
2. Use environment variables for configuration
3. Store secrets in environment files (not in the repository)

## TODO for Each New Service

When creating a new service, make sure to:

- [ ] Implement health check endpoint at `/health`
- [ ] Add proper error handling and logging
- [ ] Configure proper resource limits in Docker
- [ ] Add service-specific environment variables
- [ ] Update the deployment scripts
- [ ] Update the Nginx configuration
