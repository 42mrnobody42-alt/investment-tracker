-- database/sql/03_procedures.sql
CREATE OR REPLACE FUNCTION investment_tracker.calcular_venta_optima(
    p_usuario_id INTEGER,
    p_simbolo VARCHAR(20),
    p_ganancia_deseada DECIMAL(10,2),
    p_plataforma_id INTEGER
) RETURNS TABLE(
    precio_minimo DECIMAL(10,2),
    cantidad_optima INTEGER,
    comision_estimada DECIMAL(10,2),
    ingreso_bruto DECIMAL(10,2),
    ganancia_neta DECIMAL(10,2)
) AS $$
DECLARE
    v_cantidad_actual INTEGER;
    v_costo_promedio DECIMAL(10,2);
    v_comision_compra DECIMAL(10,2);
    v_porcentaje_comision DECIMAL(5,4);
    v_valor_fijo_comision DECIMAL(10,2);
    v_precio_actual_estimado DECIMAL(10,2);
BEGIN
    -- Obtener posición actual del símbolo
    SELECT 
        SUM(CASE WHEN tipo = 'COMPRA' THEN cantidad ELSE -cantidad END),
        AVG(CASE WHEN tipo = 'COMPRA' THEN precio_unitario ELSE NULL END),
        SUM(CASE WHEN tipo = 'COMPRA' THEN comision ELSE 0 END)
    INTO v_cantidad_actual, v_costo_promedio, v_comision_compra
    FROM investment_tracker.transacciones
    WHERE usuario_id = p_usuario_id 
      AND simbolo = p_simbolo
      AND tipo IN ('COMPRA', 'VENTA');
    
    -- Si no hay existencias, retornar vacío
    IF v_cantidad_actual <= 0 THEN
        RETURN;
    END IF;
    
    -- Obtener estructura de comisiones vigente
    SELECT porcentaje, valor_fijo
    INTO v_porcentaje_comision, v_valor_fijo_comision
    FROM investment_tracker.comisiones
    WHERE plataforma_id = p_plataforma_id
      AND fecha_inicio <= CURRENT_TIMESTAMP
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_TIMESTAMP)
    ORDER BY fecha_inicio DESC
    LIMIT 1;
    
    -- Calcular costo total de la posición
    -- Costo total = (cantidad * costo_promedio) + comisiones de compra
    -- Para obtener ganancia_deseada:
    -- (precio * cantidad_optima) - comision_venta - costo_total = ganancia_deseada
    -- Despejando precio cuando vendemos toda la posición:
    
    -- Comisión de venta estimada
    v_comision_compra := v_comision_compra * (p_ganancia_deseada / NULLIF(v_cantidad_actual * v_costo_promedio, 0));
    
    -- Calcular precio mínimo
    RETURN QUERY
    SELECT 
        ROUND(((v_cantidad_actual * v_costo_promedio + v_comision_compra + p_ganancia_deseada) / 
               (v_cantidad_actual * (1 - COALESCE(v_porcentaje_comision, 0))))::numeric, 2) as precio_min,
        v_cantidad_actual as cantidad_optima,
        ROUND((((v_cantidad_actual * v_costo_promedio + v_comision_compra + p_ganancia_deseada) / 
                (v_cantidad_actual * (1 - COALESCE(v_porcentaje_comision, 0)))) * 
               v_porcentaje_comision + COALESCE(v_valor_fijo_comision, 0))::numeric, 2) as comision,
        ROUND(((v_cantidad_actual * v_costo_promedio + v_comision_compra + p_ganancia_deseada) / 
               (1 - COALESCE(v_porcentaje_comision, 0)))::numeric, 2) as ingreso_bruto,
        p_ganancia_deseada as ganancia_neta;
END;
$$ LANGUAGE plpgsql;