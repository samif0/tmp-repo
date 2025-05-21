#!/bin/bash

# Install sudo if not present
which sudo > /dev/null || apt-get update && apt-get install -y sudo

# Create app directory with sudo if needed
sudo mkdir -p ~/app
cd ~/app

if [ -d "blackflow" ]; then
  cd blackflow
  sudo git pull
else
  sudo git clone https://github.com/samif0/blackflow.git blackflow
  cd blackflow
fi

sudo cp docker-compose.yml ../ || echo "No docker-compose.yml to copy"

cd ..

# Create scripts directory with proper permissions first
sudo mkdir -p scripts
sudo cp -r blackflow/scripts/* scripts/
sudo chmod -R 755 scripts

# Set up nginx directory structure and configuration files
sudo mkdir -p nginx/conf.d nginx/ssl
# Create directories where SSL certs will be stored
sudo chmod 755 nginx
sudo chmod -R 755 nginx/conf.d nginx/ssl

# Generate nginx configuration files
cd .
sudo ./scripts/nginx/create-nginx-conf.sh
sudo ./scripts/nginx/create-server-blocks.sh
sudo chmod 644 nginx/nginx.conf
sudo chmod 644 nginx/conf.d/*.conf

# Handle prod configuration files if they exist
if [ -f ~/docker-compose.prod.yml ]; then
  sudo mv ~/docker-compose.prod.yml ./
else
  echo "Warning: docker-compose.prod.yml not found in home directory"
fi

# Clean up Docker containers and run new containers
sudo ./scripts/cleanup/cleanup-docker.sh

# Create merged docker-compose file
sudo ./scripts/deploy/create-docker-compose.sh

# Make sure docker-compose.prod.yml exists, create empty one if needed
if [ ! -f docker-compose.prod.yml ]; then
  echo "Warning: docker-compose.prod.yml not found, creating empty one"
  sudo touch docker-compose.prod.yml
fi

# Start all services
sudo docker-compose -f docker-compose.merged.yml -f docker-compose.prod.yml up -d --build

sudo docker image prune -af --force

echo "Consolidated deployment complete!"
