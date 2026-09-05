-- =============================================
-- TABLA: plataformas
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_05_cr_plataformas.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla plataformas 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla plataformas...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.plataformas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(50),
    moneda_id UUID REFERENCES investment_tracker.monedas(id),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, nombre)
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla plataformas', '40_tablas/00_001_000_05_cr_plataformas.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla plataformas creada (00_001_000)'
