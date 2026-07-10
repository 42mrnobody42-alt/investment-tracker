#!/bin/bash
echo "🔍 VERIFICACIÓN FINAL DEL SISTEMA"
echo "================================================"

echo -e "\n1. Estado de servicios:"
docker compose ps

echo -e "\n2. Salud de PostgreSQL:"
docker compose exec -T postgres pg_isready -U investor -d investment_tracker

echo -e "\n3. Datos en la base de datos:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT '========================================' as "";
SELECT 'RESUMEN DE BASE DE DATOS' as "";
SELECT '========================================' as "";
SELECT 'Roles: ' || COUNT(*) FROM investment_tracker.roles;
SELECT 'Usuarios: ' || COUNT(*) FROM investment_tracker.usuarios;
SELECT 'Plataformas: ' || COUNT(*) FROM investment_tracker.plataformas;
SELECT 'Comisiones: ' || COUNT(*) FROM investment_tracker.comisiones;
SELECT 'Transacciones: ' || COUNT(*) FROM investment_tracker.transacciones;
SELECT 'Versiones: ' || COUNT(*) FROM investment_tracker.schema_version;

SELECT '========================================' as "";
SELECT 'USUARIOS REGISTRADOS:' as "";
SELECT '========================================' as "";
SELECT username, email, nombre_completo, activo FROM investment_tracker.usuarios;

SELECT '========================================' as "";
SELECT 'TRANSACCIONES:' as "";
SELECT '========================================' as "";
SELECT tipo, simbolo, cantidad, precio_unitario, valor_total, fecha_transaccion::date as fecha
FROM investment_tracker.transacciones 
ORDER BY fecha_transaccion DESC;
SQL

echo -e "\n4. Probando función de resumen:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT * FROM investment_tracker.resumen_inversiones(
    (SELECT id FROM investment_tracker.usuarios WHERE username = 'demo_user')
);
SQL

echo -e "\n✅ Verificación completada"
