#!/bin/bash
# =============================================
# RESET-PGADMIN.SH - Reset de pgAdmin (mantiene BD)
# Uso: ./reset-pgadmin.sh
# =============================================

echo "🗑️  RESET DE PGADMIN"
echo "===================="

cd "$(dirname "$0")/.."

echo ""
echo "1. Deteniendo pgAdmin y eliminando su volumen..."
docker compose stop pgadmin
docker compose rm -f pgadmin
docker volume rm -f investment_pgadmin_data 2>/dev/null

echo ""
echo "2. Recreando pgAdmin..."
docker compose up -d pgadmin

echo ""
echo "3. Esperando inicio (5s)..."
sleep 5

echo ""
echo "✅ pgAdmin reiniciado"
echo "   URL: http://localhost:5050"
echo "   Email: admin@investment-tracker.com"
echo "   Password: Admin123!"
