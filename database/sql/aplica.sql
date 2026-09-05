-- =============================================
-- INSTALACIÓN COMPLETA - Investment Tracker
-- Versión: 00_001_000
-- Fecha generación: $(date '+%Y-%m-%d %H:%M:%S')
-- Descripción: Script con referencias a archivos individuales
-- =============================================

\echo '🚀 Iniciando instalación completa de Investment Tracker...'
\set ON_ERROR_STOP on

-- =============================================
-- DIRECTORIO: 10_esquemas
-- =============================================
\ir install/10_esquemas//00_001_000_01_cr_schema.sql
-- =============================================
-- DIRECTORIO: 20_extensiones
-- =============================================
\ir install/20_extensiones//00_001_000_01_cr_extensiones.sql
-- =============================================
-- DIRECTORIO: 30_tipos
-- =============================================
-- =============================================
-- DIRECTORIO: 40_tablas
-- =============================================
\ir install/40_tablas//00_001_000_01_cr_roles.sql
\ir install/40_tablas//00_001_000_02_cr_usuarios.sql
\ir install/40_tablas//00_001_000_03_cr_usuario_roles.sql
\ir install/40_tablas//00_001_000_04_cr_monedas.sql
\ir install/40_tablas//00_001_000_05_cr_plataformas.sql
\ir install/40_tablas//00_001_000_06_cr_comisiones.sql
\ir install/40_tablas//00_001_000_07_cr_transacciones.sql
\ir install/40_tablas//00_001_000_08_cr_calculos_hist.sql
-- =============================================
-- DIRECTORIO: 50_alter_tablas
-- =============================================
-- =============================================
-- DIRECTORIO: 60_restricciones
-- =============================================
-- =============================================
-- DIRECTORIO: 70_indices
-- =============================================
\ir install/70_indices//00_001_000_01_cr_indices.sql
-- =============================================
-- DIRECTORIO: 80_vistas
-- =============================================
-- =============================================
-- DIRECTORIO: 90_funciones
-- =============================================
\ir install/90_funciones//00_001_000_01_cr_obtener_comision_actual.sql
\ir install/90_funciones//00_001_000_02_cr_calcular_comision.sql
\ir install/90_funciones//00_001_000_03_cr_resumen_inversiones.sql
\ir install/90_funciones//00_001_000_04_cr_calcular_venta_optima.sql
-- =============================================
-- DIRECTORIO: 100_procedimientos
-- =============================================
-- =============================================
-- DIRECTORIO: 110_disparadores
-- =============================================
-- =============================================
-- DIRECTORIO: 120_eventos
-- =============================================
-- =============================================
-- DIRECTORIO: 130_secuencias
-- =============================================
-- =============================================
-- DIRECTORIO: 140_datos_basicos
-- =============================================
\ir install/140_datos_basicos//00_001_000_01_cr_roles_data.sql
\ir install/140_datos_basicos//00_001_000_02_cr_usuarios_data.sql
\ir install/140_datos_basicos//00_001_000_03_cr_monedas_data.sql
\ir install/140_datos_basicos//00_001_000_04_cr_plataformas_data.sql
\ir install/140_datos_basicos//00_001_000_05_cr_comisiones_data.sql
\ir install/140_datos_basicos//00_001_000_06_cr_transacciones_data.sql
-- =============================================
-- DIRECTORIO: 150_permisos
-- =============================================
-- =============================================
-- DIRECTORIO: 160_comentarios
-- =============================================
\echo '✅ Instalación completa finalizada (00_001_000)'
