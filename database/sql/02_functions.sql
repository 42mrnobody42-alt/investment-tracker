-- =============================================
-- INVESTMENT TRACKER - FUNCIONES PL/pgSQL
-- Versión: 1.0.1
-- Descripción: Funciones del sistema (IDEMPOTENTE)
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version 
        WHERE version = '1.0.1' AND script_name = '02_functions.sql'
    ) THEN
        RAISE NOTICE '⚠️  Las funciones v1.0.1 ya están instaladas. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando funciones v1.0.1...';
END $$;

-- Función: obtener_comision_actual
CREATE OR REPLACE FUNCTION investment_tracker.obtener_comision_actual(
    p_plataforma_id INTEGER
) RETURNS TABLE(
    porcentaje DECIMAL(5,4),
    valor_fijo DECIMAL(10,2),
    descripcion VARCHAR(200)
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.porcentaje, c.valor_fijo, c.descripcion
    FROM investment_tracker.comisiones c
    WHERE c.plataforma_id = p_plataforma_id
      AND c.activo = true
      AND c.fecha_inicio <= CURRENT_TIMESTAMP
      AND (c.fecha_fin IS NULL OR c.fecha_fin >= CURRENT_TIMESTAMP)
    ORDER BY c.fecha_inicio DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Función: calcular_comision
CREATE OR REPLACE FUNCTION investment_tracker.calcular_comision(
    p_plataforma_id INTEGER,
    p_valor_transaccion DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    v_comision DECIMAL(10,2) := 0;
    v_porcentaje DECIMAL(5,4);
    v_valor_fijo DECIMAL(10,2);
BEGIN
    SELECT c.porcentaje, c.valor_fijo 
    INTO v_porcentaje, v_valor_fijo
    FROM investment_tracker.comisiones c
    WHERE c.plataforma_id = p_plataforma_id
      AND c.activo = true
      AND c.fecha_inicio <= CURRENT_TIMESTAMP
      AND (c.fecha_fin IS NULL OR c.fecha_fin >= CURRENT_TIMESTAMP)
    ORDER BY c.fecha_inicio DESC
    LIMIT 1;
    
    IF v_porcentaje IS NOT NULL THEN
        v_comision := v_comision + (p_valor_transaccion * v_porcentaje);
    END IF;
    IF v_valor_fijo IS NOT NULL THEN
        v_comision := v_comision + v_valor_fijo;
    END IF;
    
    RETURN ROUND(v_comision::numeric, 2);
END;
$$ LANGUAGE plpgsql;

-- Función: resumen_inversiones (CORREGIDA)
CREATE OR REPLACE FUNCTION investment_tracker.resumen_inversiones(
    p_usuario_id INTEGER
) RETURNS TABLE(
    simbolo VARCHAR(20),
    empresa_nombre VARCHAR(200),
    cantidad_actual INTEGER,
    precio_promedio_compra DECIMAL(10,4),
    total_invertido DECIMAL(10,2),
    total_comisiones DECIMAL(10,2),
    ultima_transaccion TIMESTAMP,
    cantidad_compras BIGINT,
    cantidad_ventas BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.simbolo::VARCHAR(20),
        MAX(t.empresa_nombre)::VARCHAR(200),
        SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.cantidad ELSE -t.cantidad END)::INTEGER,
        ROUND(AVG(CASE WHEN t.tipo = 'COMPRA' THEN t.precio_unitario ELSE NULL END)::numeric, 4)::DECIMAL(10,4),
        SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.valor_total ELSE 0 END)::DECIMAL(10,2),
        SUM(t.comision)::DECIMAL(10,2),
        MAX(t.fecha_transaccion),
        COUNT(*) FILTER (WHERE t.tipo = 'COMPRA'),
        COUNT(*) FILTER (WHERE t.tipo = 'VENTA')
    FROM investment_tracker.transacciones t
    WHERE t.usuario_id = p_usuario_id
    GROUP BY t.simbolo
    HAVING SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.cantidad ELSE -t.cantidad END) > 0
    ORDER BY total_invertido DESC;
END;
$$ LANGUAGE plpgsql;

-- Función: calcular_venta_optima
CREATE OR REPLACE FUNCTION investment_tracker.calcular_venta_optima(
    p_usuario_id INTEGER,
    p_simbolo VARCHAR(20),
    p_ganancia_deseada DECIMAL(10,2),
    p_plataforma_id INTEGER
) RETURNS TABLE(
    precio_minimo DECIMAL(10,4),
    cantidad_optima INTEGER,
    comision_estimada DECIMAL(10,2),
    ingreso_bruto DECIMAL(10,2),
    ganancia_neta DECIMAL(10,2)
) AS $$
DECLARE
    v_cantidad_actual INTEGER;
    v_costo_promedio DECIMAL(10,4);
    v_comision_compra DECIMAL(10,2);
    v_porcentaje_comision DECIMAL(5,4);
    v_valor_fijo_comision DECIMAL(10,2);
    v_costo_total DECIMAL(10,2);
    v_precio_minimo_calc DECIMAL(10,4);
    v_comision_venta DECIMAL(10,2);
BEGIN
    SELECT 
        SUM(CASE WHEN tipo = 'COMPRA' THEN cantidad ELSE -cantidad END),
        AVG(CASE WHEN tipo = 'COMPRA' THEN precio_unitario ELSE NULL END),
        SUM(CASE WHEN tipo = 'COMPRA' THEN comision ELSE 0 END)
    INTO v_cantidad_actual, v_costo_promedio, v_comision_compra
    FROM investment_tracker.transacciones
    WHERE usuario_id = p_usuario_id 
      AND simbolo = p_simbolo
      AND tipo IN ('COMPRA', 'VENTA');
    
    IF v_cantidad_actual IS NULL OR v_cantidad_actual <= 0 THEN
        RETURN;
    END IF;
    
    SELECT porcentaje, valor_fijo
    INTO v_porcentaje_comision, v_valor_fijo_comision
    FROM investment_tracker.obtener_comision_actual(p_plataforma_id);
    
    v_costo_total := (v_cantidad_actual * v_costo_promedio) + v_comision_compra;
    
    IF v_porcentaje_comision IS NOT NULL AND v_porcentaje_comision > 0 THEN
        v_precio_minimo_calc := (v_costo_total + p_ganancia_deseada + COALESCE(v_valor_fijo_comision, 0)) / 
                                (v_cantidad_actual * (1 - v_porcentaje_comision));
    ELSE
        v_precio_minimo_calc := (v_costo_total + p_ganancia_deseada) / v_cantidad_actual;
    END IF;
    
    v_comision_venta := investment_tracker.calcular_comision(
        p_plataforma_id, 
        v_precio_minimo_calc * v_cantidad_actual
    );
    
    RETURN QUERY
    SELECT 
        ROUND(v_precio_minimo_calc::numeric, 4),
        v_cantidad_actual,
        v_comision_venta,
        ROUND((v_precio_minimo_calc * v_cantidad_actual)::numeric, 2),
        p_ganancia_deseada;
END;
$$ LANGUAGE plpgsql;

-- Registrar versión
INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('1.0.1', 'Funciones del sistema corregidas', '02_functions.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Funciones v1.0.1 instaladas'
