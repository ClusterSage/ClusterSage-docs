#!/usr/bin/env bash
set -euo pipefail
APP_DIR=${APP_DIR:-/opt/clusterwatch}
sudo mkdir -p "$APP_DIR"
sudo cp docker-compose.prod.yml "$APP_DIR/docker-compose.yml"
sudo cp .env "$APP_DIR/.env"
cd "$APP_DIR"
sudo docker compose pull
sudo docker compose up -d
sudo docker compose exec backend alembic upgrade head
