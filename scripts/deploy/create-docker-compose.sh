#!/bin/bash

cat >docker-compose.merged.yml <<'EOF'
version: '3'

networks:
  frontend:
  production:
  staging:
  backend:
    internal: true

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
      - backend
    restart: unless-stopped
  
  blackflow-prod:
    build:
      context: ./blackflow
      dockerfile: Dockerfile
      args:
        - NODE_ENV=production
    ports:
      - "3001:3000"
    environment: 
      - NODE_ENV=production
    networks:
      - production
    restart: unless-stopped
  
  blackflow-staging:
    build:
      context: ./blackflow
      dockerfile: Dockerfile
      args:
        - NODE_ENV=staging
    ports:
      - "3002:3000"
    environment: 
      - NODE_ENV=staging
    networks:
      - staging
    restart: unless-stopped

  auth:
    build: 
      context: ./blackflow/services/auth
      dockerfile: Dockerfile
    ports:
      - "3003:3000"
    environment:
      - GIN_MODE=release
    networks:
      - backend
    restart: unless-stopped
EOF

echo "Docker Compose configuration created"
