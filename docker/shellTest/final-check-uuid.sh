#!/bin/bash
echo "🔍 VERIFICACIÓN FINAL - UUID v2.0.0"
echo "================================================"

echo ""
echo "1. Estado de servicios:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "2. Datos en la base de datos:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM investment_tracker.roles;
    RAISE NOTICE 'Roles: %', v_count;
    SELECT COUNT(*) INTO v_count FROM investment_tracker.usuarios;
    RAISE NOTICE 'Usuarios: %', v_count;
    SELECT COUNT(*) INTO v_count FROM investment_tracker.plataformas;
    RAISE NOTICE 'Plataformas: %', v_count;
    SELECT COUNT(*) INTO v_count FROM investment_tracker.comisiones;
    RAISE NOTICE 'Comisiones: %', v_count;
    SELECT COUNT(*) INTO v_count FROM investment_tracker.transacciones;
    RAISE NOTICE 'Transacciones: %', v_count;
END $$;

SELECT '--- USUARIOS (UUID) ---' as info;
SELECT id, username, email FROM investment_tracker.usuarios;

SELECT '--- PLATAFORMAS (UUID) ---' as info;
SELECT id, nombre, tipo FROM investment_tracker.plataformas;

SELECT '--- TRANSACCIONES ---' as info;
SELECT id, tipo, simbolo, cantidad, precio_unitario, valor_total, fecha_transaccion::date as fecha
FROM investment_tracker.transacciones ORDER BY fecha_transaccion DESC;
SQL

echo ""
echo "3. Probando función resumen_inversiones (UUID):"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT * FROM investment_tracker.resumen_inversiones(
    'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a'::UUID
);
SQL

echo ""
echo "4. Probando calculadora con UUID:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT * FROM investment_tracker.calcular_venta_optima(
    'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a'::UUID,
    'AAPL',
    500.00,
    'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c'::UUID
);
SQL

echo ""
echo "5. Verificando versiones instaladas:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT version, script_name, ejecutado_en::date as fecha 
FROM investment_tracker.schema_version 
ORDER BY ejecutado_en;
SQL

echo ""
echo "✅ Verificación UUID completada"
