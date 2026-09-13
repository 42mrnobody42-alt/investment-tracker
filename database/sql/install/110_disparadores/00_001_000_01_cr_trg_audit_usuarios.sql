-- ============================================================================
-- Script: 00_001_000_01_cr_trg_audit_usuarios.sql
-- Descripción: Función + trigger de auditoría para la tabla usuarios.
--              - INSERT → I
--              - UPDATE con solo ultimo_login → L (Login)
--              - UPDATE con otros campos → U
--              - DELETE → D
--              Lee app.audit_user (SET SESSION por el backend) para
--              registrar el usuario autenticado. Si no existe → 'desconocido'.
-- Autor: Equipo Investment Tracker
-- Fecha: 2026-09-12
-- Versión: 00_001_000
-- ============================================================================
BEGIN;

CREATE OR REPLACE FUNCTION investment_tracker.fn_audit_usuarios()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = investment_tracker, pg_temp
AS $$
DECLARE
    v_datos_anteriores     JSONB;
    v_datos_nuevos         JSONB;
    v_campos_modificados   TEXT[];
    v_usuario_id           UUID;
    v_operacion            CHAR(1);
    v_usuario_aplicacion   VARCHAR(100);
BEGIN
    -- Usuario autenticado (SET SESSION app.audit_user por el backend)
    v_usuario_aplicacion := COALESCE(
        NULLIF(current_setting('app.audit_user', true), ''),
        'desconocido'
    );

    IF TG_OP = 'INSERT' THEN
        v_operacion          := 'I';
        v_datos_anteriores   := NULL;
        v_datos_nuevos       := to_jsonb(NEW);
        v_usuario_id         := NEW.id;
        v_campos_modificados := NULL;

    ELSIF TG_OP = 'UPDATE' THEN
        v_datos_anteriores   := to_jsonb(OLD);
        v_datos_nuevos       := to_jsonb(NEW);
        v_usuario_id         := NEW.id;

        SELECT ARRAY_AGG(n.key ORDER BY n.key)
          INTO v_campos_modificados
          FROM jsonb_each(v_datos_nuevos) n
         WHERE n.value IS DISTINCT FROM (v_datos_anteriores -> n.key);

        -- Sin cambios reales → no auditar
        IF v_campos_modificados IS NULL THEN
            RETURN NEW;
        END IF;

        -- Solo cambió ultimo_login → Login
        IF v_campos_modificados = ARRAY['ultimo_login'] THEN
            v_operacion := 'L';
        ELSE
            v_operacion := 'U';
        END IF;

    ELSIF TG_OP = 'DELETE' THEN
        v_operacion          := 'D';
        v_datos_anteriores   := to_jsonb(OLD);
        v_datos_nuevos       := NULL;
        v_usuario_id         := OLD.id;
        v_campos_modificados := NULL;
    END IF;

    INSERT INTO investment_tracker.auditoria_usuarios (
        operacion,
        usuario_id,
        datos_anteriores,
        datos_nuevos,
        campos_modificados,
        usuario_bd,
        usuario_aplicacion,
        ip_cliente
    ) VALUES (
        v_operacion,
        v_usuario_id,
        v_datos_anteriores,
        v_datos_nuevos,
        v_campos_modificados,
        SESSION_USER,
        v_usuario_aplicacion,
        inet_client_addr()
    );

    RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trg_audit_usuarios ON investment_tracker.usuarios;

CREATE TRIGGER trg_audit_usuarios
    AFTER INSERT OR UPDATE OR DELETE
    ON investment_tracker.usuarios
    FOR EACH ROW
    EXECUTE FUNCTION investment_tracker.fn_audit_usuarios();

COMMIT;
