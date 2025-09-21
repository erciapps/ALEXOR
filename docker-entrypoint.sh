#!/bin/bash
set -e

DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}

echo "⏳ Esperando a que PostgreSQL esté listo en $DB_HOST:$DB_PORT..."
until nc -z $DB_HOST $DB_PORT; do
  sleep 2
done

echo "✅ PostgreSQL está disponible, arrancando Tomcat..."
exec catalina.sh run
