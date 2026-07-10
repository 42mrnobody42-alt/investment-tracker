#!/bin/bash

echo "🧪 PRUEBA DE PERSISTENCIA DE DATOS"
echo "================================================"
echo ""

# Función para ejecutar SQL y mostrar resultados
check_data() {
    local titulo="$1"
    echo "📊 $titulo"
    echo "----------------------------------------"
    
    docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
-- Total transacciones
SELECT 'Total transacciones: ' || COUNT(*) as info
FROM investment_tracker.transacciones;

-- Usuarios existentes
SELECT 'Usuarios registrados: ' || STRING_AGG(username, ', ') as info
FROM investment_tracker.usuarios;

-- Plataformas
SELECT 'Plataformas: ' || STRING_AGG(nombre, ', ') as info
FROM investment_tracker.plataformas;

-- Últimas 3 transacciones
SELECT 'Últimas transacciones:' as info;
SELECT tipo || ' | ' || simbolo || ' | Cant: ' || cantidad || ' | Precio: $' || precio_unitario || ' | Total: $' || valor_total as detalle
FROM investment_tracker.transacciones 
ORDER BY fecha_transaccion DESC 
LIMIT 3;

SELECT '' as separator;
SQL
    echo ""
}

# 1. Estado inicial
check_data "1. ESTADO INICIAL"

# 2. Insertar transacción de prueba
echo "2. INSERTANDO NUEVA TRANSACCIÓN (NVDA)..."
echo "----------------------------------------"

docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
-- Verificar si existe el usuario demo
DO $$
DECLARE
    v_usuario_id INTEGER;
    v_plataforma_id INTEGER;
BEGIN
    SELECT id INTO v_usuario_id FROM investment_tracker.usuarios WHERE username = 'demo_user';
    
    IF v_usuario_id IS NULL THEN
        RAISE NOTICE '❌ Usuario demo_user no existe. Ejecutando seed...';
        -- Insertar usuario demo manualmente
        INSERT INTO investment_tracker.usuarios (username, password_hash, email, nombre_completo)
        VALUES ('demo_user', 'hash_temp', 'demo@test.com', 'Usuario Demo')
        ON CONFLICT (username) DO NOTHING
        RETURNING id INTO v_usuario_id;
    END IF;
    
    -- Verificar plataforma
    SELECT id INTO v_plataforma_id 
    FROM investment_tracker.plataformas 
    WHERE nombre = 'eToro' AND usuario_id = v_usuario_id;
    
    IF v_plataforma_id IS NULL THEN
        RAISE NOTICE '❌ Plataforma eToro no existe. Creando...';
        INSERT INTO investment_tracker.plataformas (usuario_id, nombre, descripcion, tipo)
        VALUES (v_usuario_id, 'eToro', 'Plataforma de trading', 'broker')
        ON CONFLICT (usuario_id, nombre) DO NOTHING
        RETURNING id INTO v_plataforma_id;
    END IF;
    
    -- Insertar nueva transacción
    INSERT INTO investment_tracker.transacciones (
        usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
        cantidad, precio_unitario, comision, valor_total, fecha_transaccion
    ) VALUES (
        v_usuario_id,
        v_plataforma_id,
        'COMPRA',
        'NVDA',
        'NVIDIA Corporation',
        10,
        450.50,
        22.53,
        4527.53,
        CURRENT_TIMESTAMP
    );
    
    RAISE NOTICE '✅ Transacción NVDA insertada exitosamente';
END $$;

-- Verificar la inserción
SELECT 
    CASE WHEN COUNT(*) > 0 
        THEN '✅ NVDA insertada: ' || COUNT(*) || ' transacción(es)'
        ELSE '❌ No se insertó NVDA'
    END as resultado
FROM investment_tracker.transacciones 
WHERE simbolo = 'NVDA';
SQL

echo ""

# 3. Verificar después de insertar
check_data "3. DESPUÉS DE INSERTAR"

# 4. Reiniciar PostgreSQL
echo "4. REINICIANDO POSTGRESQL..."
echo "----------------------------------------"
docker compose restart postgres
echo "⏳ Esperando 15 segundos para que PostgreSQL esté listo..."
sleep 15

# Verificar que PostgreSQL está saludable
echo "Verificando conexión..."
docker compose exec -T postgres pg_isready -U investor -d investment_tracker
echo ""

# 5. Verificar después de reiniciar
check_data "5. DESPUÉS DE REINICIAR"

# 6. Verificación final de NVDA
echo "6. VERIFICACIÓN FINAL DE PERSISTENCIA"
echo "----------------------------------------"
docker compose exec -T postgres psql -U investor -d investment_tracker << 'SQL'
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ ÉXITO: Los datos PERSISTEN correctamente'
        ELSE '❌ FALLO: Los datos NO persistieron'
    END as resultado_final,
    COUNT(*) as cantidad_nvda,
    MAX(fecha_transaccion) as ultima_transaccion
FROM investment_tracker.transacciones 
WHERE simbolo = 'NVDA';
SQL

echo ""
echo "================================================"
echo "🏁 PRUEBA DE PERSISTENCIA COMPLETADA"
echo "================================================"