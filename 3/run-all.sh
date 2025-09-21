#!/bin/bash
set -euo pipefail

echo "[+] First one, with env on CLI (ephemeral container, no persistence)"
docker run --rm -d --name pg_cli \
  -e POSTGRES_USER=john \
  -e POSTGRES_DB=doe \
  -e POSTGRES_PASSWORD=johndoe \
  postgres
echo "    waiting for readiness..."
docker exec pg_cli bash -lc 'until pg_isready -U john -d doe; do sleep 1; done'
docker exec pg_cli psql -U john -d doe -c "SELECT 1;"
docker rm -f pg_cli

echo
echo "[+] Second one, with env from .env file"
docker run --rm -d --name pg_env \
  --env-file="$(pwd)/.env" \
  postgres
echo "    waiting for readiness..."
docker exec pg_env bash -lc 'until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do sleep 1; done'
docker exec pg_env psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1;"
docker rm -f pg_env

echo
echo "[+] Third one, with shared data folder here (bind ./data)"
mkdir -p data
docker run --rm -d --name pg_bind_cli \
  --env-file="$(pwd)/.env" \
  -v "$(pwd)/data":/var/lib/postgresql/data \
  postgres
echo "    waiting for readiness..."
docker exec pg_bind_cli bash -lc 'until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do sleep 1; done'
docker exec pg_bind_cli psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "CREATE TABLE IF NOT EXISTS t(x int); INSERT INTO t VALUES (42); SELECT * FROM t;"
docker rm -f pg_bind_cli
echo "    Data persisted in ./data (bind). You can relaunch to verify."

echo
echo "[+] Fourth one, with a named docker volume"
docker volume create postgres_data_vol >/dev/null
docker run --rm -d --name pg_vol_cli \
  --env-file="$(pwd)/.env" \
  --mount source=postgres_data_vol,destination=/var/lib/postgresql/data \
  postgres
echo "    waiting for readiness..."
docker exec pg_vol_cli bash -lc 'until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do sleep 1; done'
docker exec pg_vol_cli psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "CREATE TABLE IF NOT EXISTS t2(y int); INSERT INTO t2 VALUES (99); SELECT * FROM t2;"
docker rm -f pg_vol_cli
echo "    Data persisted in the docker volume 'postgres_data_vol'."
