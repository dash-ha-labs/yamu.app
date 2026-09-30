#!/bin/bash
set -e

# Load token
source ~/.hermes/.env

URL="${DOKPLOY_URL:-http://localhost:3000}"
TOKEN="$DOKPLOY_TOKEN"

echo "Building Vite app..."
npm run build

echo "Zipping dist..."
cd dist && tar -czf ../deploy.tar.gz . && cd ..

# Authenticate Dokploy CLI
echo "Authenticating Dokploy CLI..."
npx --yes @dokploy/cli auth -u "$URL" -t "$TOKEN"

# Try to create app if doesn't exist
npx --yes @dokploy/cli application create \
  --name yamu \
  --appName yamu \
  --sourceType drop \
  --description "Yamu Vite App" || true

# Note: The Dokploy CLI does not fully support file upload for drop deployments yet.
# In a real scenario with a reachable server, you'd POST the zip to the drop endpoint:
# curl -X POST "$URL/api/application.uploadDrop" \
#  -H "Authorization: Bearer $TOKEN" \
#  -F "file=@deploy.tar.gz" \
#  -F "applicationId=yamu"

echo "Triggering deploy..."
npx --yes @dokploy/cli application deploy --applicationId yamu
