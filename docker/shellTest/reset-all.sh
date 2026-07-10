#!/bin/bash
# =============================================
# RESET-ALL.SH - Destruir y recrear todo desde cero
# Uso: ./reset-all.sh
# =============================================

echo "🗑️  RESET COMPLETO DEL SISTEMA"
echo "==============================="

cd "$(dirname "$0")/.."

echo ""
echo "1. Deteniendo y eliminando contenedores y volúmenes..."
docker compose down -v

echo ""
echo "2. Recreando servicios..."
docker compose up -d postgres pgadmin

echo ""
echo "3. Esperando inicialización (20s)..."
sleep 20

echo ""
echo "4. Verificando instalación..."
./shellTest/check-all.sh
