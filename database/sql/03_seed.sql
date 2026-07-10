-- =============================================
-- INVESTMENT TRACKER - DATOS INICIALES (SEED)
-- Versión: 2.0.0
-- Descripción: Datos de prueba con UUID fijos
-- =============================================

\echo '🔍 Verificando datos existentes...'

-- =============================================
-- ROLES DEL SISTEMA (UUID fijos para referencia)
-- =============================================
INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
SELECT 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d', 'ROLE_ADMIN', 'Administrador del sistema con acceso total'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_ADMIN');

INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
SELECT 'b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e', 'ROLE_USER', 'Usuario regular con funcionalidades básicas'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_USER');

INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
SELECT 'c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f', 'ROLE_PREMIUM', 'Usuario premium con acceso a calculadora avanzada'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_PREMIUM');

\echo '✅ Roles verificados'

-- =============================================
-- USUARIOS (UUID fijos)
-- =============================================
-- Usuario demo
INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo)
SELECT 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a', 'demo_user',
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'demo@investment-tracker.com', 'Usuario Demo'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'demo_user');

INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
SELECT 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a', 'b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e'
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.usuario_roles 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' 
    AND rol_id = 'b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e'
);

\echo '✅ Usuario demo verificado'

-- Usuario admin
INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo)
SELECT 'e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b', 'admin',
       '$2a$10$8K1p/a0dL1LXMIgoEDFrwOfMQkf9RlFP0KxDsF3jkHNGOofQQUmSi',
       'admin@investment-tracker.com', 'Administrador'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'admin');

INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
SELECT 'e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b', r.id
FROM investment_tracker.roles r
WHERE r.nombre IN ('ROLE_ADMIN', 'ROLE_USER')
AND NOT EXISTS (
    SELECT 1 FROM investment_tracker.usuario_roles 
    WHERE usuario_id = 'e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b' 
    AND rol_id = r.id
);

\echo '✅ Usuario admin verificado'

-- =============================================
-- PLATAFORMAS (UUID fijos)
-- =============================================
INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
SELECT 'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a',
       'eToro', 'Plataforma de trading social y copy trading', 'broker'
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.plataformas 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' AND nombre = 'eToro'
);

INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
SELECT 'a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a',
       'Interactive Brokers', 'Broker profesional con acceso a mercados globales', 'broker'
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.plataformas 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' AND nombre = 'Interactive Brokers'
);

INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
SELECT 'b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a',
       'Robinhood', 'App de trading sin comisiones', 'broker'
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.plataformas 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' AND nombre = 'Robinhood'
);

INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
SELECT 'c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a',
       'Binance', 'Exchange de criptomonedas', 'exchange'
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.plataformas 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' AND nombre = 'Binance'
);

\echo '✅ Plataformas verificadas'

-- =============================================
-- COMISIONES (UUID fijos)
-- =============================================
INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
SELECT 'd0e1f2a3-b4c5-4d6e-7f8a-9b0c1d2e3f4a', 'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c',
       0.0050, 0.00, 'Comisión estándar eToro 0.5%', '2024-01-01'::timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = 'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c'
);

INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
SELECT 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b', 'a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d',
       0.0010, 1.00, 'Comisión IBKR Pro', '2024-01-01'::timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = 'a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d'
);

INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
SELECT 'f2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c', 'b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e',
       0.0000, 0.00, 'Sin comisiones', '2024-01-01'::timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = 'b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e'
);

INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
SELECT 'a3b4c5d6-e7f8-4a9b-0c1d-2e3f4a5b6c7d', 'c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f',
       0.0010, 0.00, 'Comisión estándar Binance 0.1%', '2024-01-01'::timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = 'c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f'
);

\echo '✅ Comisiones verificadas'

-- =============================================
-- TRANSACCIONES DE EJEMPLO (UUID fijos)
-- =============================================
INSERT INTO investment_tracker.transacciones (
    id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
    cantidad, precio_unitario, comision, valor_total, fecha_transaccion
)
SELECT 'b4c5d6e7-f8a9-4b0c-1d2e-3f4a5b6c7d8e', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a',
       'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c', 'COMPRA', 'AAPL', 'Apple Inc.',
       10, 175.50, 8.78, 1763.78, '2024-01-15 10:30:00'::timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.transacciones 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' 
    AND simbolo = 'AAPL' AND fecha_transaccion = '2024-01-15 10:30:00'::timestamp
);

INSERT INTO investment_tracker.transacciones (
    id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
    cantidad, precio_unitario, comision, valor_total, fecha_transaccion
)
SELECT 'c5d6e7f8-a9b0-4c1d-2e3f-4a5b6c7d8e9f', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a',
       'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c', 'COMPRA', 'TSLA', 'Tesla Inc.',
       5, 245.30, 6.13, 1232.63, '2024-02-01 11:00:00'::timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.transacciones 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' 
    AND simbolo = 'TSLA' AND fecha_transaccion = '2024-02-01 11:00:00'::timestamp
);

INSERT INTO investment_tracker.transacciones (
    id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
    cantidad, precio_unitario, comision, valor_total, fecha_transaccion
)
SELECT 'd6e7f8a9-b0c1-4d2e-3f4a-5b6c7d8e9f0a', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a',
       'a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d', 'COMPRA', 'GOOGL', 'Alphabet Inc.',
       3, 140.50, 1.42, 422.92, '2024-03-01 09:45:00'::timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.transacciones 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' 
    AND simbolo = 'GOOGL' AND fecha_transaccion = '2024-03-01 09:45:00'::timestamp
);

INSERT INTO investment_tracker.transacciones (
    id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
    cantidad, precio_unitario, comision, valor_total, fecha_transaccion
)
SELECT 'e7f8a9b0-c1d2-4e3f-4a5b-6c7d8e9f0a1b', 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a',
       'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c', 'COMPRA', 'MSFT', 'Microsoft Corp.',
       8, 380.75, 15.23, 3061.23, '2024-03-10 15:20:00'::timestamp
WHERE NOT EXISTS (
    SELECT 1 FROM investment_tracker.transacciones 
    WHERE usuario_id = 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a' 
    AND simbolo = 'MSFT' AND fecha_transaccion = '2024-03-10 15:20:00'::timestamp
);

\echo '✅ Transacciones de ejemplo verificadas'

-- =============================================
-- RESUMEN FINAL
-- =============================================
SELECT '📊 DATOS ACTUALES (UUID):' as info;
SELECT 'Roles: ' || COUNT(*) FROM investment_tracker.roles;
SELECT 'Usuarios: ' || COUNT(*) FROM investment_tracker.usuarios;
SELECT 'Plataformas: ' || COUNT(*) FROM investment_tracker.plataformas;
SELECT 'Comisiones: ' || COUNT(*) FROM investment_tracker.comisiones;
SELECT 'Transacciones: ' || COUNT(*) FROM investment_tracker.transacciones;

\echo '✅ Seed v2.0.0 (UUID) completado exitosamente'
