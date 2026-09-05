-- =============================================
-- DATOS: plataformas
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
    v_PLAT_ROBINHOOD  UUID := 'c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f';
    v_PLAT_BINANCE    UUID := 'd0e1f2a3-b4c5-4d6e-7f8a-9b0c1d2e3f4a';
    v_PLAT_TRII       UUID := 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b';
BEGIN
    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo, moneda_id)
    SELECT v_PLAT_ETORO, v_USER_DEMO, 'eToro', 'Plataforma de trading social y copy trading', 'broker', v_MON_USD
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_DEMO AND nombre = 'eToro');

    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo, moneda_id)
    SELECT v_PLAT_IBKR, v_USER_DEMO, 'Interactive Brokers', 'Broker profesional con acceso a mercados globales', 'broker', v_MON_USD
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_DEMO AND nombre = 'Interactive Brokers');

    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo, moneda_id)
    SELECT v_PLAT_ROBINHOOD, v_USER_DEMO, 'Robinhood', 'App de trading sin comisiones', 'broker', v_MON_USD
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_DEMO AND nombre = 'Robinhood');

    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo, moneda_id)
    SELECT v_PLAT_BINANCE, v_USER_DEMO, 'Binance', 'Exchange de criptomonedas', 'exchange', v_MON_USD
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_DEMO AND nombre = 'Binance');

    INSERT INTO investment_tracker.plataformas (id, usuario_id, nombre, descripcion, tipo, moneda_id)
    SELECT v_PLAT_TRII, v_USER_INCOGNITO, 'Trii', 'Broker de Colombia con productos latinoamericanos, estadounidense y chinos', 'broker', v_MON_COP
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.plataformas WHERE usuario_id = v_USER_INCOGNITO AND nombre = 'Trii');
END $$;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Datos de plataformas', '140_datos_basicos/00_001_000_04_cr_plataformas_data.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Datos de plataformas insertados (00_001_000)'
