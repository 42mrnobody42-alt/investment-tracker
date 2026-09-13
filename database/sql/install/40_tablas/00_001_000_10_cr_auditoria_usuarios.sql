-- ============================================================================
-- Script: 00_001_000_10_cr_auditoria_usuarios.sql
-- Descripción: Tabla de auditoría para cambios en usuarios.
--              Columnas: operacion (I/U/D/L), snapshots, campos modificados,
--              usuario_bd (SESSION_USER), usuario_aplicacion (JWT), IP, fecha.
-- Autor: Equipo Investment Tracker
-- Fecha: 2026-09-12
-- Versión: 00_001_000
-- ============================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS investment_tracker.auditoria_usuarios (
    id                      BIGSERIAL       PRIMARY KEY,
    operacion               CHAR(1)         NOT NULL,
    usuario_id              UUID            NOT NULL,
    datos_anteriores        JSONB,
    datos_nuevos            JSONB,
    campos_modificados      TEXT[],
    usuario_bd              VARCHAR(100)    NOT NULL,
    usuario_aplicacion      VARCHAR(100)    NOT NULL DEFAULT 'desconocido',
    ip_cliente              INET,
    fecha                   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_auditoria_usuarios_operacion
        CHECK (operacion IN ('I','U','D','L'))
);

-- Idempotente: agregar columna si la tabla ya existía sin ella
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'investment_tracker'
          AND table_name   = 'auditoria_usuarios'
          AND column_name  = 'usuario_aplicacion'
    ) THEN
        ALTER TABLE investment_tracker.auditoria_usuarios
            ADD COLUMN usuario_aplicacion VARCHAR(100) NOT NULL DEFAULT 'desconocido';
    END IF;
END $$;

-- Idempotente: garantizar CHECK incluyendo 'L'
ALTER TABLE investment_tracker.auditoria_usuarios
    DROP CONSTRAINT IF EXISTS ck_auditoria_usuarios_operacion;

ALTER TABLE investment_tracker.auditoria_usuarios
    ADD CONSTRAINT ck_auditoria_usuarios_operacion
        CHECK (operacion IN ('I','U','D','L'));

COMMIT;
