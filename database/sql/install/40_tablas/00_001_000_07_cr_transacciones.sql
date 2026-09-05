-- =============================================
-- TABLA: transacciones
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_07_cr_transacciones.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla transacciones 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla transacciones...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.transacciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    plataforma_id UUID REFERENCES investment_tracker.plataformas(id),
    moneda_id UUID REFERENCES investment_tracker.monedas(id),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('COMPRA', 'VENTA')),
    simbolo VARCHAR(20) NOT NULL,
    empresa_nombre VARCHAR(200),
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,4) NOT NULL,
    comision DECIMAL(10,2) DEFAULT 0,
    valor_total DECIMAL(10,2) NOT NULL,
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla transacciones', '40_tablas/00_001_000_07_cr_transacciones.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla transacciones creada (00_001_000)'
