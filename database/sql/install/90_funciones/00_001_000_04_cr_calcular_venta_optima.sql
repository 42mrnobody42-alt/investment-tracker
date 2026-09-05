-- =============================================
-- FUNCIÓN: calcular_venta_optima
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '90_funciones/00_001_000_04_cr_calcular_venta_optima.sql'
    ) THEN
        RAISE NOTICE '⚠️  Función calcular_venta_optima 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando función calcular_venta_optima...';
END $$;

CREATE OR REPLACE FUNCTION investment_tracker.calcular_venta_optima(
    p_usuario_id UUID,
    p_simbolo VARCHAR(20),
    p_ganancia_deseada DECIMAL(10,2),
    p_plataforma_id UUID
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

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Función calcular_venta_optima', '90_funciones/00_001_000_04_cr_calcular_venta_optima.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Función calcular_venta_optima instalada (00_001_000)'
