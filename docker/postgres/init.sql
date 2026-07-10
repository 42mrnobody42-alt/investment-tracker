-- =============================================
-- POSTGRESQL - SCRIPT DE INICIALIZACIÓN
-- Se ejecuta automáticamente al iniciar el contenedor
-- =============================================

-- Crear extensión UUID si no existe
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Mensaje de inicio
\echo '🚀 Iniciando configuración de base de datos Investment Tracker...'
\echo '============================================'

-- Los scripts se ejecutan en orden alfabético desde 
-- /docker-entrypoint-initdb.d/
-- por eso los archivos en database/sql/ se montarán en 
-- /docker-entrypoint-initdb.d/sql/
-- y se ejecutarán en orden: 01_, 02_, 03_

\echo '✅ Script de inicialización completado'
