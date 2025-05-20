#!/bin/bash
# renew-ssl-certs.sh - Renew SSL certificates if they are expiring or don't exist
# Usage: ./renew-ssl-certs.sh [domain.com] [optional-additional-domain.com] [optional-email@domain.com]

set -e

# Base directory paths
APP_DIR="${HOME}/app"
CERT_DIR="${APP_DIR}/nginx/ssl"
DOMAIN_VARS_FILE="${APP_DIR}/scripts/nginx/domain-variables.sh"

# Source domain variables if available
if [ -f "$DOMAIN_VARS_FILE" ]; then
  source "$DOMAIN_VARS_FILE"
fi

# Primary domain is either passed as argument or from environment variable
PRIMARY_DOMAIN=${1:-$DOMAIN_NAME}
if [ -z "$PRIMARY_DOMAIN" ]; then
  echo "ERROR: No domain specified. Please provide domain as an argument or ensure DOMAIN_NAME is set."
  exit 1
fi

# Process additional domains and email
shift
DOMAIN_ARGS="-d $PRIMARY_DOMAIN"
EMAIL=""
DOMAINS=()

# Check if arguments were provided
if [ $# -gt 0 ]; then
  while [ $# -gt 0 ]; do
    if [[ "$1" == *"@"* ]]; then
      EMAIL="$1"
      shift
    else
      DOMAINS+=("$1")
      DOMAIN_ARGS="$DOMAIN_ARGS -d $1"
      shift
    fi
  done
else
  # If no additional args, check for staging domain
  if [ -n "$STAGING_DOMAIN_NAME" ]; then
    DOMAINS+=("$STAGING_DOMAIN_NAME")
    DOMAIN_ARGS="$DOMAIN_ARGS -d $STAGING_DOMAIN_NAME"
  fi
fi

# Set default email if none was provided
if [ -z "$EMAIL" ]; then
  EMAIL="admin@$PRIMARY_DOMAIN"
  echo "No email provided, using default: $EMAIL"
fi

echo "=== Renewing Let's Encrypt certificates for $PRIMARY_DOMAIN ==="
echo "Additional domains: ${DOMAINS[*]}"

# Ensure Certbot is installed
if ! command -v certbot &> /dev/null; then
  echo "Installing Certbot..."
  sudo apt update
  sudo apt install -y certbot python3-certbot-nginx
fi

# Check if Nginx is running
if systemctl is-active --quiet nginx; then
  echo "Nginx is running. Using Nginx plugin for Certbot..."
  
  # Obtain or renew certificates using Nginx plugin
  sudo certbot --nginx $DOMAIN_ARGS --non-interactive --agree-tos --email $EMAIL
else
  echo "Nginx is not running. Using standalone mode for Certbot..."
  
  # Stop running Nginx containers if they exist
  if docker ps | grep -q nginx; then
    echo "Stopping Nginx containers temporarily..."
    docker stop $(docker ps -q --filter name=nginx) || true
  fi
  
  # Obtain or renew certificates in standalone mode
  sudo certbot certonly --standalone $DOMAIN_ARGS --non-interactive --agree-tos --email $EMAIL
  
  # Restart Nginx containers if they were stopped
  if docker ps -a | grep -q nginx; then
    echo "Restarting Nginx containers..."
    docker start $(docker ps -a -q --filter name=nginx) || true
  fi
fi

# Check if certificates were obtained successfully
if [ ! -d "/etc/letsencrypt/live/$PRIMARY_DOMAIN" ]; then
  echo "Failed to obtain certificates. Check the Certbot output for errors."
  exit 1
fi

# Create app directories if they don't exist
echo "Setting up application directories..."
mkdir -p $CERT_DIR

# Copy certificates to app directory
echo "Copying certificates to application directory..."
sudo cp /etc/letsencrypt/live/$PRIMARY_DOMAIN/fullchain.pem $CERT_DIR/cert.pem
sudo cp /etc/letsencrypt/live/$PRIMARY_DOMAIN/privkey.pem $CERT_DIR/key.pem

echo "Setting proper permissions..."
sudo chown $USER:$USER $CERT_DIR/*.pem
sudo chmod 600 $CERT_DIR/*.pem

# Restart nginx container if running with Docker Compose
if [ -f "$APP_DIR/docker-compose.merged.yml" ]; then
  echo "Restarting Nginx container to apply new certificates..."
  cd $APP_DIR && docker-compose -f docker-compose.merged.yml restart nginx || true
fi

echo "=== SSL certificate renewal complete! ==="
echo "Certificates installed: $CERT_DIR/cert.pem and $CERT_DIR/key.pem"