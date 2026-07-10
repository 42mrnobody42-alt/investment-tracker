-- =============================================
-- INVESTMENT TRACKER - ESQUEMA DE BASE DE DATOS
-- Versión: 1.0.1
-- Descripción: Creación de tablas (IDEMPOTENTE)
-- =============================================

DO $$ BEGIN RAISE NOTICE '🔍 Verificando configuración existente...'; END $$;

CREATE SCHEMA IF NOT EXISTS investment_tracker;

-- Tabla de control de versiones
CREATE TABLE IF NOT EXISTS investment_tracker.schema_version (
    id SERIAL PRIMARY KEY,
    version VARCHAR(50) NOT NULL,
    descripcion TEXT,
    script_name VARCHAR(255) NOT NULL,
    ejecutado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ejecutado_por VARCHAR(100) DEFAULT CURRENT_USER,
    CONSTRAINT uq_schema_version_script UNIQUE (version, script_name)
);

-- Verificar si ya se ejecutó este script
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version 
        WHERE version = '1.0.1' AND script_name = '01_schema.sql'
    ) THEN
        RAISE NOTICE '⚠️  El esquema v1.0.1 ya está instalado. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Iniciando instalación del esquema v1.0.1...';
END $$;

-- Tablas (solo se crean si no existen)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'roles') THEN
        CREATE TABLE investment_tracker.roles (
            id SERIAL PRIMARY KEY,
            nombre VARCHAR(50) UNIQUE NOT NULL,
            descripcion TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE '✅ Tabla roles creada';
    ELSE RAISE NOTICE '⏭️ Tabla roles ya existe'; END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'usuarios') THEN
        CREATE TABLE investment_tracker.usuarios (
            id SERIAL PRIMARY KEY,
            username VARCHAR(100) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            nombre_completo VARCHAR(200),
            activo BOOLEAN DEFAULT true,
            ultimo_login TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE '✅ Tabla usuarios creada';
    ELSE RAISE NOTICE '⏭️ Tabla usuarios ya existe'; END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'usuario_roles') THEN
        CREATE TABLE investment_tracker.usuario_roles (
            usuario_id INTEGER REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
            rol_id INTEGER REFERENCES investment_tracker.roles(id) ON DELETE CASCADE,
            asignado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (usuario_id, rol_id)
        );
        RAISE NOTICE '✅ Tabla usuario_roles creada';
    ELSE RAISE NOTICE '⏭️ Tabla usuario_roles ya existe'; END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'plataformas') THEN
        CREATE TABLE investment_tracker.plataformas (
            id SERIAL PRIMARY KEY,
            usuario_id INTEGER REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
            nombre VARCHAR(100) NOT NULL,
            descripcion TEXT,
            tipo VARCHAR(50),
            activo BOOLEAN DEFAULT true,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(usuario_id, nombre)
        );
        RAISE NOTICE '✅ Tabla plataformas creada';
    ELSE RAISE NOTICE '⏭️ Tabla plataformas ya existe'; END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'comisiones') THEN
        CREATE TABLE investment_tracker.comisiones (
            id SERIAL PRIMARY KEY,
            plataforma_id INTEGER REFERENCES investment_tracker.plataformas(id) ON DELETE CASCADE,
            porcentaje DECIMAL(5,4),
            valor_fijo DECIMAL(10,2),
            descripcion VARCHAR(200),
            fecha_inicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            fecha_fin TIMESTAMP,
            activo BOOLEAN DEFAULT true,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT chk_comision CHECK (porcentaje IS NOT NULL OR valor_fijo IS NOT NULL)
        );
        RAISE NOTICE '✅ Tabla comisiones creada';
    ELSE RAISE NOTICE '⏭️ Tabla comisiones ya existe'; END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'transacciones') THEN
        CREATE TABLE investment_tracker.transacciones (
            id SERIAL PRIMARY KEY,
            usuario_id INTEGER REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
            plataforma_id INTEGER REFERENCES investment_tracker.plataformas(id),
            tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('COMPRA', 'VENTA')),
            simbolo VARCHAR(20) NOT NULL,
            empresa_nombre VARCHAR(200),
            cantidad INTEGER NOT NULL CHECK (cantidad > 0),
            precio_unitario DECIMAL(10,4) NOT NULL,
            comision DECIMAL(10,2) DEFAULT 0,
            valor_total DECIMAL(10,2) NOT NULL,
            fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            notas TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE '✅ Tabla transacciones creada';
    ELSE RAISE NOTICE '⏭️ Tabla transacciones ya existe'; END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'calculos_hist') THEN
        CREATE TABLE investment_tracker.calculos_hist (
            id SERIAL PRIMARY KEY,
            usuario_id INTEGER REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
            plataforma_id INTEGER REFERENCES investment_tracker.plataformas(id),
            simbolo VARCHAR(20) NOT NULL,
            ganancia_deseada DECIMAL(10,2) NOT NULL,
            precio_minimo_calculado DECIMAL(10,4),
            cantidad_optima INTEGER,
            comision_estimada DECIMAL(10,2),
            ganancia_neta_estimada DECIMAL(10,2),
            parametros_json JSONB,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE '✅ Tabla calculos_hist creada';
    ELSE RAISE NOTICE '⏭️ Tabla calculos_hist ya existe'; END IF;
END $$;

-- Índices
DO $$
DECLARE
    idx_names TEXT[] := ARRAY[
        'idx_transacciones_usuario', 'idx_transacciones_simbolo', 'idx_transacciones_fecha',
        'idx_transacciones_tipo', 'idx_transacciones_usuario_simbolo',
        'idx_comisiones_plataforma', 'idx_comisiones_fecha', 'idx_comisiones_activas'
    ];
    idx_name TEXT;
BEGIN
    FOREACH idx_name IN ARRAY idx_names LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = idx_name) THEN
            CASE idx_name
                WHEN 'idx_transacciones_usuario' THEN
                    CREATE INDEX idx_transacciones_usuario ON investment_tracker.transacciones(usuario_id);
                WHEN 'idx_transacciones_simbolo' THEN
                    CREATE INDEX idx_transacciones_simbolo ON investment_tracker.transacciones(simbolo);
                WHEN 'idx_transacciones_fecha' THEN
                    CREATE INDEX idx_transacciones_fecha ON investment_tracker.transacciones(fecha_transaccion);
                WHEN 'idx_transacciones_tipo' THEN
                    CREATE INDEX idx_transacciones_tipo ON investment_tracker.transacciones(tipo);
                WHEN 'idx_transacciones_usuario_simbolo' THEN
                    CREATE INDEX idx_transacciones_usuario_simbolo ON investment_tracker.transacciones(usuario_id, simbolo);
                WHEN 'idx_comisiones_plataforma' THEN
                    CREATE INDEX idx_comisiones_plataforma ON investment_tracker.comisiones(plataforma_id);
                WHEN 'idx_comisiones_fecha' THEN
                    CREATE INDEX idx_comisiones_fecha ON investment_tracker.comisiones(fecha_inicio, fecha_fin);
                WHEN 'idx_comisiones_activas' THEN
                    CREATE INDEX idx_comisiones_activas ON investment_tracker.comisiones(plataforma_id, activo) WHERE activo = true;
            END CASE;
            RAISE NOTICE '✅ Índice % creado', idx_name;
        END IF;
    END LOOP;
END $$;

-- Registrar versión
INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('1.0.1', 'Esquema inicial del sistema', '01_schema.sql')
ON CONFLICT (version, script_name) DO NOTHING;

DO $$ BEGIN RAISE NOTICE '✅ Esquema v1.0.1 instalado exitosamente'; END $$;
