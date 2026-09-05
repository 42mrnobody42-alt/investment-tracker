-- =============================================
-- DATOS: roles
-- Versión: 00_001_000
-- =============================================

DO $$
DECLARE
    v_ROLE_ADMIN    UUID := 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d';
    v_ROLE_USER     UUID := 'b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e';
    v_ROLE_PREMIUM  UUID := 'c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f';
BEGIN
    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_ADMIN, 'ROLE_ADMIN', 'Administrador del sistema con acceso total'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_ADMIN');

    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_USER, 'ROLE_USER', 'Usuario regular con funcionalidades básicas'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_USER');

    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_PREMIUM, 'ROLE_PREMIUM', 'Usuario premium con acceso a calculadora avanzada'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_PREMIUM');
END $$;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Datos de roles', '140_datos_basicos/00_001_000_01_cr_roles_data.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Datos de roles insertados (00_001_000)'
