#!/bin/bash
# =============================================================================
# Script: generar_archivos_sql.sh
# Descripción: Genera la estructura de directorios y los archivos SQL individuales
#              para la versión 00_001_000, basado en los scripts existentes.
#              Cada archivo contiene un único objeto (tabla, función, índice, etc.)
# Uso:   ./generar_archivos_sql.sh
# =============================================================================

set -e

PROJECT_ROOT="/prog/datos/investment-tracker"
SQL_DIR="$PROJECT_ROOT/database/sql"
INSTALL_DIR="$SQL_DIR/install"
UPDATES_DIR="$SQL_DIR/updates"

VERSION="00"
RELEASE="001"
HOTFIX="000"
VERSION_TAG="${VERSION}_${RELEASE}_${HOTFIX}"

echo "🔧 Generando archivos SQL individuales para versión $VERSION_TAG..."

# Crear directorios
mkdir -p "$INSTALL_DIR" "$UPDATES_DIR"

for dir in 10_esquemas 20_extensiones 30_tipos 40_tablas 50_alter_tablas 60_restricciones 70_indices 80_vistas 90_funciones 100_procedimientos 110_disparadores 120_eventos 130_secuencias 140_datos_basicos 150_permisos 160_comentarios; do
    mkdir -p "$INSTALL_DIR/$dir"
    mkdir -p "$UPDATES_DIR/$dir"
done

# =============================================================================
# Crear archivos individuales
# =============================================================================

# ---------- 10_esquemas ----------
cat > "$INSTALL_DIR/10_esquemas/${VERSION_TAG}_01_cr_schema.sql" << 'EOF'
-- =============================================
-- ESQUEMA: investment_tracker
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '10_esquemas/00_001_000_01_cr_schema.sql'
    ) THEN
        RAISE NOTICE '⚠️  Esquema 00_001_000 ya instalado. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando esquema investment_tracker...';
END $$;

CREATE SCHEMA IF NOT EXISTS investment_tracker;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Creación de esquema', '10_esquemas/00_001_000_01_cr_schema.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Esquema investment_tracker creado (00_001_000)'
EOF

# ---------- 20_extensiones ----------
cat > "$INSTALL_DIR/20_extensiones/${VERSION_TAG}_01_cr_extensiones.sql" << 'EOF'
-- =============================================
-- EXTENSIONES: PostgreSQL
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '20_extensiones/00_001_000_01_cr_extensiones.sql'
    ) THEN
        RAISE NOTICE '⚠️  Extensiones 00_001_000 ya instaladas. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando extensiones...';
END $$;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Extensiones (uuid-ossp)', '20_extensiones/00_001_000_01_cr_extensiones.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Extensiones instaladas (00_001_000)'
EOF

# ---------- 40_tablas (una por tabla) ----------
# roles
cat > "$INSTALL_DIR/40_tablas/${VERSION_TAG}_01_cr_roles.sql" << 'EOF'
-- =============================================
-- TABLA: roles
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_01_cr_roles.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla roles 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla roles...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla roles', '40_tablas/00_001_000_01_cr_roles.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla roles creada (00_001_000)'
EOF

# usuarios
cat > "$INSTALL_DIR/40_tablas/${VERSION_TAG}_02_cr_usuarios.sql" << 'EOF'
-- =============================================
-- TABLA: usuarios
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_02_cr_usuarios.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla usuarios 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla usuarios...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre_completo VARCHAR(200),
    activo BOOLEAN DEFAULT true,
    ultimo_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla usuarios', '40_tablas/00_001_000_02_cr_usuarios.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla usuarios creada (00_001_000)'
EOF

# usuario_roles
cat > "$INSTALL_DIR/40_tablas/${VERSION_TAG}_03_cr_usuario_roles.sql" << 'EOF'
-- =============================================
-- TABLA: usuario_roles
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_03_cr_usuario_roles.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla usuario_roles 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla usuario_roles...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.usuario_roles (
    usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    rol_id UUID REFERENCES investment_tracker.roles(id) ON DELETE CASCADE,
    asignado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, rol_id)
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla usuario_roles', '40_tablas/00_001_000_03_cr_usuario_roles.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla usuario_roles creada (00_001_000)'
EOF

# monedas
cat > "$INSTALL_DIR/40_tablas/${VERSION_TAG}_04_cr_monedas.sql" << 'EOF'
-- =============================================
-- TABLA: monedas
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_04_cr_monedas.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla monedas 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla monedas...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.monedas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(3) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    simbolo VARCHAR(10),
    pais VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla monedas', '40_tablas/00_001_000_04_cr_monedas.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla monedas creada (00_001_000)'
EOF

# plataformas
cat > "$INSTALL_DIR/40_tablas/${VERSION_TAG}_05_cr_plataformas.sql" << 'EOF'
-- =============================================
-- TABLA: plataformas
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_05_cr_plataformas.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla plataformas 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla plataformas...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.plataformas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(50),
    moneda_id UUID REFERENCES investment_tracker.monedas(id),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, nombre)
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla plataformas', '40_tablas/00_001_000_05_cr_plataformas.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla plataformas creada (00_001_000)'
EOF

# comisiones
cat > "$INSTALL_DIR/40_tablas/${VERSION_TAG}_06_cr_comisiones.sql" << 'EOF'
-- =============================================
-- TABLA: comisiones
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_06_cr_comisiones.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla comisiones 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla comisiones...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.comisiones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plataforma_id UUID REFERENCES investment_tracker.plataformas(id) ON DELETE CASCADE,
    porcentaje DECIMAL(5,4),
    valor_fijo DECIMAL(10,2),
    moneda_id UUID REFERENCES investment_tracker.monedas(id),
    descripcion VARCHAR(200),
    fecha_inicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_comision CHECK (porcentaje IS NOT NULL OR valor_fijo IS NOT NULL)
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla comisiones', '40_tablas/00_001_000_06_cr_comisiones.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla comisiones creada (00_001_000)'
EOF

# transacciones
cat > "$INSTALL_DIR/40_tablas/${VERSION_TAG}_07_cr_transacciones.sql" << 'EOF'
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
EOF

# calculos_hist
cat > "$INSTALL_DIR/40_tablas/${VERSION_TAG}_08_cr_calculos_hist.sql" << 'EOF'
-- =============================================
-- TABLA: calculos_hist
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '40_tablas/00_001_000_08_cr_calculos_hist.sql'
    ) THEN
        RAISE NOTICE '⚠️  Tabla calculos_hist 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando tabla calculos_hist...';
END $$;

CREATE TABLE IF NOT EXISTS investment_tracker.calculos_hist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    plataforma_id UUID REFERENCES investment_tracker.plataformas(id),
    simbolo VARCHAR(20) NOT NULL,
    ganancia_deseada DECIMAL(10,2) NOT NULL,
    precio_minimo_calculado DECIMAL(10,4),
    cantidad_optima INTEGER,
    comision_estimada DECIMAL(10,2),
    ganancia_neta_estimada DECIMAL(10,2),
    parametros_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Tabla calculos_hist', '40_tablas/00_001_000_08_cr_calculos_hist.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Tabla calculos_hist creada (00_001_000)'
EOF

# ---------- 70_indices (todos en un archivo) ----------
cat > "$INSTALL_DIR/70_indices/${VERSION_TAG}_01_cr_indices.sql" << 'EOF'
-- =============================================
-- ÍNDICES: Para rendimiento
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '70_indices/00_001_000_01_cr_indices.sql'
    ) THEN
        RAISE NOTICE '⚠️  Índices 00_001_000 ya instalados. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Creando índices...';
END $$;

CREATE INDEX IF NOT EXISTS idx_transacciones_usuario ON investment_tracker.transacciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_transacciones_simbolo ON investment_tracker.transacciones(simbolo);
CREATE INDEX IF NOT EXISTS idx_transacciones_fecha ON investment_tracker.transacciones(fecha_transaccion);
CREATE INDEX IF NOT EXISTS idx_transacciones_tipo ON investment_tracker.transacciones(tipo);
CREATE INDEX IF NOT EXISTS idx_transacciones_usuario_simbolo ON investment_tracker.transacciones(usuario_id, simbolo);
CREATE INDEX IF NOT EXISTS idx_comisiones_plataforma ON investment_tracker.comisiones(plataforma_id);
CREATE INDEX IF NOT EXISTS idx_comisiones_fecha ON investment_tracker.comisiones(fecha_inicio, fecha_fin);
CREATE INDEX IF NOT EXISTS idx_comisiones_activas ON investment_tracker.comisiones(plataforma_id, activo) WHERE activo = true;
CREATE INDEX IF NOT EXISTS idx_monedas_codigo ON investment_tracker.monedas(codigo);

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Índices de rendimiento', '70_indices/00_001_000_01_cr_indices.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Índices creados (00_001_000)'
EOF

# ---------- 90_funciones (una por función) ----------
# Función 1: obtener_comision_actual
cat > "$INSTALL_DIR/90_funciones/${VERSION_TAG}_01_cr_obtener_comision_actual.sql" << 'EOF'
-- =============================================
-- FUNCIÓN: obtener_comision_actual
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '90_funciones/00_001_000_01_cr_obtener_comision_actual.sql'
    ) THEN
        RAISE NOTICE '⚠️  Función obtener_comision_actual 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando función obtener_comision_actual...';
END $$;

CREATE OR REPLACE FUNCTION investment_tracker.obtener_comision_actual(
    p_plataforma_id UUID
) RETURNS TABLE(
    porcentaje DECIMAL(5,4),
    valor_fijo DECIMAL(10,2),
    descripcion VARCHAR(200)
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.porcentaje, c.valor_fijo, c.descripcion
    FROM investment_tracker.comisiones c
    WHERE c.plataforma_id = p_plataforma_id
      AND c.activo = true
      AND c.fecha_inicio <= CURRENT_TIMESTAMP
      AND (c.fecha_fin IS NULL OR c.fecha_fin >= CURRENT_TIMESTAMP)
    ORDER BY c.fecha_inicio DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Función obtener_comision_actual', '90_funciones/00_001_000_01_cr_obtener_comision_actual.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Función obtener_comision_actual instalada (00_001_000)'
EOF

# Función 2: calcular_comision
cat > "$INSTALL_DIR/90_funciones/${VERSION_TAG}_02_cr_calcular_comision.sql" << 'EOF'
-- =============================================
-- FUNCIÓN: calcular_comision
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '90_funciones/00_001_000_02_cr_calcular_comision.sql'
    ) THEN
        RAISE NOTICE '⚠️  Función calcular_comision 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando función calcular_comision...';
END $$;

CREATE OR REPLACE FUNCTION investment_tracker.calcular_comision(
    p_plataforma_id UUID,
    p_valor_transaccion DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    v_comision DECIMAL(10,2) := 0;
    v_porcentaje DECIMAL(5,4);
    v_valor_fijo DECIMAL(10,2);
BEGIN
    SELECT c.porcentaje, c.valor_fijo 
    INTO v_porcentaje, v_valor_fijo
    FROM investment_tracker.comisiones c
    WHERE c.plataforma_id = p_plataforma_id
      AND c.activo = true
      AND c.fecha_inicio <= CURRENT_TIMESTAMP
      AND (c.fecha_fin IS NULL OR c.fecha_fin >= CURRENT_TIMESTAMP)
    ORDER BY c.fecha_inicio DESC
    LIMIT 1;
    
    IF v_porcentaje IS NOT NULL THEN
        v_comision := v_comision + (p_valor_transaccion * v_porcentaje);
    END IF;
    IF v_valor_fijo IS NOT NULL THEN
        v_comision := v_comision + v_valor_fijo;
    END IF;
    
    RETURN ROUND(v_comision::numeric, 2);
END;
$$ LANGUAGE plpgsql;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Función calcular_comision', '90_funciones/00_001_000_02_cr_calcular_comision.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Función calcular_comision instalada (00_001_000)'
EOF

# Función 3: resumen_inversiones
cat > "$INSTALL_DIR/90_funciones/${VERSION_TAG}_03_cr_resumen_inversiones.sql" << 'EOF'
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
EOF

# Función 4: calcular_venta_optima
cat > "$INSTALL_DIR/90_funciones/${VERSION_TAG}_04_cr_calcular_venta_optima.sql" << 'EOF'
-- =============================================
-- FUNCIÓN: calcular_venta_optima
-- Versión: 00_001_000
-- =============================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM investment_tracker.schema_version
        WHERE version = '00_001_000' AND script_name = '90_funciones/00_001_000_04_cr_calcular_venta_optima.sql'
    ) THEN
        RAISE NOTICE '⚠️  Función calcular_venta_optima 00_001_000 ya instalada. Omitiendo.';
        RETURN;
    END IF;
    RAISE NOTICE '🚀 Instalando función calcular_venta_optima...';
END $$;

CREATE OR REPLACE FUNCTION investment_tracker.calcular_venta_optima(
    p_usuario_id UUID,
    p_simbolo VARCHAR(20),
    p_ganancia_deseada DECIMAL(10,2),
    p_plataforma_id UUID
) RETURNS TABLE(
    precio_minimo DECIMAL(10,4),
    cantidad_optima INTEGER,
    comision_estimada DECIMAL(10,2),
    ingreso_bruto DECIMAL(10,2),
    ganancia_neta DECIMAL(10,2)
) AS $$
DECLARE
    v_cantidad_actual INTEGER;
    v_costo_promedio DECIMAL(10,4);
    v_comision_compra DECIMAL(10,2);
    v_porcentaje_comision DECIMAL(5,4);
    v_valor_fijo_comision DECIMAL(10,2);
    v_costo_total DECIMAL(10,2);
    v_precio_minimo_calc DECIMAL(10,4);
    v_comision_venta DECIMAL(10,2);
BEGIN
    SELECT 
        SUM(CASE WHEN tipo = 'COMPRA' THEN cantidad ELSE -cantidad END),
        AVG(CASE WHEN tipo = 'COMPRA' THEN precio_unitario ELSE NULL END),
        SUM(CASE WHEN tipo = 'COMPRA' THEN comision ELSE 0 END)
    INTO v_cantidad_actual, v_costo_promedio, v_comision_compra
    FROM investment_tracker.transacciones
    WHERE usuario_id = p_usuario_id 
      AND simbolo = p_simbolo
      AND tipo IN ('COMPRA', 'VENTA');
    
    IF v_cantidad_actual IS NULL OR v_cantidad_actual <= 0 THEN
        RETURN;
    END IF;
    
    SELECT porcentaje, valor_fijo
    INTO v_porcentaje_comision, v_valor_fijo_comision
    FROM investment_tracker.obtener_comision_actual(p_plataforma_id);
    
    v_costo_total := (v_cantidad_actual * v_costo_promedio) + v_comision_compra;
    
    IF v_porcentaje_comision IS NOT NULL AND v_porcentaje_comision > 0 THEN
        v_precio_minimo_calc := (v_costo_total + p_ganancia_deseada + COALESCE(v_valor_fijo_comision, 0)) / 
                                (v_cantidad_actual * (1 - v_porcentaje_comision));
    ELSE
        v_precio_minimo_calc := (v_costo_total + p_ganancia_deseada) / v_cantidad_actual;
    END IF;
    
    v_comision_venta := investment_tracker.calcular_comision(
        p_plataforma_id, 
        v_precio_minimo_calc * v_cantidad_actual
    );
    
    RETURN QUERY
    SELECT 
        ROUND(v_precio_minimo_calc::numeric, 4),
        v_cantidad_actual,
        v_comision_venta,
        ROUND((v_precio_minimo_calc * v_cantidad_actual)::numeric, 2),
        p_ganancia_deseada;
END;
$$ LANGUAGE plpgsql;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Función calcular_venta_optima', '90_funciones/00_001_000_04_cr_calcular_venta_optima.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Función calcular_venta_optima instalada (00_001_000)'
EOF

# ---------- 140_datos_basicos (un archivo por tabla a poblar) ----------
# roles_data
cat > "$INSTALL_DIR/140_datos_basicos/${VERSION_TAG}_01_cr_roles_data.sql" << 'EOF'
-- =============================================
-- DATOS: roles
-- Versión: 00_001_000
-- =============================================

DO $$
DECLARE
    v_ROLE_ADMIN    UUID := 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d';
    v_ROLE_USER     UUID := 'b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e';
    v_ROLE_PREMIUM  UUID := 'c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f';
BEGIN
    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_ADMIN, 'ROLE_ADMIN', 'Administrador del sistema con acceso total'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_ADMIN');

    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_USER, 'ROLE_USER', 'Usuario regular con funcionalidades básicas'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_USER');

    INSERT INTO investment_tracker.roles (id, nombre, descripcion) 
    SELECT v_ROLE_PREMIUM, 'ROLE_PREMIUM', 'Usuario premium con acceso a calculadora avanzada'
    WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_PREMIUM');
END $$;

INSERT INTO investment_tracker.schema_version (version, descripcion, script_name)
VALUES ('00_001_000', 'Datos de roles', '140_datos_basicos/00_001_000_01_cr_roles_data.sql')
ON CONFLICT (version, script_name) DO NOTHING;

\echo '✅ Datos de roles insertados (00_001_000)'
EOF

# usuarios_data
cat > "$INSTALL_DIR/140_datos_basicos/${VERSION_TAG}_02_cr_usuarios_data.sql" << 'EOF'
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
EOF

# monedas_data
cat > "$INSTALL_DIR/140_datos_basicos/${VERSION_TAG}_03_cr_monedas_data.sql" << 'EOF'
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
EOF

# plataformas_data
cat > "$INSTALL_DIR/140_datos_basicos/${VERSION_TAG}_04_cr_plataformas_data.sql" << 'EOF'
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
EOF

# comisiones_data
cat > "$INSTALL_DIR/140_datos_basicos/${VERSION_TAG}_05_cr_comisiones_data.sql" << 'EOF'
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
EOF

# transacciones_data
cat > "$INSTALL_DIR/140_datos_basicos/${VERSION_TAG}_06_cr_transacciones_data.sql" << 'EOF'
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
EOF

echo ""
echo "✅ Archivos SQL individuales generados correctamente."
echo "📂 Ubicación: $INSTALL_DIR"
echo ""
echo "🔧 Ahora ejecuta los scripts de construcción:"
echo "   sh /prog/datos/investment-tracker/database/CreateInstallSqlInvestmentTracker.sh"
echo "   sh /prog/datos/investment-tracker/database/CreateRelease00_001_000SqlInvestmentTracker.sh"