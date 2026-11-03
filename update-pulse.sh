#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${EUID} -eq 0 ]] || { echo "Run as root"; exit 1; }
cd /opt/pulse
docker compose config --quiet
echo "Current image:"
docker inspect pulse --format '{{.Config.Image}}' 2>/dev/null || true
docker compose pull pulse
docker compose up -d --no-deps pulse
docker compose ps
echo "Updated image:"
docker inspect pulse --format '{{.Image}}' 2>/dev/null || true
