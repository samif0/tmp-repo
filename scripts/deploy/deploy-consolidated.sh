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

sudo mv ~/docker-compose.prod.yml ./
sudo mv ~/nginx ./

# Create scripts directory with proper permissions
sudo mkdir -p scripts
sudo cp -r blackflow/scripts/* scripts/
sudo chmod -R 755 scripts

sudo ./scripts/cleanup/cleanup-docker.sh

sudo docker-compose -f docker-compose.merged.yml -f docker-compose.prod.yml up -d --build

sudo docker image prune -af --force

echo "Consolidated deployment complete!"
