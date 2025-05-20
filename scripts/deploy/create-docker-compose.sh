#!/bin/bash

cat >docker-compose.merged.yml <<'EOF'
version: '3'

networks:
  frontend:
  production:
  staging:

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "8080:8080"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    networks:
      - frontend
      - production
      - staging
    restart: unless-stopped
  
  blackflow-prod:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - NODE_ENV=production
    ports:
      - "3000:3000"
    environment: 
      - NODE_ENV=production
    networks:
      - production
    restart: unless-stopped
  
  blackflow-staging:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        - NODE_ENV=staging
    ports:
      - "3001:3000"
    environment: 
      - NODE_ENV=staging
    networks:
      - staging
    restart: unless-stopped
EOF

echo "Docker Compose configuration created"
