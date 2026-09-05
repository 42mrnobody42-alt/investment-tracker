-- =============================================
-- FUNCIÓN: resumen_inversiones
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '90_funciones/00_001_000_03_cr_resumen_inversiones.sql'
    ) THEN
        RAISE NOTICE '⚠️  Función resumen_inversiones 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando función resumen_inversiones...';
END $$;

CREATE OR REPLACE FUNCTION investment_tracker.resumen_inversiones(
    p_usuario_id UUID
) RETURNS TABLE(
    simbolo VARCHAR(20),
    empresa_nombre VARCHAR(200),
    cantidad_actual INTEGER,
    precio_promedio_compra DECIMAL(10,4),
    total_invertido DECIMAL(10,2),
    total_comisiones DECIMAL(10,2),
    ultima_transaccion TIMESTAMP,
    cantidad_compras BIGINT,
    cantidad_ventas BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.simbolo::VARCHAR(20),
        MAX(t.empresa_nombre)::VARCHAR(200),
        SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.cantidad ELSE -t.cantidad END)::INTEGER,
        ROUND(AVG(CASE WHEN t.tipo = 'COMPRA' THEN t.precio_unitario ELSE NULL END)::numeric, 4)::DECIMAL(10,4),
        SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.valor_total ELSE 0 END)::DECIMAL(10,2),
        SUM(t.comision)::DECIMAL(10,2),
        MAX(t.fecha_transaccion),
        COUNT(*) FILTER (WHERE t.tipo = 'COMPRA'),
        COUNT(*) FILTER (WHERE t.tipo = 'VENTA')
    FROM investment_tracker.transacciones t
    WHERE t.usuario_id = p_usuario_id
    GROUP BY t.simbolo
    HAVING SUM(CASE WHEN t.tipo = 'COMPRA' THEN t.cantidad ELSE -t.cantidad END) > 0
    ORDER BY total_invertido DESC;
END;
$$ LANGUAGE plpgsql;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Función resumen_inversiones', '90_funciones/00_001_000_03_cr_resumen_inversiones.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Función resumen_inversiones instalada (00_001_000)'
