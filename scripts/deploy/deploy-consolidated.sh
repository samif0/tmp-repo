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

./scripts/cleanup/cleanup-docker.sh

docker-compose -f docker-compose.merged.yml -f docker-compose.prod.yml up -d --build

docker image prune -af --force

echo "Consolidated deployment complete!"
