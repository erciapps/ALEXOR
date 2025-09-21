#!/usr/bin/env bash
set -e

DB_HOST="${DB_HOST:-axelor-db}"
DB_PORT="${DB_PORT:-5432}"

echo "⏳ Esperando a que PostgreSQL esté listo en ${DB_HOST}:${DB_PORT}..."
for i in $(seq 1 60); do
  if nc -z "${DB_HOST}" "${DB_PORT}" >/dev/null 2>&1; then
    echo "✅ PostgreSQL está disponible, arrancando Tomcat..."
    exit 0
  fi
  sleep 2
done

echo "❌ Timeout esperando a PostgreSQL (${DB_HOST}:${DB_PORT})"
exit 1
