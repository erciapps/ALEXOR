#!/usr/bin/env bash
set -e
HOST="${DB_HOST:-db}"
PORT="${DB_PORT:-5432}"

echo "⏳ Esperando a PostgreSQL en ${HOST}:${PORT}..."
for i in {1..60}; do
  if nc -z "${HOST}" "${PORT}" >/dev/null 2>&1; then
    echo "✅ PostgreSQL disponible."
    exit 0
  fi
  sleep 2
done
echo "❌ Timeout esperando PostgreSQL en ${HOST}:${PORT}"
exit 1
