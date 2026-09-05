#!/bin/bash
# =============================================================================
# Script de inicialización de PostgreSQL para Investment Tracker
# Se ejecuta automáticamente al iniciar el contenedor (solo en primera inicialización)
# =============================================================================
echo "🚀 [$(date '+%Y-%m-%d %H:%M:%S')] Iniciando contenedor PostgreSQL..."

set -e

echo "🚀 [init.sh] Iniciando script de inicialización..."

# Esperar a que PostgreSQL esté listo para aceptar conexiones
MAX_RETRIES=30
RETRY_COUNT=0
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "❌ [init.sh] Tiempo de espera agotado para PostgreSQL."
        exit 1
    fi
    echo "⏳ [init.sh] Esperando a que PostgreSQL esté listo... (intento $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

echo "✅ [init.sh] PostgreSQL está listo."

# Verificar si el esquema ya existe
SCHEMA_EXISTS=$(psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name = 'investment_tracker'")

if [ "$SCHEMA_EXISTS" = "1" ]; then
    echo "✅ [init.sh] El esquema 'investment_tracker' ya existe. No se realizarán cambios."
    echo "   (Base de datos existente preservada)"
    exit 0
fi

echo "⚠️  [init.sh] El esquema 'investment_tracker' NO existe. Instalando desde cero..."
echo "📦 [init.sh] Ejecutando /scripts/sql/aplica.sql ..."

if [ -f /scripts/sql/aplica.sql ]; then
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /scripts/sql/aplica.sql
    echo "✅ [init.sh] Instalación completada exitosamente."
else
    echo "❌ [init.sh] No se encontró /scripts/sql/aplica.sql"
    exit 1
fi