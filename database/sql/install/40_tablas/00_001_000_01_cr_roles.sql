-- =============================================
-- TABLA: roles
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_01_cr_roles.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla roles 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla roles...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla roles', '40_tablas/00_001_000_01_cr_roles.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla roles creada (00_001_000)'
