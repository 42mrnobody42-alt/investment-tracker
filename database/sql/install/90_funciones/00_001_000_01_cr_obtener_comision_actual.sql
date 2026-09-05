-- =============================================
-- FUNCIÓN: obtener_comision_actual
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '90_funciones/00_001_000_01_cr_obtener_comision_actual.sql'
    ) THEN
        RAISE NOTICE '⚠️  Función obtener_comision_actual 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando función obtener_comision_actual...';
END $$;

CREATE OR REPLACE FUNCTION investment_tracker.obtener_comision_actual(
    p_plataforma_id UUID
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

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Función obtener_comision_actual', '90_funciones/00_001_000_01_cr_obtener_comision_actual.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Función obtener_comision_actual instalada (00_001_000)'
