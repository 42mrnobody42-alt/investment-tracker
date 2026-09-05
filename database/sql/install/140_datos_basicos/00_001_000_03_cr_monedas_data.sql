-- =============================================
-- DATOS: monedas (54 divisas)
-- Versión: 00_001_000
-- =============================================

DO $$
DECLARE
    v_MON_USD UUID := '00000001-0001-0001-0001-000000000001';
    v_MON_COP UUID := '00000001-0001-0001-0001-000000000002';
    v_MON_EUR UUID := '00000001-0001-0001-0001-000000000003';
    v_MON_GBP UUID := '00000001-0001-0001-0001-000000000004';
BEGIN
    INSERT INTO investment_tracker.monedas (id, codigo, nombre, simbolo, pais) VALUES
    (v_MON_USD, 'USD', 'Dólar estadounidense', '$', 'Estados Unidos'),
    (v_MON_COP, 'COP', 'Peso colombiano', '$', 'Colombia'),
    (v_MON_EUR, 'EUR', 'Euro', '€', 'Unión Europea'),
    (v_MON_GBP, 'GBP', 'Libra esterlina', '£', 'Reino Unido')
    ON CONFLICT (codigo) DO NOTHING;

    INSERT INTO investment_tracker.monedas (codigo, nombre, simbolo, pais) VALUES
    ('CAD', 'Dólar canadiense', 'C$', 'Canadá'),
    ('MXN', 'Peso mexicano', 'Mex$', 'México'),
    ('BRL', 'Real brasileño', 'R$', 'Brasil'),
    ('ARS', 'Peso argentino', 'AR$', 'Argentina'),
    ('CLP', 'Peso chileno', 'CL$', 'Chile'),
    ('PEN', 'Sol peruano', 'S/', 'Perú'),
    ('UYU', 'Peso uruguayo', '$U', 'Uruguay'),
    ('VES', 'Bolívar venezolano', 'Bs.', 'Venezuela'),
    ('CRC', 'Colón costarricense', '₡', 'Costa Rica'),
    ('DOP', 'Peso dominicano', 'RD$', 'República Dominicana'),
    ('GTQ', 'Quetzal guatemalteco', 'Q', 'Guatemala'),
    ('HNL', 'Lempira hondureño', 'L', 'Honduras'),
    ('NIO', 'Córdoba nicaragüense', 'C$', 'Nicaragua'),
    ('PAB', 'Balboa panameño', 'B/.', 'Panamá'),
    ('PYG', 'Guaraní paraguayo', '₲', 'Paraguay'),
    ('BOB', 'Boliviano', 'Bs.', 'Bolivia'),
    ('CHF', 'Franco suizo', 'Fr', 'Suiza'),
    ('SEK', 'Corona sueca', 'kr', 'Suecia'),
    ('NOK', 'Corona noruega', 'kr', 'Noruega'),
    ('DKK', 'Corona danesa', 'kr', 'Dinamarca'),
    ('PLN', 'Złoty polaco', 'zł', 'Polonia'),
    ('CZK', 'Corona checa', 'Kč', 'República Checa'),
    ('HUF', 'Forinto húngaro', 'Ft', 'Hungría'),
    ('RON', 'Leu rumano', 'lei', 'Rumania'),
    ('TRY', 'Lira turca', '₺', 'Turquía'),
    ('RUB', 'Rublo ruso', '₽', 'Rusia'),
    ('UAH', 'Grivna ucraniana', '₴', 'Ucrania'),
    ('JPY', 'Yen japonés', '¥', 'Japón'),
    ('CNY', 'Yuan chino', '¥', 'China'),
    ('HKD', 'Dólar de Hong Kong', 'HK$', 'Hong Kong'),
    ('TWD', 'Dólar taiwanés', 'NT$', 'Taiwán'),
    ('KRW', 'Won surcoreano', '₩', 'Corea del Sur'),
    ('INR', 'Rupia india', '₹', 'India'),
    ('SGD', 'Dólar de Singapur', 'S$', 'Singapur'),
    ('MYR', 'Ringgit malayo', 'RM', 'Malasia'),
    ('IDR', 'Rupia indonesia', 'Rp', 'Indonesia'),
    ('THB', 'Baht tailandés', '฿', 'Tailandia'),
    ('PHP', 'Peso filipino', '₱', 'Filipinas'),
    ('VND', 'Dong vietnamita', '₫', 'Vietnam'),
    ('AUD', 'Dólar australiano', 'A$', 'Australia'),
    ('NZD', 'Dólar neozelandés', 'NZ$', 'Nueva Zelanda'),
    ('AED', 'Dírham de EAU', 'د.إ', 'Emiratos Árabes Unidos'),
    ('SAR', 'Riyal saudí', '﷼', 'Arabia Saudita'),
    ('QAR', 'Riyal qatarí', 'QR', 'Qatar'),
    ('ILS', 'Nuevo shéquel israelí', '₪', 'Israel'),
    ('ZAR', 'Rand sudafricano', 'R', 'Sudáfrica'),
    ('NGN', 'Naira nigeriano', '₦', 'Nigeria'),
    ('EGP', 'Libra egipcia', 'E£', 'Egipto'),
    ('MAD', 'Dírham marroquí', 'DH', 'Marruecos'),
    ('KES', 'Chelín keniano', 'KSh', 'Kenia'),
    ('GHS', 'Cedi ghanés', 'GH₵', 'Ghana')
    ON CONFLICT (codigo) DO NOTHING;
END $$;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Datos de monedas', '140_datos_basicos/00_001_000_03_cr_monedas_data.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Datos de monedas insertados (00_001_000)'
