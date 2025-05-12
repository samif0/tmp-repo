#!/bin/bash

docker-compose down --remove-orphans
docker rm -f $(docker ps -a -q --filter name=blackflow) 2>/dev/null || true
docker rmi -f $(docker images -q blackflow) 2>/dev/null || true
docker system prune -af --volumes

docker image rm $(docker images -q *blackflow* 2>/dev/null) 2>/dev/null || true

echo "Docker cleanup completed"
