#!/bin/bash

cd ~/app

if [ -d "blackflow" ]; then
  cd blackflow
  git pull
else
  git clone https://github.com/samif0/blackflow.git blackflow
  cd blackflow
fi

cp docker-compose.yml ../ || echo "No docker-compose.yml to copy"

cd ..

mv ~/docker-compose.prod.yml ./
mv ~/nginx ./

# TODO: Add service-specific environment file setup
# For example, copy .env files for each service
# cp ~/service-secrets/example-service.env ./services/example-service/.env

# TODO: Create database initialization scripts if needed
# mkdir -p ./db/init
# cp ~/db-init-scripts/* ./db/init/

./scripts/cleanup/cleanup-docker.sh

# TODO: Add pre-deployment steps if needed
# For example, database migrations
# docker-compose -f docker-compose.merged.yml run --rm example-service npm run migrate

# Build and start all services
docker-compose -f docker-compose.merged.yml -f docker-compose.prod.yml up -d --build

# Post-deployment verification steps
echo "Checking service health..."
sleep 15  # Give services time to start up

# Check main app health
curl -s http://localhost:3000/api/health | grep "healthy" || echo "Main app is not healthy!"

# Check auth service health
curl -s http://localhost:3003/health | grep "healthy" || echo "Auth service is not healthy!"

# Clean up unused images
docker image prune -af --force

echo "Consolidated deployment complete!"