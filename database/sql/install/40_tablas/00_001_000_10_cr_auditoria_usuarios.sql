-- ============================================================================
-- Script: 00_001_000_10_cr_auditoria_usuarios.sql
-- Descripción: Creación de la tabla de auditoría para cambios en usuarios
-- Autor: Equipo Investment Tracker
-- Fecha: 2026-09-12
-- Versión: 00_001_000
-- ============================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS investment_tracker.auditoria_usuarios (
    id                  BIGSERIAL       PRIMARY KEY,
    operacion           CHAR(1)         NOT NULL,
    usuario_id          UUID            NOT NULL,
    datos_anteriores    JSONB,
    datos_nuevos        JSONB,
    campos_modificados  TEXT[],
    usuario_bd          VARCHAR(100)    NOT NULL,
    ip_cliente          INET,
    fecha               TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_auditoria_usuarios_operacion
        CHECK (operacion IN ('I','U','D'))
);

COMMIT;
