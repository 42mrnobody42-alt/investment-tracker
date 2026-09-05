-- =============================================
-- DATOS: comisiones
-- Versión: 00_001_000
-- =============================================

DO $$
DECLARE
    v_PLAT_ETORO      UUID := 'a7b8c9d0-e1f2-4a3b-4c5d-6e7f8a9b0c1d';
    v_PLAT_IBKR       UUID := 'b8c9d0e1-f2a3-4b4c-5d6e-7f8a9b0c1d2e';
    v_PLAT_ROBINHOOD  UUID := 'c9d0e1f2-a3b4-4c5d-6e7f-8a9b0c1d2e3f';
    v_PLAT_BINANCE    UUID := 'd0e1f2a3-b4c5-4d6e-7f8a-9b0c1d2e3f4a';
    v_PLAT_TRII       UUID := 'e1f2a3b4-c5d6-4e7f-8a9b-0c1d2e3f4a5b';
    v_MON_USD UUID := '00000001-0001-0001-0001-000000000001';
    v_MON_COP UUID := '00000001-0001-0001-0001-000000000002';
    v_COM_ETORO       UUID := 'f2a3b4c5-d6e7-4f8a-9b0c-1d2e3f4a5b6c';
    v_COM_IBKR        UUID := 'a3b4c5d6-e7f8-4a9b-0c1d-2e3f4a5b6c7d';
    v_COM_ROBINHOOD   UUID := 'b4c5d6e7-f8a9-4b0c-1d2e-3f4a5b6c7d8e';
    v_COM_BINANCE     UUID := 'c5d6e7f8-a9b0-4c1d-2e3f-4a5b6c7d8e9f';
    v_COM_TRII        UUID := 'd6e7f8a9-b0c1-4d2e-3f4a-5b6c7d8e9f0a';
BEGIN
    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, moneda_id, descripcion, fecha_inicio)
    SELECT v_COM_ETORO, v_PLAT_ETORO, 0.0050, 0.00, v_MON_USD, 'Comisión estándar eToro 0.5%', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_ETORO);

    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, moneda_id, descripcion, fecha_inicio)
    SELECT v_COM_IBKR, v_PLAT_IBKR, 0.0010, 1.00, v_MON_USD, 'Comisión IBKR Pro', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_IBKR);

    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, moneda_id, descripcion, fecha_inicio)
    SELECT v_COM_ROBINHOOD, v_PLAT_ROBINHOOD, 0.0000, 0.00, v_MON_USD, 'Sin comisiones', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_ROBINHOOD);

    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, moneda_id, descripcion, fecha_inicio)
    SELECT v_COM_BINANCE, v_PLAT_BINANCE, 0.0010, 0.00, v_MON_USD, 'Comisión estándar Binance 0.1%', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_BINANCE);

    INSERT INTO investment_tracker.comisiones (id, plataforma_id, porcentaje, valor_fijo, moneda_id, descripcion, fecha_inicio)
    SELECT v_COM_TRII, v_PLAT_TRII, NULL, 14875.00, v_MON_COP, 'Comisión fija Trii $14,875 COP', '2024-01-01'::timestamp
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.comisiones WHERE plataforma_id = v_PLAT_TRII);
END $$;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Datos de comisiones', '140_datos_basicos/00_001_000_05_cr_comisiones_data.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Datos de comisiones insertados (00_001_000)'
