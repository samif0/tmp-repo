#!/bin/bash

cat >nginx/conf.d/default.conf <<EOF

server {
    listen 80;
    server_name $PROD_HOST;
    
    location / {
        proxy_pass http://blackflow-prod:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

# Staging server
server {
    listen 8080;
    server_name $PROD_HOST;
    
    location / {
        proxy_pass http://blackflow-staging:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

# Default server
server {
    listen 80 default_server;
    server_name _;
    
    location / {
        return 404;
    }
}
EOF
