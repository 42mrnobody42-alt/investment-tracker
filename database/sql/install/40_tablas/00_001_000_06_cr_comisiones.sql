-- =============================================
-- TABLA: comisiones
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_06_cr_comisiones.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla comisiones 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla comisiones...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.comisiones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plataforma_id UUID REFERENCES investment_tracker.plataformas(id) ON DELETE CASCADE,
    porcentaje DECIMAL(5,4),
    valor_fijo DECIMAL(10,2),
    moneda_id UUID REFERENCES investment_tracker.monedas(id),
    descripcion VARCHAR(200),
    fecha_inicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_comision CHECK (porcentaje IS NOT NULL OR valor_fijo IS NOT NULL)
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla comisiones', '40_tablas/00_001_000_06_cr_comisiones.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla comisiones creada (00_001_000)'
