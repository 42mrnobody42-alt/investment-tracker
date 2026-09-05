-- =============================================
-- ÍNDICES: Para rendimiento
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '70_indices/00_001_000_01_cr_indices.sql'
    ) THEN
        RAISE NOTICE '⚠️  Índices 00_001_000 ya instalados. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando índices...';
END $$;

CREATE INDEX IF NOT EXISTS idx_transacciones_usuario ON investment_tracker.transacciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_simbolo ON investment_tracker.transacciones(simbolo);
CREATE INDEX IF NOT EXISTS idx_transacciones_fecha ON investment_tracker.transacciones(fecha_transaccion);
CREATE INDEX IF NOT EXISTS idx_transacciones_tipo ON investment_tracker.transacciones(tipo);
CREATE INDEX IF NOT EXISTS idx_transacciones_usuario_simbolo ON investment_tracker.transacciones(usuario_id, simbolo);
CREATE INDEX IF NOT EXISTS idx_comisiones_plataforma ON investment_tracker.comisiones(plataforma_id);
CREATE INDEX IF NOT EXISTS idx_comisiones_fecha ON investment_tracker.comisiones(fecha_inicio, fecha_fin);
CREATE INDEX IF NOT EXISTS idx_comisiones_activas ON investment_tracker.comisiones(plataforma_id, activo) WHERE activo = true;
CREATE INDEX IF NOT EXISTS idx_monedas_codigo ON investment_tracker.monedas(codigo);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Índices de rendimiento', '70_indices/00_001_000_01_cr_indices.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Índices creados (00_001_000)'
