#!/bin/bash
# =============================================================================
# Script: CreateRelease00_001_000SqlInvestmentTracker.sh
# Descripción: Genera aplica_00_001_000.sql con referencias a los archivos
#              de install (para esta versión, no hay updates previos).
# Uso:   sh CreateRelease00_001_000SqlInvestmentTracker.sh
# =============================================================================

set -e

PROJECT_ROOT="/prog/datos/investment-tracker"
SQL_DIR="$PROJECT_ROOT/database/sql"
INSTALL_DIR="$SQL_DIR/install"
OUTPUT_FILE="$PROJECT_ROOT/database/sql/aplica_00_001_000.sql"
VERSION_TAG="00_001_000"

echo "🔧 Generando script de migración para versión $VERSION_TAG (aplica_${VERSION_TAG}.sql)..."

cat > "$OUTPUT_FILE" << 'EOF'
-- =============================================
-- MIGRACIÓN - VERSIÓN 00_001_000
-- Investment Tracker
-- Fecha generación: $(date '+%Y-%m-%d %H:%M:%S')
-- Descripción: Script de migración con referencias a archivos individuales
-- =============================================

\echo '🚀 Aplicando migración a versión 00_001_000...'
\set ON_ERROR_STOP on

EOF

# Como es la primera versión, referenciamos los archivos de install
for dir in $(ls -d "$INSTALL_DIR"/*/ 2>/dev/null | sort -V); do
    dir_name=$(basename "$dir")
    echo "-- =============================================" >> "$OUTPUT_FILE"
    echo "-- DIRECTORIO: $dir_name" >> "$OUTPUT_FILE"
    echo "-- =============================================" >> "$OUTPUT_FILE"
    
    for file in $(ls "$dir"/*.sql 2>/dev/null | sort -V); do
        if [ -f "$file" ]; then
            rel_path="${file#$SQL_DIR/}"
            echo "\ir $rel_path" >> "$OUTPUT_FILE"
        fi
    done
done

echo "\echo '✅ Migración a versión 00_001_000 completada'" >> "$OUTPUT_FILE"

echo ""
echo "✅ Script de migración generado: $OUTPUT_FILE"