
### SQL del Esquema (database/sql/01_schema.sql)
```sql
-- Esquema principal
CREATE SCHEMA IF NOT EXISTS investment_tracker;

-- Tabla de Roles
CREATE TABLE investment_tracker.roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Usuarios
CREATE TABLE investment_tracker.usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Tabla de relación Usuario-Rol
CREATE TABLE investment_tracker.usuario_roles (
    usuario_id INTEGER REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    rol_id INTEGER REFERENCES investment_tracker.roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, rol_id)
);

-- Tabla de Plataformas
CREATE TABLE investment_tracker.plataformas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    usuario_id INTEGER REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, nombre)
);

-- Tabla de Comisiones
CREATE TABLE investment_tracker.comisiones (
    id SERIAL PRIMARY KEY,
    plataforma_id INTEGER REFERENCES investment_tracker.plataformas(id) ON DELETE CASCADE,
    porcentaje DECIMAL(5,4), -- Ej: 0.0125 = 1.25%
    valor_fijo DECIMAL(10,2),
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_comision CHECK (porcentaje IS NOT NULL OR valor_fijo IS NOT NULL)
);

-- Tabla de Transacciones
CREATE TABLE investment_tracker.transacciones (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES investment_tracker.usuarios(id) ON DELETE CASCADE,
    plataforma_id INTEGER REFERENCES investment_tracker.plataformas(id),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('COMPRA', 'VENTA')),
    simbolo VARCHAR(20) NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    comision DECIMAL(10,2) DEFAULT 0,
    valor_total DECIMAL(10,2) NOT NULL,
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejor rendimiento
CREATE INDEX idx_transacciones_usuario ON investment_tracker.transacciones(usuario_id);
CREATE INDEX idx_transacciones_fecha ON investment_tracker.transacciones(fecha_transaccion);
CREATE INDEX idx_transacciones_simbolo ON investment_tracker.transacciones(simbolo);