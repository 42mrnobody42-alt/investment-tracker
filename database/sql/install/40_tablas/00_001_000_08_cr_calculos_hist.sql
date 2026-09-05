-- =============================================
-- TABLA: calculos_hist
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_08_cr_calculos_hist.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla calculos_hist 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla calculos_hist...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.calculos_hist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    plataforma_id UUID REFERENCES investment_tracker.plataformas(id),
    simbolo VARCHAR(20) NOT NULL,
    ganancia_deseada DECIMAL(10,2) NOT NULL,
    precio_minimo_calculado DECIMAL(10,4),
    cantidad_optima INTEGER,
    comision_estimada DECIMAL(10,2),
    ganancia_neta_estimada DECIMAL(10,2),
    parametros_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla calculos_hist', '40_tablas/00_001_000_08_cr_calculos_hist.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla calculos_hist creada (00_001_000)'
