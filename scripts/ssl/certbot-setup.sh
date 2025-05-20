#!/bin/bash
# certbot-setup.sh - Automated Let's Encrypt certificate setup script
# Usage: ./certbot-setup.sh yourdomain.com [additional.domain.com] [email@address]

set -e

# Check if at least one domain was provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 yourdomain.com [additional.domain.com ...] [email@address]"
  exit 1
fi

# Primary domain is the first argument
PRIMARY_DOMAIN=$1
DOMAIN_ARGS="-d $PRIMARY_DOMAIN"
shift

# Process additional domains until we find an email address
EMAIL=""
DOMAINS=()
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

# Set default email if none was provided
if [ -z "$EMAIL" ]; then
  EMAIL="admin@$PRIMARY_DOMAIN"
  echo "No email provided, using default: $EMAIL"
else
  echo "Using email: $EMAIL"
fi

echo "=== Setting up Let's Encrypt certificates for $PRIMARY_DOMAIN ==="
echo "Additional domains: ${DOMAINS[*]}"

echo "Updating package lists..."
sudo apt update

echo "Installing Certbot..."
sudo apt install -y certbot python3-certbot-nginx

if systemctl is-active --quiet nginx; then
  echo "Nginx is running. Using Nginx plugin for Certbot..."

  echo "Getting certificates via Nginx plugin..."
  sudo certbot --nginx $DOMAIN_ARGS --non-interactive --agree-tos --email $EMAIL

else
  echo "Nginx is not running. Using standalone mode for Certbot..."

  echo "Getting certificates in standalone mode..."
  sudo certbot certonly --standalone $DOMAIN_ARGS --non-interactive --agree-tos --email $EMAIL
fi

# Check if certificates were obtained successfully
if [ ! -d "/etc/letsencrypt/live/$PRIMARY_DOMAIN" ]; then
  echo "Failed to obtain certificates. Check the Certbot output for errors."
  exit 1
fi

# Create app directories if they don't exist
echo "Setting up application directories..."
mkdir -p ~/app/nginx/ssl

# Copy certificates to app directory
echo "Copying certificates to application directory..."
sudo cp /etc/letsencrypt/live/$PRIMARY_DOMAIN/fullchain.pem ~/app/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/$PRIMARY_DOMAIN/privkey.pem ~/app/nginx/ssl/key.pem

echo "Setting proper permissions..."
sudo chown $USER:$USER ~/app/nginx/ssl/*.pem
sudo chmod 600 ~/app/nginx/ssl/*.pem

# Create a script for certificate renewal
echo "Creating certificate renewal script..."
cat >~/renew-certs.sh <<EOF
#!/bin/bash
# This script is called after certificate renewal to copy new certificates to the app directory

# Renew certificates
sudo certbot renew --quiet

# Copy new certificates to app directory
sudo cp /etc/letsencrypt/live/$PRIMARY_DOMAIN/fullchain.pem ~/app/nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/$PRIMARY_DOMAIN/privkey.pem ~/app/nginx/ssl/key.pem

# Set proper permissions
sudo chown $USER:$USER ~/app/nginx/ssl/*.pem
sudo chmod 600 ~/app/nginx/ssl/*.pem

# Restart Nginx container to pick up new certificates
cd ~/app && docker-compose restart nginx
EOF

# Make the renewal script executable
chmod +x ~/renew-certs.sh

# Create a cron job to run the renewal script
echo "Setting up automatic renewal with cron..."
(
  crontab -l 2>/dev/null || true
  echo "0 3 * * * ~/renew-certs.sh"
) | crontab -

echo "=== Let's Encrypt setup complete! ==="
echo "Certificates installed: ~/app/nginx/ssl/cert.pem and ~/app/nginx/ssl/key.pem"
echo "Automatic renewal has been configured to run daily at 3 AM"
echo "You may need to restart your Nginx container to apply the certificates"
