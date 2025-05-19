#!/bin/bash

export DOMAIN_NAME="blackflowlabs.com"
export STAGING_DOMAIN_NAME="staging.${DOMAIN_NAME}"

cat >nginx/conf.d/default.conf <<EOF

server {
  listen 80;
  server_name ${DOMAIN_NAME};


  # Redirect http to https
  location / {
    return 301 https://\$host\$request_uri;
  }
}

server {
    listen 443 ssl;
    server_name ${DOMAIN_NAME};

     # SSL configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Main application
    location / {
        proxy_pass http://blackflow-prod:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    # TODO: Add additional service routes as needed
    
    # Example service API routing
    location /api/example/ {
        # Rewrite the path to remove the /api/example prefix
        rewrite ^/api/example/(.*)$ /api/v1/\$1 break;
        
        proxy_pass http://example-service:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        
        # TODO: Add service-specific headers if needed
        # proxy_set_header X-Real-IP \$remote_addr;
    }
    
    # TODO: Add more API routes for additional services
    # location /api/another-service/ {
    #     rewrite ^/api/another-service/(.*)$ /\$1 break;
    #     proxy_pass http://another-service:3000;
    #     proxy_http_version 1.1;
    #     proxy_set_header Upgrade \$http_upgrade;
    #     proxy_set_header Connection 'upgrade';
    #     proxy_set_header Host \$host;
    #     proxy_cache_bypass \$http_upgrade;
    # }
}

# Staging server
server {
    listen 80;
    server_name ${STAGING_DOMAIN_NAME};
    
    # Redirect staging HTTP to HTTPS
    location / {
        return 301 https://\$host:8443\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name ${STAGING_DOMAIN_NAME};

    # SSL configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Main application
    location / {
        proxy_pass http://blackflow-staging:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # TODO: Add staging service routes here (similar to production)
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