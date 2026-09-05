-- =============================================
-- ESQUEMA: investment_tracker
-- Versión: 00_001_000
-- =============================================

-- Crear la extensión directamente (es idempotente)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear el esquema
CREATE SCHEMA IF NOT EXISTS investment_tracker;

-- Crear la tabla de versiones (idempotente)
CREATE TABLE IF NOT EXISTS investment_tracker.schema_version (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    version VARCHAR(50) NOT NULL,
    descripcion TEXT,
    script_name VARCHAR(255) NOT NULL,
    ejecutado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ejecutado_por VARCHAR(100) DEFAULT CURRENT_USER,
    CONSTRAINT uq_schema_version_script UNIQUE (version, script_name)
);

-- Registrar esta versión (idempotente)
INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Creación de esquema y tabla de versiones', '10_esquemas/00_001_000_01_cr_schema.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Esquema y tabla schema_version creados (00_001_000)'