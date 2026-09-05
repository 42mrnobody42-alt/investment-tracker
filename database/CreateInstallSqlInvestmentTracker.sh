#!/bin/bash
# =============================================================================
# Script: CreateInstallSqlInvestmentTracker.sh
# Descripción: Genera aplica.sql con referencias a cada archivo SQL individual.
#              Usa \ir para incluir archivos relativos al directorio del script.
# Uso:   sh CreateInstallSqlInvestmentTracker.sh
# =============================================================================

set -e

PROJECT_ROOT="/prog/datos/investment-tracker"
SQL_DIR="$PROJECT_ROOT/database/sql"
INSTALL_DIR="$SQL_DIR/install"
OUTPUT_FILE="$PROJECT_ROOT/database/sql/aplica.sql"

echo "🔧 Generando script de instalación (aplica.sql) con referencias relativas..."

# Crear el archivo de salida
cat > "$OUTPUT_FILE" << 'EOF'
-- =============================================
-- INSTALACIÓN COMPLETA - Investment Tracker
-- Versión: 00_001_000
-- Fecha generación: $(date '+%Y-%m-%d %H:%M:%S')
-- Descripción: Script con referencias a archivos individuales
-- =============================================

\echo '🚀 Iniciando instalación completa de Investment Tracker...'
\set ON_ERROR_STOP on

EOF

# Recorrer los directorios en orden numérico
for dir in $(ls -d "$INSTALL_DIR"/*/ 2>/dev/null | sort -V); do
    dir_name=$(basename "$dir")
    echo "-- =============================================" >> "$OUTPUT_FILE"
    echo "-- DIRECTORIO: $dir_name" >> "$OUTPUT_FILE"
    echo "-- =============================================" >> "$OUTPUT_FILE"
    
    # Recorrer los archivos dentro del directorio en orden
    for file in $(ls "$dir"/*.sql 2>/dev/null | sort -V); do
        if [ -f "$file" ]; then
            # Obtener la ruta relativa desde sql/ (donde se genera aplica.sql)
            rel_path="${file#$SQL_DIR/}"
            echo "\ir $rel_path" >> "$OUTPUT_FILE"
        fi
    done
done

echo "\echo '✅ Instalación completa finalizada (00_001_000)'" >> "$OUTPUT_FILE"

echo ""
echo "✅ Script de instalación generado: $OUTPUT_FILE"
echo "   Contiene referencias \ir a cada archivo individual."