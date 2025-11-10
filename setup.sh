#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_CMD=""

# Detect Docker Compose
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "Docker Compose not found. Please install Docker Desktop or Compose plugin."
  exit 1
fi

mkdir -p "$ROOT_DIR/logs"

echo "🛠️  Building images..."
$COMPOSE_CMD build --pull

echo "🚀 Starting services..."
$COMPOSE_CMD up -d

wait_for_health() {
  local name="$1"
  local timeout=${2:-120}
  local elapsed=0
  echo "⏳ Waiting for $name to be healthy..."
  while [ $elapsed -lt $timeout ]; do
    cid=$(docker ps -aqf "name=$name")
    [ -z "$cid" ] && sleep 3 && continue
    health=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$cid")
    if [ "$health" = "healthy" ]; then
      echo "✅ $name is healthy"
      return 0
    fi
    sleep 5
    elapsed=$((elapsed+5))
  done
  echo "⚠️  $name not healthy after $timeout seconds"
  return 1
}

# Check container health
for svc in redis sample-app nginx jenkins; do
  wait_for_health "$svc" 180 || true
done

echo "📜 Collecting logs..."
for svc in jenkins redis sample-app nginx; do
  docker logs "$svc" > "logs/${svc}.log" 2>&1 || true
done

echo
echo "✅ All services are up and running!"
$COMPOSE_CMD ps

echo
echo "🌍 Access URLs:"
echo "- Flask App:       http://localhost:5001"
echo "- Nginx Proxy:     http://localhost"
echo "- Jenkins:         http://localhost:8080"
echo "- Redis (CLI):     localhost:6379"
