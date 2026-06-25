-- database/sql/02_functions.sql
CREATE OR REPLACE FUNCTION investment_tracker.calcular_comision(
    p_plataforma_id INTEGER,
    p_valor_transaccion DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    v_comision DECIMAL(10,2);
    v_porcentaje DECIMAL(5,4);
    v_valor_fijo DECIMAL(10,2);
BEGIN
    -- Obtener comisión vigente
    SELECT porcentaje, valor_fijo 
    INTO v_porcentaje, v_valor_fijo
    FROM investment_tracker.comisiones
    WHERE plataforma_id = p_plataforma_id
      AND fecha_inicio <= CURRENT_TIMESTAMP
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_TIMESTAMP)
    ORDER BY fecha_inicio DESC
    LIMIT 1;
    
    -- Calcular comisión
    IF v_porcentaje IS NOT NULL THEN
        v_comision := p_valor_transaccion * v_porcentaje;
    END IF;
    
    IF v_valor_fijo IS NOT NULL THEN
        v_comision := COALESCE(v_comision, 0) + v_valor_fijo;
    END IF;
    
    RETURN COALESCE(v_comision, 0);
END;
$$ LANGUAGE plpgsql;