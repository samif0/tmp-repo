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

# Ensure SSL directory exists
mkdir -p ./nginx/ssl

# Copy SSL certificates from Let's Encrypt to the nginx ssl directory
if [ -d "/etc/letsencrypt/live/blackflowlabs.com" ]; then
  echo "Copying SSL certificates for blackflowlabs.com"
  sudo cp /etc/letsencrypt/live/blackflowlabs.com/fullchain.pem ./nginx/ssl/cert.pem
  sudo cp /etc/letsencrypt/live/blackflowlabs.com/privkey.pem ./nginx/ssl/key.pem
  sudo chown $USER:$USER ./nginx/ssl/*.pem
  sudo chmod 600 ./nginx/ssl/*.pem
else
  echo "Warning: SSL certificates for blackflowlabs.com not found"
fi

./scripts/cleanup/cleanup-docker.sh

docker-compose -f docker-compose.merged.yml -f docker-compose.prod.yml up -d --build

docker image prune -af --force

echo "Consolidated deployment complete!"
