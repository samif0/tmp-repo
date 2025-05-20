#!/bin/bash
# check-ssl-certs.sh - Check if SSL certificates exist and if they need renewal
# Returns:
#   0 - Certificates exist and are valid for more than 7 days
#   1 - Certificates don't exist
#   2 - Certificates exist but expire within 7 days
#   3 - Certificates are expired

set -e

# Directory where certificates are stored
CERT_DIR="${HOME}/app/nginx/ssl"
CERT_FILE="${CERT_DIR}/cert.pem"
KEY_FILE="${CERT_DIR}/key.pem"

# Check if certificate files exist
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
  echo "SSL certificates not found in ${CERT_DIR}"
  exit 1
fi

# Check certificate expiration date
if ! command -v openssl &> /dev/null; then
  echo "OpenSSL not found. Installing..."
  sudo apt-get update && sudo apt-get install -y openssl
fi

# Get certificate expiration date
EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
CURRENT_EPOCH=$(date +%s)
SECONDS_REMAINING=$((EXPIRY_EPOCH - CURRENT_EPOCH))
DAYS_REMAINING=$((SECONDS_REMAINING / 86400))

# Check if certificate is already expired
if [ $DAYS_REMAINING -le 0 ]; then
  echo "SSL certificate is expired! Expired on: $EXPIRY_DATE"
  exit 3
fi

# Check if certificate expires within 7 days
if [ $DAYS_REMAINING -le 7 ]; then
  echo "SSL certificate will expire in $DAYS_REMAINING days (on $EXPIRY_DATE)"
  exit 2
fi

echo "SSL certificate is valid for $DAYS_REMAINING more days (expires on $EXPIRY_DATE)"
exit 0