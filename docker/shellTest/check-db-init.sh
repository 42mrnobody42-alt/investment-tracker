#!/bin/bash

echo "🔍 VERIFICANDO INICIALIZACIÓN DE BASE DE DATOS"
echo "==============================================="

# Verificar tablas
echo -e "\n📊 TABLAS CREADAS:"
docker compose exec -T postgres psql -U investor -d investment_tracker -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'investment_tracker' 
ORDER BY table_name;
"

# Verificar funciones
echo -e "\n⚡ FUNCIONES CREADAS:"
docker compose exec -T postgres psql -U investor -d investment_tracker -c "
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'investment_tracker' 
ORDER BY routine_name;
"

# Verificar datos
echo -e "\n📈 CONTEO DE REGISTROS:"
docker compose exec -T postgres psql -U investor -d investment_tracker -c "
SELECT 'Roles' as entidad, count(*) as cantidad FROM investment_tracker.roles
UNION ALL
SELECT 'Usuarios', count(*) FROM investment_tracker.usuarios
UNION ALL
SELECT 'Plataformas', count(*) FROM investment_tracker.plataformas
UNION ALL
SELECT 'Comisiones', count(*) FROM investment_tracker.comisiones
UNION ALL
SELECT 'Transacciones', count(*) FROM investment_tracker.transacciones;
"

# Probar función de resumen
echo -e "\n💰 RESUMEN DE INVERSIONES (Usuario Demo):"
docker compose exec -T postgres psql -U investor -d investment_tracker -c "
SELECT * FROM investment_tracker.resumen_inversiones(
    (SELECT id FROM investment_tracker.usuarios WHERE username = 'demo_user')
);
"

echo -e "\n✅ Verificación completada"