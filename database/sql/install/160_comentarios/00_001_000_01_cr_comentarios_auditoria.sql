-- ============================================================================
-- Script: 00_001_000_01_cr_comentarios_auditoria.sql
-- Descripción: Comentarios de documentación de la tabla de auditoría
-- Autor: Equipo Investment Tracker
-- Fecha: 2026-09-12
-- Versión: 00_001_000
-- ============================================================================
BEGIN;

COMMENT ON TABLE  investment_tracker.auditoria_usuarios IS
    'Historial de cambios (INSERT/UPDATE/DELETE/Login) sobre usuarios. Solo accesible por el owner (postgres); investment_app no tiene permisos.';

COMMENT ON COLUMN investment_tracker.auditoria_usuarios.operacion IS
    'I=INSERT, U=UPDATE, D=DELETE, L=Login (solo cambió ultimo_login)';

COMMENT ON COLUMN investment_tracker.auditoria_usuarios.usuario_id IS
    'UUID del usuario afectado (NEW.id en INSERT/UPDATE, OLD.id en DELETE)';

COMMENT ON COLUMN investment_tracker.auditoria_usuarios.datos_anteriores IS
    'Snapshot JSONB de la fila antes del cambio (NULL en INSERT)';

COMMENT ON COLUMN investment_tracker.auditoria_usuarios.datos_nuevos IS
    'Snapshot JSONB de la fila después del cambio (NULL en DELETE)';

COMMENT ON COLUMN investment_tracker.auditoria_usuarios.campos_modificados IS
    'Lista ordenada de columnas que cambiaron en un UPDATE';

COMMENT ON COLUMN investment_tracker.auditoria_usuarios.usuario_bd IS
    'SESSION_USER que ejecutó el DML (ej: investment_app)';

COMMENT ON COLUMN investment_tracker.auditoria_usuarios.usuario_aplicacion IS
    'Usuario autenticado en la aplicación que ejecutó la petición (JWT). "desconocido" si no hay autenticación.';

COMMENT ON COLUMN investment_tracker.auditoria_usuarios.ip_cliente IS
    'IP del cliente PostgreSQL si está disponible (inet_client_addr)';

COMMENT ON FUNCTION investment_tracker.fn_audit_usuarios() IS
    'Función de trigger SECURITY DEFINER que registra cambios de usuarios. Lee app.audit_user para el usuario autenticado; mapea UPDATE de solo ultimo_login a operacion=L.';

COMMIT;
