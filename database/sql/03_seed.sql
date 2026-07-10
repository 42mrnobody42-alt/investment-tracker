-- =============================================
-- INVESTMENT TRACKER - DATOS INICIALES (SEED)
-- Fecha: 2024-07-10
-- Descripción: Datos de prueba para desarrollo
-- =============================================

-- =============================================
-- Versión: 1.0.0
-- Descripción: Datos de prueba (SOLO SI NO EXISTEN)
-- =============================================

\echo '🔍 Verificando datos existentes...'

-- =============================================
-- ROLES DEL SISTEMA
-- =============================================
INSERT INTO investment_tracker.roles (nombre, descripcion) 
SELECT 'ROLE_ADMIN', 'Administrador del sistema con acceso total'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_ADMIN');

INSERT INTO investment_tracker.roles (nombre, descripcion) 
SELECT 'ROLE_USER', 'Usuario regular con funcionalidades básicas'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_USER');

INSERT INTO investment_tracker.roles (nombre, descripcion) 
SELECT 'ROLE_PREMIUM', 'Usuario premium con acceso a calculadora avanzada'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.roles WHERE nombre = 'ROLE_PREMIUM');

\echo '✅ Roles verificados'

-- =============================================
-- USUARIO DEMO
-- =============================================
INSERT INTO investment_tracker.usuarios (username, password_hash, email, nombre_completo)
SELECT 'demo_user', 
       '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
       'demo@investment-tracker.com',
       'Usuario Demo'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'demo_user');

-- Asignar rol USER al demo
INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
SELECT u.id, r.id 
FROM investment_tracker.usuarios u 
CROSS JOIN investment_tracker.roles r
WHERE u.username = 'demo_user' 
  AND r.nombre = 'ROLE_USER'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.usuario_roles ur 
      WHERE ur.usuario_id = u.id AND ur.rol_id = r.id
  );

\echo '✅ Usuario demo verificado'

-- =============================================
-- USUARIO ADMIN
-- =============================================
INSERT INTO investment_tracker.usuarios (username, password_hash, email, nombre_completo)
SELECT 'admin',
       '$2a$10$8K1p/a0dL1LXMIgoEDFrwOfMQkf9RlFP0KxDsF3jkHNGOofQQUmSi',
       'admin@investment-tracker.com',
       'Administrador'
WHERE NOT EXISTS (SELECT 1 FROM investment_tracker.usuarios WHERE username = 'admin');

-- Asignar roles al admin
INSERT INTO investment_tracker.usuario_roles (usuario_id, rol_id)
SELECT u.id, r.id 
FROM investment_tracker.usuarios u 
CROSS JOIN investment_tracker.roles r
WHERE u.username = 'admin' 
  AND r.nombre IN ('ROLE_ADMIN', 'ROLE_USER')
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.usuario_roles ur 
      WHERE ur.usuario_id = u.id AND ur.rol_id = r.id
  );

\echo '✅ Usuario admin verificado'

-- =============================================
-- PLATAFORMAS DE EJEMPLO
-- =============================================
INSERT INTO investment_tracker.plataformas (usuario_id, nombre, descripcion, tipo)
SELECT u.id, 'eToro', 'Plataforma de trading social y copy trading', 'broker'
FROM investment_tracker.usuarios u
WHERE u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.plataformas p 
      WHERE p.usuario_id = u.id AND p.nombre = 'eToro'
  );

INSERT INTO investment_tracker.plataformas (usuario_id, nombre, descripcion, tipo)
SELECT u.id, 'Interactive Brokers', 'Broker profesional con acceso a mercados globales', 'broker'
FROM investment_tracker.usuarios u
WHERE u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.plataformas p 
      WHERE p.usuario_id = u.id AND p.nombre = 'Interactive Brokers'
  );

INSERT INTO investment_tracker.plataformas (usuario_id, nombre, descripcion, tipo)
SELECT u.id, 'Robinhood', 'App de trading sin comisiones', 'broker'
FROM investment_tracker.usuarios u
WHERE u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.plataformas p 
      WHERE p.usuario_id = u.id AND p.nombre = 'Robinhood'
  );

INSERT INTO investment_tracker.plataformas (usuario_id, nombre, descripcion, tipo)
SELECT u.id, 'Binance', 'Exchange de criptomonedas', 'exchange'
FROM investment_tracker.usuarios u
WHERE u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.plataformas p 
      WHERE p.usuario_id = u.id AND p.nombre = 'Binance'
  );

\echo '✅ Plataformas verificadas'

-- =============================================
-- COMISIONES DE EJEMPLO
-- =============================================
-- eToro: 0.5%
INSERT INTO investment_tracker.comisiones (plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
SELECT p.id, 0.0050, 0.00, 'Comisión estándar eToro 0.5%', '2024-01-01'::timestamp
FROM investment_tracker.plataformas p
JOIN investment_tracker.usuarios u ON p.usuario_id = u.id
WHERE p.nombre = 'eToro' AND u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.comisiones c 
      WHERE c.plataforma_id = p.id
  );

-- Interactive Brokers: 0.1% + $1.00
INSERT INTO investment_tracker.comisiones (plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
SELECT p.id, 0.0010, 1.00, 'Comisión IBKR Pro', '2024-01-01'::timestamp
FROM investment_tracker.plataformas p
JOIN investment_tracker.usuarios u ON p.usuario_id = u.id
WHERE p.nombre = 'Interactive Brokers' AND u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.comisiones c 
      WHERE c.plataforma_id = p.id
  );

-- Robinhood: Sin comisión
INSERT INTO investment_tracker.comisiones (plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
SELECT p.id, 0.0000, 0.00, 'Sin comisiones', '2024-01-01'::timestamp
FROM investment_tracker.plataformas p
JOIN investment_tracker.usuarios u ON p.usuario_id = u.id
WHERE p.nombre = 'Robinhood' AND u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.comisiones c 
      WHERE c.plataforma_id = p.id
  );

-- Binance: 0.1%
INSERT INTO investment_tracker.comisiones (plataforma_id, porcentaje, valor_fijo, descripcion, fecha_inicio)
SELECT p.id, 0.0010, 0.00, 'Comisión estándar Binance 0.1%', '2024-01-01'::timestamp
FROM investment_tracker.plataformas p
JOIN investment_tracker.usuarios u ON p.usuario_id = u.id
WHERE p.nombre = 'Binance' AND u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.comisiones c 
      WHERE c.plataforma_id = p.id
  );

\echo '✅ Comisiones verificadas'

-- =============================================
-- TRANSACCIONES DE EJEMPLO
-- =============================================
INSERT INTO investment_tracker.transacciones (
    usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
    cantidad, precio_unitario, comision, valor_total, fecha_transaccion
)
SELECT 
    u.id,
    p.id,
    'COMPRA',
    'AAPL',
    'Apple Inc.',
    10,
    175.50,
    8.78,
    1763.78,
    '2024-01-15 10:30:00'::timestamp
FROM investment_tracker.usuarios u
JOIN investment_tracker.plataformas p ON p.usuario_id = u.id AND p.nombre = 'eToro'
WHERE u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.transacciones t 
      WHERE t.usuario_id = u.id AND t.simbolo = 'AAPL' 
        AND t.fecha_transaccion = '2024-01-15 10:30:00'::timestamp
  );

INSERT INTO investment_tracker.transacciones (
    usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
    cantidad, precio_unitario, comision, valor_total, fecha_transaccion
)
SELECT 
    u.id,
    p.id,
    'COMPRA',
    'TSLA',
    'Tesla Inc.',
    5,
    245.30,
    6.13,
    1232.63,
    '2024-02-01 11:00:00'::timestamp
FROM investment_tracker.usuarios u
JOIN investment_tracker.plataformas p ON p.usuario_id = u.id AND p.nombre = 'eToro'
WHERE u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.transacciones t 
      WHERE t.usuario_id = u.id AND t.simbolo = 'TSLA' 
        AND t.fecha_transaccion = '2024-02-01 11:00:00'::timestamp
  );

INSERT INTO investment_tracker.transacciones (
    usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
    cantidad, precio_unitario, comision, valor_total, fecha_transaccion
)
SELECT 
    u.id,
    p.id,
    'COMPRA',
    'GOOGL',
    'Alphabet Inc.',
    3,
    140.50,
    1.42,
    422.92,
    '2024-03-01 09:45:00'::timestamp
FROM investment_tracker.usuarios u
JOIN investment_tracker.plataformas p ON p.usuario_id = u.id AND p.nombre = 'Interactive Brokers'
WHERE u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.transacciones t 
      WHERE t.usuario_id = u.id AND t.simbolo = 'GOOGL' 
        AND t.fecha_transaccion = '2024-03-01 09:45:00'::timestamp
  );

INSERT INTO investment_tracker.transacciones (
    usuario_id, plataforma_id, tipo, simbolo, empresa_nombre,
    cantidad, precio_unitario, comision, valor_total, fecha_transaccion
)
SELECT 
    u.id,
    p.id,
    'COMPRA',
    'MSFT',
    'Microsoft Corp.',
    8,
    380.75,
    15.23,
    3061.23,
    '2024-03-10 15:20:00'::timestamp
FROM investment_tracker.usuarios u
JOIN investment_tracker.plataformas p ON p.usuario_id = u.id AND p.nombre = 'eToro'
WHERE u.username = 'demo_user'
  AND NOT EXISTS (
      SELECT 1 FROM investment_tracker.transacciones t 
      WHERE t.usuario_id = u.id AND t.simbolo = 'MSFT' 
        AND t.fecha_transaccion = '2024-03-10 15:20:00'::timestamp
  );

\echo '✅ Transacciones de ejemplo verificadas'

-- =============================================
-- RESUMEN FINAL
-- =============================================
SELECT '📊 DATOS ACTUALES:' as info;
SELECT 'Roles: ' || COUNT(*) FROM investment_tracker.roles;
SELECT 'Usuarios: ' || COUNT(*) FROM investment_tracker.usuarios;
SELECT 'Plataformas: ' || COUNT(*) FROM investment_tracker.plataformas;
SELECT 'Comisiones: ' || COUNT(*) FROM investment_tracker.comisiones;
SELECT 'Transacciones: ' || COUNT(*) FROM investment_tracker.transacciones;

\echo '✅ Seed completado exitosamente'