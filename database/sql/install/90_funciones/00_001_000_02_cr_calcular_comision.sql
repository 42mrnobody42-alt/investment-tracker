-- =============================================
-- FUNCIÓN: calcular_comision
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '90_funciones/00_001_000_02_cr_calcular_comision.sql'
    ) THEN
        RAISE NOTICE '⚠️  Función calcular_comision 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando función calcular_comision...';
END $$;

CREATE OR REPLACE FUNCTION investment_tracker.calcular_comision(
    p_plataforma_id UUID,
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

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Función calcular_comision', '90_funciones/00_001_000_02_cr_calcular_comision.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Función calcular_comision instalada (00_001_000)'
