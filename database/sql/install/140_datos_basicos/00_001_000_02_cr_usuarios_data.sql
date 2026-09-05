-- =============================================
-- DATOS: usuarios
-- Versión: 00_001_000
-- =============================================

DO $$
DECLARE
    v_ROLE_USER     UUID := 'b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e';
    v_ROLE_ADMIN    UUID := 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d';
    v_ROLE_PREMIUM  UUID := 'c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f';
    v_USER_DEMO      UUID := 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a';
    v_USER_ADMIN     UUID := 'e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b';
    v_USER_INCOGNITO UUID := 'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c';
BEGIN
    INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo)
    SELECT v_USER_DEMO, 'demo_user',
           '$2a$10$geVB6cZUm027Tw0.suctIOtzL4CkbAQ6XNsxTNzsbjX8ADtgUWPDS',
           'demo@investment-tracker.com', 'Usuario Demo'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'demo_user');

    INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
    SELECT v_USER_DEMO, v_ROLE_USER
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuario_roles WHERE usuario_id = v_USER_DEMO AND rol_id = v_ROLE_USER);

    INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo)
    SELECT v_USER_ADMIN, 'admin',
           '$2a$10$emTDQhyVPegoeKxfw1lZieRYRyeM5RsWkLB1iXNH15VzhrubbLweq',
           'admin@investment-tracker.com', 'Administrador'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'admin');

    INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
    SELECT v_USER_ADMIN, r.id FROM investment_tracker.roles r
    WHERE r.nombre IN ('ROLE_ADMIN', 'ROLE_USER')
    AND NOT EXISTS (SELECT 1 FROM investment_tracker.usuario_roles WHERE usuario_id = v_USER_ADMIN AND rol_id = r.id);

    INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo)
    SELECT v_USER_INCOGNITO, 'incognito',
           '$2a$10$Rw3wbbs1gphl3cS3eJ1r2Oh2kSHSqCWJGqPRLs7/snc8OcgayZCYq',
           '42mrnobody42@gmail.com', 'Usuario Premium incognito'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'incognito');

    INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
    SELECT v_USER_INCOGNITO, r.id FROM investment_tracker.roles r
    WHERE r.nombre IN ('ROLE_PREMIUM', 'ROLE_USER')
    AND NOT EXISTS (SELECT 1 FROM investment_tracker.usuario_roles WHERE usuario_id = v_USER_INCOGNITO AND rol_id = r.id);
END $$;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Datos de usuarios', '140_datos_basicos/00_001_000_02_cr_usuarios_data.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Datos de usuarios insertados (00_001_000)'
