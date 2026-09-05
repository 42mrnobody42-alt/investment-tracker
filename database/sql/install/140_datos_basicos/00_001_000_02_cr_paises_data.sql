-- =============================================
-- DATOS: paises (con moneda_id mediante subconsulta)
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '140_datos_basicos/00_001_000_02_cr_paises_data.sql'
    ) THEN
        RAISE NOTICE '⚠️  Datos de países 00_001_000 ya instalados. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Insertando países...';
END $$;

INSERT INTO investment_tracker.paises (id, nombre, codigo_iso, indicativo_celular, moneda_id) VALUES
('10000000-0001-0001-0001-000000000001', 'Estados Unidos', 'USA', '+1', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'USD')),
('10000000-0001-0001-0001-000000000002', 'Colombia', 'COL', '+57', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'COP')),
('10000000-0001-0001-0001-000000000003', 'Unión Europea', 'EU', '+00', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'EUR')),
('10000000-0001-0001-0001-000000000004', 'Reino Unido', 'GBR', '+44', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'GBP')),
('10000000-0001-0001-0001-000000000005', 'Canadá', 'CAN', '+1', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'CAD')),
('10000000-0001-0001-0001-000000000006', 'México', 'MEX', '+52', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'MXN')),
('10000000-0001-0001-0001-000000000007', 'Brasil', 'BRA', '+55', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'BRL')),
('10000000-0001-0001-0001-000000000008', 'Argentina', 'ARG', '+54', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'ARS')),
('10000000-0001-0001-0001-000000000009', 'Chile', 'CHL', '+56', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'CLP')),
('10000000-0001-0001-0001-000000000010', 'Perú', 'PER', '+51', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'PEN')),
('10000000-0001-0001-0001-000000000011', 'Uruguay', 'URY', '+598', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'UYU')),
('10000000-0001-0001-0001-000000000012', 'Venezuela', 'VEN', '+58', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'VES')),
('10000000-0001-0001-0001-000000000013', 'Costa Rica', 'CRI', '+506', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'CRC')),
('10000000-0001-0001-0001-000000000014', 'República Dominicana', 'DOM', '+1', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'DOP')),
('10000000-0001-0001-0001-000000000015', 'Guatemala', 'GTM', '+502', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'GTQ')),
('10000000-0001-0001-0001-000000000016', 'Honduras', 'HND', '+504', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'HNL')),
('10000000-0001-0001-0001-000000000017', 'Nicaragua', 'NIC', '+505', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'NIO')),
('10000000-0001-0001-0001-000000000018', 'Panamá', 'PAN', '+507', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'PAB')),
('10000000-0001-0001-0001-000000000019', 'Paraguay', 'PRY', '+595', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'PYG')),
('10000000-0001-0001-0001-000000000020', 'Bolivia', 'BOL', '+591', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'BOB')),
('10000000-0001-0001-0001-000000000021', 'Suiza', 'CHE', '+41', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'CHF')),
('10000000-0001-0001-0001-000000000022', 'Suecia', 'SWE', '+46', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'SEK')),
('10000000-0001-0001-0001-000000000023', 'Noruega', 'NOR', '+47', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'NOK')),
('10000000-0001-0001-0001-000000000024', 'Dinamarca', 'DNK', '+45', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'DKK')),
('10000000-0001-0001-0001-000000000025', 'Polonia', 'POL', '+48', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'PLN')),
('10000000-0001-0001-0001-000000000026', 'República Checa', 'CZE', '+420', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'CZK')),
('10000000-0001-0001-0001-000000000027', 'Hungría', 'HUN', '+36', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'HUF')),
('10000000-0001-0001-0001-000000000028', 'Rumania', 'ROU', '+40', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'RON')),
('10000000-0001-0001-0001-000000000029', 'Turquía', 'TUR', '+90', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'TRY')),
('10000000-0001-0001-0001-000000000030', 'Rusia', 'RUS', '+7', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'RUB')),
('10000000-0001-0001-0001-000000000031', 'Ucrania', 'UKR', '+380', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'UAH')),
('10000000-0001-0001-0001-000000000032', 'Japón', 'JPN', '+81', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'JPY')),
('10000000-0001-0001-0001-000000000033', 'China', 'CHN', '+86', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'CNY')),
('10000000-0001-0001-0001-000000000034', 'Hong Kong', 'HKG', '+852', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'HKD')),
('10000000-0001-0001-0001-000000000035', 'Taiwán', 'TWN', '+886', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'TWD')),
('10000000-0001-0001-0001-000000000036', 'Corea del Sur', 'KOR', '+82', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'KRW')),
('10000000-0001-0001-0001-000000000037', 'India', 'IND', '+91', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'INR')),
('10000000-0001-0001-0001-000000000038', 'Singapur', 'SGP', '+65', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'SGD')),
('10000000-0001-0001-0001-000000000039', 'Malasia', 'MYS', '+60', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'MYR')),
('10000000-0001-0001-0001-000000000040', 'Indonesia', 'IDN', '+62', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'IDR')),
('10000000-0001-0001-0001-000000000041', 'Tailandia', 'THA', '+66', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'THB')),
('10000000-0001-0001-0001-000000000042', 'Filipinas', 'PHL', '+63', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'PHP')),
('10000000-0001-0001-0001-000000000043', 'Vietnam', 'VNM', '+84', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'VND')),
('10000000-0001-0001-0001-000000000044', 'Australia', 'AUS', '+61', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'AUD')),
('10000000-0001-0001-0001-000000000045', 'Nueva Zelanda', 'NZL', '+64', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'NZD')),
('10000000-0001-0001-0001-000000000046', 'Emiratos Árabes Unidos', 'ARE', '+971', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'AED')),
('10000000-0001-0001-0001-000000000047', 'Arabia Saudita', 'SAU', '+966', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'SAR')),
('10000000-0001-0001-0001-000000000048', 'Qatar', 'QAT', '+974', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'QAR')),
('10000000-0001-0001-0001-000000000049', 'Israel', 'ISR', '+972', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'ILS')),
('10000000-0001-0001-0001-000000000050', 'Sudáfrica', 'ZAF', '+27', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'ZAR')),
('10000000-0001-0001-0001-000000000051', 'Nigeria', 'NGA', '+234', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'NGN')),
('10000000-0001-0001-0001-000000000052', 'Egipto', 'EGY', '+20', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'EGP')),
('10000000-0001-0001-0001-000000000053', 'Marruecos', 'MAR', '+212', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'MAD')),
('10000000-0001-0001-0001-000000000054', 'Kenia', 'KEN', '+254', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'KES')),
('10000000-0001-0001-0001-000000000055', 'Ghana', 'GHA', '+233', (SELECT id FROM investment_tracker.monedas WHERE codigo = 'GHS'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Datos de países (todos los de monedas)', '140_datos_basicos/00_001_000_02_cr_paises_data.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Datos de países insertados (00_001_000)'
