#!/bin/bash

echo "🔍 DIAGNÓSTICO DE BASE DE DATOS"
echo "================================================"

echo ""
echo "1. Verificando versiones instaladas:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT * FROM investment_tracker.schema_version ORDER BY id;
SQL

echo ""
echo "2. Verificando tablas existentes:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'investment_tracker' 
ORDER BY table_name;
SQL

echo ""
echo "3. Contenido de tablas:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT 'Roles: ' || COUNT(*) as info FROM investment_tracker.roles
UNION ALL
SELECT 'Usuarios: ' || COUNT(*) FROM investment_tracker.usuarios
UNION ALL
SELECT 'Plataformas: ' || COUNT(*) FROM investment_tracker.plataformas
UNION ALL
SELECT 'Comisiones: ' || COUNT(*) FROM investment_tracker.comisiones
UNION ALL
SELECT 'Transacciones: ' || COUNT(*) FROM investment_tracker.transacciones;
SQL

echo ""
echo "4. Revisando logs de inicialización:"
docker compose logs postgres 2>&1 | grep -i "notice\|error\|warning" | tail -30

echo ""
echo "================================================"