-- =============================================
-- DATOS: transacciones
-- Versión: 00_001_000
-- =============================================

DO $$
DECLARE
    v_USER_DEMO      UUID := 'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a';
    v_USER_INCOGNITO UUID := 'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c';
    v_MON_USD UUID := '00000001-0001-0001-0001-000000000001';
    v_MON_COP UUID := '00000001-0001-0001-0001-000000000002';
    v_PLAT_ETORO      UUID := 'a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d';
    v_PLAT_IBKR       UUID := 'b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e';
    v_PLAT_TRII       UUID := 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b';
    v_TX_AAPL         UUID := 'e7f8a9b0-c1d2-4e3f-4a5b-6c7d8e9f0a1b';
    v_TX_TSLA         UUID := 'f8a9b0c1-d2e3-4f4a-5b6c-7d8e9f0a1b2c';
    v_TX_GOOGL        UUID := 'a9b0c1d2-e3f4-4a5b-6c7d-8e9f0a1b2c3d';
    v_TX_MSFT         UUID := 'b0c1d2e3-f4a5-4b6c-7d8e-9f0a1b2c3d4e';
    v_TX_ICHNCO_1     UUID := 'c1d2e3f4-a5b6-4c7d-8e9f-0a1b2c3d4e5f';
    v_TX_ICHNCO_2     UUID := 'd2e3f4a5-b6c7-4d8e-9f0a-1b2c3d4e5f6a';
    v_TX_NVDACO_1     UUID := 'e3f4a5b6-c7d8-4e9f-0a1b-2c3d4e5f6a7b';
    v_TX_ICHNCO_3     UUID := 'f4a5b6c7-d8e9-4f0a-1b2c-3d4e5f6a7b8c';
    v_TX_NVDACO_2     UUID := 'a5b6c7d8-e9f0-4a1b-2c3d-4e5f6a7b8c9d';
    v_TX_ICHNCO_4     UUID := 'b6c7d8e9-f0a1-4b2c-3d4e-5f6a7b8c9d0e';
    v_TX_ICHNCO_5     UUID := 'c7d8e9f0-a1b2-4c3d-4e5f-6a7b8c9d0e1f';
BEGIN
    -- demo_user
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_AAPL, v_USER_DEMO, v_PLAT_ETORO, v_MON_USD, 'COMPRA', 'AAPL', 'Apple Inc.', 10, 175.50, 8.78, 1763.78, '2024-01-15 10:30:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_AAPL);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_TSLA, v_USER_DEMO, v_PLAT_ETORO, v_MON_USD, 'COMPRA', 'TSLA', 'Tesla Inc.', 5, 245.30, 6.13, 1232.63, '2024-02-01 11:00:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_TSLA);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_GOOGL, v_USER_DEMO, v_PLAT_IBKR, v_MON_USD, 'COMPRA', 'GOOGL', 'Alphabet Inc.', 3, 140.50, 1.42, 422.92, '2024-03-01 09:45:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_GOOGL);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_MSFT, v_USER_DEMO, v_PLAT_ETORO, v_MON_USD, 'COMPRA', 'MSFT', 'Microsoft Corp.', 8, 380.75, 15.23, 3061.23, '2024-03-10 15:20:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_MSFT);

    -- incognito
    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_1, v_USER_INCOGNITO, v_PLAT_TRII, v_MON_COP, 'COMPRA', 'ICHNCO', 'iShares Colombia', 28, 18360.00, 14875.00, 528955.00, '2026-06-23 15:41:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_1);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_2, v_USER_INCOGNITO, v_PLAT_TRII, v_MON_COP, 'COMPRA', 'ICHNCO', 'iShares Colombia', 13, 20300.00, 14875.00, 278775.00, '2026-06-18 12:36:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_2);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_NVDACO_1, v_USER_INCOGNITO, v_PLAT_TRII, v_MON_COP, 'COMPRA', 'NVDACO', 'NVIDIA Colombia', 2, 739980.00, 14875.00, 1494835.00, '2026-06-19 15:16:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_NVDACO_1);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_3, v_USER_INCOGNITO, v_PLAT_TRII, v_MON_COP, 'COMPRA', 'ICHNCO', 'iShares Colombia', 4, 19100.00, 14875.00, 91275.00, '2026-06-17 14:22:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_3);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_NVDACO_2, v_USER_INCOGNITO, v_PLAT_TRII, v_MON_COP, 'COMPRA', 'NVDACO', 'NVIDIA Colombia', 2, 714460.00, 14875.00, 1443795.00, '2026-06-17 14:21:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_NVDACO_2);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_4, v_USER_INCOGNITO, v_PLAT_TRII, v_MON_COP, 'COMPRA', 'ICHNCO', 'iShares Colombia', 111, 20500.00, 14875.00, 2290375.00, '2026-06-09 12:03:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_4);

    INSERT INTO investment_tracker.transacciones (id, usuario_id, plataforma_id, moneda_id, tipo, simbolo, empresa_nombre, cantidad, precio_unitario, comision, valor_total, fecha_transaccion)
    SELECT v_TX_ICHNCO_5, v_USER_INCOGNITO, v_PLAT_TRII, v_MON_COP, 'COMPRA', 'ICHNCO', 'iShares Colombia', 57, 22000.00, 14875.00, 1268875.00, '2026-05-21 12:16:00'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.transacciones WHERE id = v_TX_ICHNCO_5);
END $$;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Datos de transacciones', '140_datos_basicos/00_001_000_06_cr_transacciones_data.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Datos de transacciones insertados (00_001_000)'
