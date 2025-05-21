#!/bin/bash

sudo mkdir -p nginx/conf.d

sudo ./scripts/nginx/create-nginx-conf.sh
sudo ./scripts/nginx/create-server-blocks.sh

echo "Nginx setup completed"
