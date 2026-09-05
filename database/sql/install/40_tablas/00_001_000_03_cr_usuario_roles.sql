-- =============================================
-- TABLA: usuario_roles
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_03_cr_usuario_roles.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla usuario_roles 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla usuario_roles...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.usuario_roles (
    usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    rol_id UUID REFERENCES investment_tracker.roles(id) ON DELETE CASCADE,
    asignado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, rol_id)
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla usuario_roles', '40_tablas/00_001_000_03_cr_usuario_roles.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla usuario_roles creada (00_001_000)'
