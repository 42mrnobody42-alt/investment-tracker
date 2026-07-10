#!/bin/bash
# =============================================
# RESET-ALL.SH - Reset de base de datos (mantiene pgadmin)
# Uso: ./reset-all.sh
# =============================================

echo "🗑️  RESET DE BASE DE DATOS"
echo "=========================="

cd "$(dirname "$0")/.."

echo ""
echo "1. Deteniendo PostgreSQL y eliminando su volumen..."
docker compose stop postgres
docker compose rm -f postgres
docker volume rm -f investment_postgres_data 2>/dev/null

echo ""
echo "2. Recreando PostgreSQL..."
docker compose up -d postgres

echo ""
echo "3. Esperando inicialización (20s)..."
sleep 20

echo ""
echo "4. Verificando instalación..."
./shellTest/check-all.sh
