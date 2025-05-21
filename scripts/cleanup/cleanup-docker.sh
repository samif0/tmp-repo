#!/bin/bash

sudo docker-compose down --remove-orphans
sudo docker rm -f $(sudo docker ps -a -q --filter name=blackflow) 2>/dev/null || true
sudo docker rmi -f $(sudo docker images -q blackflow) 2>/dev/null || true
sudo docker system prune -af --volumes

sudo docker image rm $(sudo docker images -q *blackflow* 2>/dev/null) 2>/dev/null || true

echo "Docker cleanup completed"
