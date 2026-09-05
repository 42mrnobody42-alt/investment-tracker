-- =============================================
-- TABLA: paises (con relación a monedas)
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_02_cr_paises.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla paises 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla paises...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.paises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    codigo_iso VARCHAR(3) UNIQUE NOT NULL,
    indicativo_celular VARCHAR(10) NOT NULL,
    moneda_id UUID REFERENCES investment_tracker.monedas(id) ON DELETE RESTRICT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla paises', '40_tablas/00_001_000_02_cr_paises.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla paises creada (00_001_000)'
