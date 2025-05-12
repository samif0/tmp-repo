#!/bin/bash

mkdir -p nginx/conf.d

./scripts/nginx/create-nginx-conf.sh
./scripts/nginx/create-server-blocks.sh

echo "Nginx setup completed"
