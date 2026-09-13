-- ============================================================================
-- Script: 00_001_000_01_cr_app_db_user.sql
-- Descripción: Usuario de aplicación investment_app con permisos restringidos
--              (sin acceso a la tabla de auditoría)
-- Autor: Equipo Investment Tracker
-- Fecha: 2026-09-12
-- Versión: 00_001_000
-- ============================================================================
BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'investment_app') THEN
        EXECUTE 'CREATE ROLE investment_app LOGIN PASSWORD ''InvestmentApp_2026!Secure''';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE investment_tracker TO investment_app;
GRANT USAGE   ON SCHEMA   investment_tracker TO investment_app;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON ALL TABLES IN SCHEMA investment_tracker
    TO investment_app;

GRANT USAGE, SELECT
    ON ALL SEQUENCES IN SCHEMA investment_tracker
    TO investment_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA investment_tracker
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO investment_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA investment_tracker
    GRANT USAGE, SELECT ON SEQUENCES TO investment_app;

REVOKE ALL ON investment_tracker.auditoria_usuarios                FROM investment_app;
REVOKE ALL ON SEQUENCE investment_tracker.auditoria_usuarios_id_seq FROM investment_app;

COMMIT;
