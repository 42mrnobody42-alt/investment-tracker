-- =============================================
-- EXTENSIONES: PostgreSQL
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '20_extensiones/00_001_000_01_cr_extensiones.sql'
    ) THEN
        RAISE NOTICE '⚠️  Extensiones 00_001_000 ya instaladas. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando extensiones...';
END $$;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Extensiones (uuid-ossp)', '20_extensiones/00_001_000_01_cr_extensiones.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Extensiones instaladas (00_001_000)'
