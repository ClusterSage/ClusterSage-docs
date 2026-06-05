#!/usr/bin/env bash
set -euo pipefail
apt-get update
apt-get install -y docker.io docker-compose-plugin nginx
mkdir -p /opt/clusterwatch
cd /opt/clusterwatch
if [ -f docker-compose.yml ]; then docker compose pull && docker compose up -d; fi
