#!/bin/bash
# =============================================
# CHECK-ALL.SH - Verificación completa del sistema
# Uso: ./check-all.sh
# =============================================

set -e

echo "🔍 INVESTMENT TRACKER - VERIFICACIÓN COMPLETA"
echo "=============================================="
echo ""

# 1. Servicios
echo "📦 1. ESTADO DE SERVICIOS"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || {
    echo "❌ Docker no está corriendo o docker-compose no encontrado"
    exit 1
}
echo ""

# 2. Salud PostgreSQL
echo "🏥 2. SALUD DE POSTGRESQL"
if docker compose exec -T postgres pg_isready -U investor -d investment_tracker 2>/dev/null; then
    echo "✅ PostgreSQL está saludable"
else
    echo "❌ PostgreSQL no responde"
    exit 1
fi
echo ""

# 3. Datos
echo "📊 3. DATOS EN BASE DE DATOS"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT '--- CONTEO DE REGISTROS ---' as info;
SELECT '  Roles: ' || COUNT(*) FROM investment_tracker.roles;
SELECT '  Usuarios: ' || COUNT(*) FROM investment_tracker.usuarios;
SELECT '  Plataformas: ' || COUNT(*) FROM investment_tracker.plataformas;
SELECT '  Comisiones: ' || COUNT(*) FROM investment_tracker.comisiones;
SELECT '  Transacciones: ' || COUNT(*) FROM investment_tracker.transacciones;
SELECT '  Versiones: ' || COUNT(*) FROM investment_tracker.schema_version;
SQL
echo ""

# 4. Usuarios
echo "👤 4. USUARIOS REGISTRADOS"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT username, email, nombre_completo, activo, created_at::date as creado
FROM investment_tracker.usuarios;
SQL
echo ""

# 5. Prueba de funciones
echo "⚡ 5. PRUEBA DE FUNCIONES"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT '--- Calculadora venta óptima (AAPL, $500) ---' as info;
SELECT * FROM investment_tracker.calcular_venta_optima(
    'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a'::UUID,
    'AAPL', 500.00,
    'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c'::UUID
);
SQL
echo ""

# 6. Versiones
echo "📌 6. VERSIONES INSTALADAS"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT version, descripcion, script_name, ejecutado_en::date as fecha
FROM investment_tracker.schema_version
ORDER BY ejecutado_en;
SQL
echo ""

echo "✅ VERIFICACIÓN COMPLETADA"
