#!/bin/bash
echo "🔍 VERIFICACIÓN FINAL v2"
echo "========================"

echo ""
echo "1. Estado de servicios:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "2. Datos en la base de datos:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
-- Usar RAISE NOTICE en lugar de SELECT con alias problemáticos
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

-- Mostrar usuarios
SELECT '--- USUARIOS ---' as info;
SELECT username, email, nombre_completo 
FROM investment_tracker.usuarios;

-- Mostrar transacciones
SELECT '--- TRANSACCIONES ---' as info;
SELECT tipo, simbolo, cantidad, precio_unitario, 
       valor_total, fecha_transaccion::date as fecha
FROM investment_tracker.transacciones 
ORDER BY fecha_transaccion DESC;
SQL

echo ""
echo "3. Probando función resumen_inversiones:"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT * FROM investment_tracker.resumen_inversiones(
    (SELECT id FROM investment_tracker.usuarios WHERE username = 'demo_user')
);
SQL

echo ""
echo "4. Probando calculadora de venta óptima (AAPL, ganancia $500):"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT * FROM investment_tracker.calcular_venta_optima(
    (SELECT id FROM investment_tracker.usuarios WHERE username = 'demo_user'),
    'AAPL',
    500.00,
    (SELECT id FROM investment_tracker.plataformas WHERE nombre = 'eToro')
);
SQL

echo ""
echo "✅ Verificación completada"
