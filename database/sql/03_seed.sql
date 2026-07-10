-- =============================================
-- INVESTMENT TRACKER - DATOS INICIALES (SEED)
-- Versión: 2.1.0
-- Descripción: Datos de prueba con UUID fijos
-- =============================================

\echo '🔍 Verificando datos existentes...'

-- =============================================
-- DEFINICIÓN DE UUIDs (variables del script)
-- =============================================
-- Usamos un bloque DO para declarar constantes UUID
DO $$
DECLARE
    -- Roles
    v_ROLE_ADMIN    UUID := 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d';
    v_ROLE_USER     UUID := 'b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e';
    v_ROLE_PREMIUM  UUID := 'c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f';
    
    -- Usuarios
    v_USER_DEMO      UUID := 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a';
    v_USER_ADMIN     UUID := 'e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8a9b';
    v_USER_INCOGNITO UUID := 'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c';
    
    -- Plataformas
    v_PLAT_ETORO      UUID := 'a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d';
    v_PLAT_IBKR       UUID := 'b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e';
    v_PLAT_ROBINHOOD  UUID := 'c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f';
    v_PLAT_BINANCE    UUID := 'd0e1f2a3-b4c5-4d6e-7f8a-9b0c1d2e3f4a';
    v_PLAT_TRII       UUID := 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b';
    
    -- Comisiones
    v_COM_ETORO      UUID := 'f2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c';
    v_COM_IBKR       UUID := 'a3b4c5d6-e7f8-4a9b-0c1d-2e3f4a5b6c7d';
    v_COM_ROBINHOOD  UUID := 'b4c5d6e7-f8a9-4b0c-1d2e-3f4a5b6c7d8e';
    v_COM_BINANCE    UUID := 'c5d6e7f8-a9b0-4c1d-2e3f-4a5b6c7d8e9f';
    v_COM_TRII       UUID := 'd6e7f8a9-b0c1-4d2e-3f4a-5b6c7d8e9f0a';
    
    -- Transacciones
    v_TX_AAPL       UUID := 'e7f8a9b0-c1d2-4e3f-4a5b-6c7d8e9f0a1b';
    v_TX_TSLA       UUID := 'f8a9b0c1-d2e3-4f4a-5b6c-7d8e9f0a1b2c';
    v_TX_GOOGL      UUID := 'a9b0c1d2-e3f4-4a5b-6c7d-8e9f0a1b2c3d';
    v_TX_MSFT       UUID := 'b0c1d2e3-f4a5-4b6c-7d8e-9f0a1b2c3d4e';
    v_TX_ICHNCO_1   UUID := 'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f';
    v_TX_ICHNCO_2   UUID := 'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a';
    v_TX_NVDACO_1   UUID := 'e3f4a5b6-c7d8-4e9f-0a1b-2c3d4e5f6a7b';
    v_TX_ICHNCO_3   UUID := 'f4a5b6c7-d8e9-4f0a-1b2c-3d4e5f6a7b8c';
    v_TX_NVDACO_2   UUID := 'a5b6c7d8-e9f0-4a1b-2c3d-4e5f6a7b8c9d';
    v_TX_ICHNCO_4   UUID := 'b6c7d8e9-f0a1-4b2c-3d4e-5f6a7b8c9d0e';
    v_TX_ICHNCO_5   UUID := 'c7d8e9f0-a1b2-4c3d-4e5f-6a7b8c9d0e1f';
    
BEGIN
    -- =============================================
    -- ROLES
    -- =============================================
    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_ADMIN, 'ROLE_ADMIN', 'Administrador del sistema con acceso total'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_ADMIN');

    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_USER, 'ROLE_USER', 'Usuario regular con funcionalidades básicas'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_USER');

    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_PREMIUM, 'ROLE_PREMIUM', 'Usuario premium con acceso a calculadora avanzada'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_PREMIUM');

    RAISE NOTICE '✅ Roles verificados';

    -- =============================================
    -- USUARIO DEMO
    -- =============================================
    INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo)
    SELECT v_USER_DEMO, 'demo_user',
           '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
           'demo@investment-tracker.com', 'Usuario Demo'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'demo_user');

    INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
    SELECT v_USER_DEMO, v_ROLE_USER
    WHERE NOT EXISTS (
        SELECT 1 FROM investment_tracker.usuario_roles WHERE usuario_id = v_USER_DEMO AND rol_id = v_ROLE_USER
    );

    RAISE NOTICE '✅ Usuario demo verificado';

    -- =============================================
    -- USUARIO ADMIN
    -- =============================================
    INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo)
    SELECT v_USER_ADMIN, 'admin',
           '$2a$10$8K1p/a0dL1LXMIgoEDFrwOfMQkf9RlFP0KxDsF3jkHNGOofQQUmSi',
           'admin@investment-tracker.com', 'Administrador'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'admin');

    INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
    SELECT v_USER_ADMIN, r.id
    FROM investment_tracker.roles r
    WHERE r.nombre IN ('ROLE_ADMIN', 'ROLE_USER')
    AND NOT EXISTS (
        SELECT 1 FROM investment_tracker.usuario_roles WHERE usuario_id = v_USER_ADMIN AND rol_id = r.id
    );

    RAISE NOTICE '✅ Usuario admin verificado';

    -- =============================================
    -- USUARIO INCOGNITO
    -- =============================================
    INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo)
    SELECT v_USER_INCOGNITO, 'incognito',
           '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
           '42mrnobody42@gmail.com', 'Usuario Premium incognito'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'incognito');

    INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
    SELECT v_USER_INCOGNITO, r.id
    FROM investment_tracker.roles r
    WHERE r.nombre IN ('ROLE_PREMIUM', 'ROLE_USER')
    AND NOT EXISTS (
        SELECT 1 FROM investment_tracker.usuario_roles WHERE usuario_id = v_USER_INCOGNITO AND rol_id = r.id
    );

    RAISE NOTICE '✅ Usuario incognito verificado';

    -- =============================================
    -- PLATAFORMAS
    -- =============================================
    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
    SELECT v_PLAT_ETORO, v_USER_DEMO, 'eToro', 'Plataforma de trading social y copy trading', 'broker'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_DEMO AND nombre = 'eToro');

    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
    SELECT v_PLAT_IBKR, v_USER_DEMO, 'Interactive Brokers', 'Broker profesional con acceso a mercados globales', 'broker'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_DEMO AND nombre = 'Interactive Brokers');

    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
    SELECT v_PLAT_ROBINHOOD, v_USER_DEMO, 'Robinhood', 'App de trading sin comisiones', 'broker'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_DEMO AND nombre = 'Robinhood');

    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
    SELECT v_PLAT_BINANCE, v_USER_DEMO, 'Binance', 'Exchange de criptomonedas', 'exchange'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_DEMO AND nombre = 'Binance');

    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo)
    SELECT v_PLAT_TRII, v_USER_INCOGNITO, 'Trii', 'Broker de Colombia con productos latinoamericanos, estadounidense y chinos', 'broker'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_INCOGNITO AND nombre = 'Trii');

    RAISE NOTICE '✅ Plataformas verificadas';

    -- =============================================
    -- COMISIONES
    -- =============================================
    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
    SELECT v_COM_ETORO, v_PLAT_ETORO, 0.0050, 0.00, 'Comisión estándar eToro 0.5%', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_ETORO);

    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
    SELECT v_COM_IBKR, v_PLAT_IBKR, 0.0010, 1.00, 'Comisión IBKR Pro', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_IBKR);

    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
    SELECT v_COM_ROBINHOOD, v_PLAT_ROBINHOOD, 0.0000, 0.00, 'Sin comisiones', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_ROBINHOOD);

    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
    SELECT v_COM_BINANCE, v_PLAT_BINANCE, 0.0010, 0.00, 'Comisión estándar Binance 0.1%', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_BINANCE);

    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
    SELECT v_COM_TRII, v_PLAT_TRII, NULL, 14875.00, 'Comisión fija Trii $14,875 COP', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_TRII);

    RAISE NOTICE '✅ Comisiones verificadas';

    -- =============================================
    -- TRANSACCIONES demo_user
    -- =============================================
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_AAPL, v_USER_DEMO, v_PLAT_ETORO, 'COMPRA', 'AAPL', 'Apple Inc.', 10, 175.50, 8.78, 1763.78, '2024-01-15 10:30:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_AAPL);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_TSLA, v_USER_DEMO, v_PLAT_ETORO, 'COMPRA', 'TSLA', 'Tesla Inc.', 5, 245.30, 6.13, 1232.63, '2024-02-01 11:00:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_TSLA);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_GOOGL, v_USER_DEMO, v_PLAT_IBKR, 'COMPRA', 'GOOGL', 'Alphabet Inc.', 3, 140.50, 1.42, 422.92, '2024-03-01 09:45:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_GOOGL);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_MSFT, v_USER_DEMO, v_PLAT_ETORO, 'COMPRA', 'MSFT', 'Microsoft Corp.', 8, 380.75, 15.23, 3061.23, '2024-03-10 15:20:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_MSFT);

    RAISE NOTICE '✅ Transacciones demo_user verificadas';

    -- =============================================
    -- TRANSACCIONES incognito - Trii (COP)
    -- Horas Colombia (UTC-5) → UTC
    -- =============================================
    -- ICHNCO 28 x $18,360 - 23 jun 2026 10:41 COT = 15:41 UTC
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_1, v_USER_INCOGNITO, v_PLAT_TRII, 'COMPRA', 'ICHNCO', 'iShares Colombia', 28, 18360.00, 14875.00, 528955.00, '2026-06-23 15:41:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_1);

    -- ICHNCO 13 x $20,300 - 18 jun 2026 07:36 COT = 12:36 UTC
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_2, v_USER_INCOGNITO, v_PLAT_TRII, 'COMPRA', 'ICHNCO', 'iShares Colombia', 13, 20300.00, 14875.00, 278775.00, '2026-06-18 12:36:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_2);

    -- NVDACO 2 x $739,980 - 19 jun 2026 10:16 COT = 15:16 UTC
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_NVDACO_1, v_USER_INCOGNITO, v_PLAT_TRII, 'COMPRA', 'NVDACO', 'NVIDIA Colombia', 2, 739980.00, 14875.00, 1494835.00, '2026-06-19 15:16:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_NVDACO_1);

    -- ICHNCO 4 x $19,100 - 17 jun 2026 09:22 COT = 14:22 UTC
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_3, v_USER_INCOGNITO, v_PLAT_TRII, 'COMPRA', 'ICHNCO', 'iShares Colombia', 4, 19100.00, 14875.00, 91275.00, '2026-06-17 14:22:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_3);

    -- NVDACO 2 x $714,460 - 17 jun 2026 09:21 COT = 14:21 UTC
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_NVDACO_2, v_USER_INCOGNITO, v_PLAT_TRII, 'COMPRA', 'NVDACO', 'NVIDIA Colombia', 2, 714460.00, 14875.00, 1443795.00, '2026-06-17 14:21:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_NVDACO_2);

    -- ICHNCO 111 x $20,500 - 9 jun 2026 07:03 COT = 12:03 UTC
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_4, v_USER_INCOGNITO, v_PLAT_TRII, 'COMPRA', 'ICHNCO', 'iShares Colombia', 111, 20500.00, 14875.00, 2290375.00, '2026-06-09 12:03:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_4);

    -- ICHNCO 57 x $22,000 - 21 may 2026 07:16 COT = 12:16 UTC
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_5, v_USER_INCOGNITO, v_PLAT_TRII, 'COMPRA', 'ICHNCO', 'iShares Colombia', 57, 22000.00, 14875.00, 1268875.00, '2026-05-21 12:16:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_5);

    RAISE NOTICE '✅ Transacciones incognito verificadas';
    
END $$;

-- =============================================
-- RESUMEN FINAL
-- =============================================
SELECT '📊 DATOS ACTUALES (UUID v2.1.0):' as info;
SELECT '  Roles: ' || COUNT(*) FROM investment_tracker.roles;
SELECT '  Usuarios: ' || COUNT(*) FROM investment_tracker.usuarios;
SELECT '  Plataformas: ' || COUNT(*) FROM investment_tracker.plataformas;
SELECT '  Comisiones: ' || COUNT(*) FROM investment_tracker.comisiones;
SELECT '  Transacciones: ' || COUNT(*) FROM investment_tracker.transacciones;

\echo '✅ Seed v2.1.0 completado exitosamente'
