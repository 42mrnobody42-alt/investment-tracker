#!/bin/bash
# =============================================
# RESTORE-DB.SH - Restaurar base de datos desde backup
# Uso: ./restore-db.sh <archivo_backup.sql>
# =============================================

if [ -z "$1" ]; then
    echo "❌ Uso: ./restore-db.sh <archivo_backup.sql>"
    echo "Backups disponibles:"
    ls -lh ../backups/ 2>/dev/null || echo "  No hay backups en ../backups/"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Archivo no encontrado: $BACKUP_FILE"
    exit 1
fi

echo "📥 RESTAURANDO BASE DE DATOS"
echo "============================="
echo "Archivo: $BACKUP_FILE"
echo ""

# Primero eliminar datos existentes
echo "1. Eliminando datos existentes..."
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
DROP SCHEMA IF EXISTS investment_tracker CASCADE;
SQL

# Restaurar
echo "2. Restaurando backup..."
cat "$BACKUP_FILE" | docker compose exec -T postgres psql -U investor -d investment_tracker

if [ $? -eq 0 ]; then
    echo "✅ Restauración exitosa"
else
    echo "❌ Error en la restauración"
    exit 1
fi
