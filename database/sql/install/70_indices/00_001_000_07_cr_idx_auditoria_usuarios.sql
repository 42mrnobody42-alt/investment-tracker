-- ============================================================================
-- Script: 00_001_000_07_cr_idx_auditoria_usuarios.sql
-- Descripción: Índices de rendimiento para auditoria_usuarios
-- Autor: Equipo Investment Tracker
-- Fecha: 2026-09-12
-- Versión: 00_001_000
-- ============================================================================
BEGIN;

CREATE INDEX IF NOT EXISTS idx_auditoria_usuarios_usuario_id
    ON investment_tracker.auditoria_usuarios (usuario_id);

CREATE INDEX IF NOT EXISTS idx_auditoria_usuarios_fecha
    ON investment_tracker.auditoria_usuarios (fecha DESC);

CREATE INDEX IF NOT EXISTS idx_auditoria_usuarios_operacion
    ON investment_tracker.auditoria_usuarios (operacion);

COMMIT;
