-- =============================================
-- INVESTMENT TRACKER - ESQUEMA DE BASE DE DATOS
-- Versión: 2.0.0
-- Descripción: Creación de tablas con UUID (IDEMPOTENTE)
-- =============================================

DO $$ BEGIN RAISE NOTICE '🔍 Verificando configuración existente...'; END $$;

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE SCHEMA IF NOT EXISTS investment_tracker;

-- Tabla de control de versiones
CREATE TABLE IF NOT EXISTS investment_tracker.schema_version (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
        WHERE version = '2.0.0' AND script_name = '01_schema.sql'
    ) THEN
        RAISE NOTICE '⚠️  El esquema v2.0.0 ya está instalado. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Iniciando instalación del esquema v2.0.0 (UUID)...';
END $$;

-- =============================================
-- TABLA: roles
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'roles') THEN
        CREATE TABLE investment_tracker.roles (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            nombre VARCHAR(50) UNIQUE NOT NULL,
            descripcion TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE '✅ Tabla roles creada (UUID)';
    ELSE 
        RAISE NOTICE '⏭️ Tabla roles ya existe'; 
    END IF;
END $$;

-- =============================================
-- TABLA: usuarios
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'usuarios') THEN
        CREATE TABLE investment_tracker.usuarios (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            username VARCHAR(100) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            nombre_completo VARCHAR(200),
            activo BOOLEAN DEFAULT true,
            ultimo_login TIMESTAMP,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE '✅ Tabla usuarios creada (UUID)';
    ELSE 
        RAISE NOTICE '⏭️ Tabla usuarios ya existe'; 
    END IF;
END $$;

-- =============================================
-- TABLA: usuario_roles
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'usuario_roles') THEN
        CREATE TABLE investment_tracker.usuario_roles (
            usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
            rol_id UUID REFERENCES investment_tracker.roles(id) ON DELETE CASCADE,
            asignado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (usuario_id, rol_id)
        );
        RAISE NOTICE '✅ Tabla usuario_roles creada (UUID)';
    ELSE 
        RAISE NOTICE '⏭️ Tabla usuario_roles ya existe'; 
    END IF;
END $$;

-- =============================================
-- TABLA: plataformas
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'plataformas') THEN
        CREATE TABLE investment_tracker.plataformas (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
            nombre VARCHAR(100) NOT NULL,
            descripcion TEXT,
            tipo VARCHAR(50),
            activo BOOLEAN DEFAULT true,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(usuario_id, nombre)
        );
        RAISE NOTICE '✅ Tabla plataformas creada (UUID)';
    ELSE 
        RAISE NOTICE '⏭️ Tabla plataformas ya existe'; 
    END IF;
END $$;

-- =============================================
-- TABLA: comisiones
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'comisiones') THEN
        CREATE TABLE investment_tracker.comisiones (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            plataforma_id UUID REFERENCES investment_tracker.plataformas(id) ON DELETE CASCADE,
            porcentaje DECIMAL(5,4),
            valor_fijo DECIMAL(10,2),
            descripcion VARCHAR(200),
            fecha_inicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            fecha_fin TIMESTAMP,
            activo BOOLEAN DEFAULT true,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT chk_comision CHECK (porcentaje IS NOT NULL OR valor_fijo IS NOT NULL)
        );
        RAISE NOTICE '✅ Tabla comisiones creada (UUID)';
    ELSE 
        RAISE NOTICE '⏭️ Tabla comisiones ya existe'; 
    END IF;
END $$;

-- =============================================
-- TABLA: transacciones
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'transacciones') THEN
        CREATE TABLE investment_tracker.transacciones (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
            plataforma_id UUID REFERENCES investment_tracker.plataformas(id),
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
        RAISE NOTICE '✅ Tabla transacciones creada (UUID)';
    ELSE 
        RAISE NOTICE '⏭️ Tabla transacciones ya existe'; 
    END IF;
END $$;

-- =============================================
-- TABLA: calculos_hist
-- =============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'investment_tracker' AND table_name = 'calculos_hist') THEN
        CREATE TABLE investment_tracker.calculos_hist (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
            plataforma_id UUID REFERENCES investment_tracker.plataformas(id),
            simbolo VARCHAR(20) NOT NULL,
            ganancia_deseada DECIMAL(10,2) NOT NULL,
            precio_minimo_calculado DECIMAL(10,4),
            cantidad_optima INTEGER,
            comision_estimada DECIMAL(10,2),
            ganancia_neta_estimada DECIMAL(10,2),
            parametros_json JSONB,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        RAISE NOTICE '✅ Tabla calculos_hist creada (UUID)';
    ELSE 
        RAISE NOTICE '⏭️ Tabla calculos_hist ya existe'; 
    END IF;
END $$;

-- =============================================
-- ÍNDICES
-- =============================================
DO $$
DECLARE
    idx_defs TEXT[][] := ARRAY[
        ARRAY['idx_transacciones_usuario', 'investment_tracker.transacciones(usuario_id)'],
        ARRAY['idx_transacciones_simbolo', 'investment_tracker.transacciones(simbolo)'],
        ARRAY['idx_transacciones_fecha', 'investment_tracker.transacciones(fecha_transaccion)'],
        ARRAY['idx_transacciones_tipo', 'investment_tracker.transacciones(tipo)'],
        ARRAY['idx_transacciones_usuario_simbolo', 'investment_tracker.transacciones(usuario_id, simbolo)'],
        ARRAY['idx_comisiones_plataforma', 'investment_tracker.comisiones(plataforma_id)'],
        ARRAY['idx_comisiones_fecha', 'investment_tracker.comisiones(fecha_inicio, fecha_fin)'],
        ARRAY['idx_comisiones_activas', 'investment_tracker.comisiones(plataforma_id, activo)']
    ];
    i INTEGER;
BEGIN
    FOR i IN 1..array_length(idx_defs, 1) LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = idx_defs[i][1]) THEN
            IF idx_defs[i][1] = 'idx_comisiones_activas' THEN
                EXECUTE format('CREATE INDEX %I ON %s WHERE activo = true', 
                    idx_defs[i][1], 'investment_tracker.comisiones(plataforma_id, activo)');
            ELSE
                EXECUTE format('CREATE INDEX %I ON %s', idx_defs[i][1], idx_defs[i][2]);
            END IF;
            RAISE NOTICE '✅ Índice % creado', idx_defs[i][1];
        END IF;
    END LOOP;
END $$;

-- Registrar versión
INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('2.0.0', 'Esquema con UUID', '01_schema.sql')
ON CONFLICT (version, script_name) DO NOTHING;

DO $$ BEGIN RAISE NOTICE '✅ Esquema v2.0.0 (UUID) instalado exitosamente'; END $$;
