#!/bin/bash

# Test script for example service

echo "Testing example service..."

# Check if service is running on port 3000 or 3010
PORT=3000
if curl -s http://localhost:3000/health >/dev/null; then
  PORT=3000
  echo "Service detected on port 3000"
elif curl -s http://localhost:3010/health >/dev/null; then
  PORT=3010
  echo "Service detected on port 3010"
else
  echo "Error: Service not detected on port 3000 or 3010"
  echo "Please start the service first with 'npm run dev' or docker"
  exit 1
fi

# Test health endpoint
echo -e "\n1. Testing health endpoint..."
curl -s http://localhost:$PORT/health | jq || echo "Failed to reach health endpoint"

# Test example endpoint
echo -e "\n2. Testing example endpoint..."
curl -s http://localhost:$PORT/api/v1/example | jq || echo "Failed to reach example endpoint"

# Test resource endpoints
echo -e "\n3. Testing resource listing..."
curl -s http://localhost:$PORT/api/v1/resource | jq || echo "Failed to reach resource endpoint"

echo -e "\n4. Testing resource by ID..."
curl -s http://localhost:$PORT/api/v1/resource/1 | jq || echo "Failed to reach resource endpoint"

echo -e "\n5. Testing resource creation..."
curl -s -X POST http://localhost:$PORT/api/v1/resource \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Resource"}' | jq || echo "Failed to create resource"

echo -e "\n6. Testing resource update..."
curl -s -X PUT http://localhost:$PORT/api/v1/resource/1 \
  -H "Content-Type: application/json" \
  -d '{"name": "Updated Resource"}' | jq || echo "Failed to update resource"

echo -e "\n7. Testing resource deletion..."
curl -s -X DELETE http://localhost:$PORT/api/v1/resource/1 | jq || echo "Failed to delete resource"

echo -e "\nAll tests completed!"

