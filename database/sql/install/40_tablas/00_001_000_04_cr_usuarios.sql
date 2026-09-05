-- =============================================
-- TABLA: usuarios (con celular BIGINT y pais_id)
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_04_cr_usuarios.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla usuarios 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla usuarios...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(200),
    pais_id UUID REFERENCES investment_tracker.paises(id) ON DELETE SET NULL,
    celular BIGINT,
    activo BOOLEAN DEFAULT true,
    ultimo_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Nota: Los índices UNIQUE se crearán en 70_indices/...
--       - username y email: case-insensitive con LOWER()
--       - pais_id + celular: compuesto único

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla usuarios (con celular BIGINT y pais_id)', '40_tablas/00_001_000_04_cr_usuarios.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla usuarios creada (00_001_000)'
