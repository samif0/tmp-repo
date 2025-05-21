#!/bin/bash
# This script ensures required remote directories exist before SCP transfers

# Usage: ./ensure-remote-dirs.sh user@host
# Example: ./ensure-remote-dirs.sh ubuntu@example.com

if [ -z "$1" ]; then
    echo "Error: Remote host not specified"
    echo "Usage: $0 user@host"
    exit 1
fi

REMOTE_HOST="$1"

# Create required directories on remote host
ssh "$REMOTE_HOST" "mkdir -p /home/\$(whoami)/app/nginx/conf.d"

# Check if directory was created successfully
if ssh "$REMOTE_HOST" "[ -d /home/\$(whoami)/app/nginx ]"; then
    echo "Remote directories successfully created"
    exit 0
else
    echo "Failed to create remote directories"
    exit 1
fi