#!/bin/bash
# =============================================
# BACKUP-DB.SH - Backup de la base de datos
# Uso: ./backup-db.sh
# =============================================

BACKUP_DIR="../backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/investment_tracker_$TIMESTAMP.sql"

mkdir -p "$BACKUP_DIR"

echo "💾 BACKUP DE BASE DE DATOS"
echo "=========================="
echo "Fecha: $(date)"
echo "Archivo: $BACKUP_FILE"
echo ""

docker compose exec -T postgres pg_dump -U investor investment_tracker > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Backup exitoso: $BACKUP_FILE"
    ls -lh "$BACKUP_FILE"
else
    echo "❌ Error en el backup"
    exit 1
fi
