-- =============================================
-- TABLA: monedas
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_04_cr_monedas.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla monedas 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla monedas...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.monedas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(3) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    simbolo VARCHAR(10),
    pais VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla monedas', '40_tablas/00_001_000_04_cr_monedas.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla monedas creada (00_001_000)'
