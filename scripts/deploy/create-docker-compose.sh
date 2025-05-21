#!/bin/bash

cat >docker-compose.merged.yml <<'EOF'
version: '3'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - blackflow-prod
      - blackflow-staging
      - auth-service
    networks:
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
      - backend
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
      - backend
    restart: unless-stopped

  auth-service:
    build:
      context: ./auth-service
      dockerfile: Dockerfile
    expose:
      - "8080"
    networks:
      - backend
    restart: unless-stopped

networks:
  backend:
    driver: bridge
EOF

echo "Docker Compose configuration created"
