#!/bin/bash
# manage-ssl-certs.sh - Check and manage SSL certificates
# This script checks if SSL certificates exist, if they're expiring soon, and renews them if needed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${HOME}/app"
DOMAIN_VARS_FILE="${APP_DIR}/scripts/nginx/domain-variables.sh"

# Source domain variables if available
if [ -f "$DOMAIN_VARS_FILE" ]; then
  source "$DOMAIN_VARS_FILE"
fi

# Check if domains are set
if [ -z "$DOMAIN_NAME" ]; then
  echo "ERROR: DOMAIN_NAME environment variable not set."
  echo "Please either:"
  echo "  1. Run this script from a deployment with domain-variables.sh, or"
  echo "  2. Provide domains as arguments: manage-ssl-certs.sh domain.com [staging.domain.com] [email@domain.com]"
  
  # If arguments were provided, use them
  if [ $# -gt 0 ]; then
    PRIMARY_DOMAIN=$1
    shift
    echo "Using command line arguments with primary domain: $PRIMARY_DOMAIN"
  else
    exit 1
  fi
else
  PRIMARY_DOMAIN=$DOMAIN_NAME
  echo "Using domain from environment: $PRIMARY_DOMAIN"
fi

# Make check-ssl-certs.sh executable
chmod +x "${SCRIPT_DIR}/check-ssl-certs.sh"

# Check current certificate status
echo "Checking SSL certificate status..."
STATUS=$("${SCRIPT_DIR}/check-ssl-certs.sh" 2>&1) || true
CERT_STATUS=$?

# Process based on certificate status
case $CERT_STATUS in
  0)
    echo "Certificate is valid and not expiring soon."
    echo "$STATUS"
    ;;
  1)
    echo "SSL certificates not found. Obtaining new certificates..."
    chmod +x "${SCRIPT_DIR}/renew-ssl-certs.sh"
    
    if [ $# -gt 0 ]; then
      # Use command line arguments
      "${SCRIPT_DIR}/renew-ssl-certs.sh" "$@"
    else
      # Use environment variables
      "${SCRIPT_DIR}/renew-ssl-certs.sh" "$DOMAIN_NAME" "$STAGING_DOMAIN_NAME" 
    fi
    ;;
  2|3)
    echo "Certificate is expiring soon or already expired."
    echo "$STATUS"
    echo "Renewing certificates..."
    chmod +x "${SCRIPT_DIR}/renew-ssl-certs.sh"
    
    if [ $# -gt 0 ]; then
      # Use command line arguments
      "${SCRIPT_DIR}/renew-ssl-certs.sh" "$@"
    else
      # Use environment variables
      "${SCRIPT_DIR}/renew-ssl-certs.sh" "$DOMAIN_NAME" "$STAGING_DOMAIN_NAME"
    fi
    ;;
  *)
    echo "Unknown status code: $CERT_STATUS"
    echo "$STATUS"
    exit 1
    ;;
esac

exit 0