#!/bin/bash
# =============================================
# CHECK-ALL.SH - Verificación completa del sistema
# Uso: ./check-all.sh
# Retorna: 0 si todo OK, 1 si hay fallos
# =============================================

# Cambiar al directorio docker/ (padre del script)
cd "$(dirname "$0")/.." || { echo "❌ No se pudo cambiar al directorio docker/"; exit 1; }

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Contadores globales
PASS=0
FAIL=0
FAILED_CHECKS=()

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────${NC}"
}

pass() {
    echo -e "  ${GREEN}✅${NC} $1"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "  ${RED}❌${NC} $1"
    if [ -n "${2:-}" ]; then
        echo -e "     ${YELLOW}↳${NC} $2"
    fi
    FAIL=$((FAIL + 1))
    FAILED_CHECKS+=("$1")
}

# check_sql: ejecuta SQL y compara el resultado
# Uso: check_sql "Descripción" "SELECT ..." "esperado"
check_sql() {
    local name="$1"
    local sql="$2"
    local expected="${3:-}"
    local output

    if ! output=$(docker compose exec -T postgres psql -U investor -d investment_tracker -t -A -v ON_ERROR_STOP=1 -c "$sql" 2>&1); then
        fail "$name" "SQL falló: $(echo "$output" | head -1)"
        return 1
    fi

    output=$(echo "$output" | tr -d '[:space:]')

    if [ -n "$expected" ] && [ "$output" != "$expected" ]; then
        fail "$name" "esperado='$expected' obtenido='$output'"
        return 1
    fi

    pass "$name"
    return 0
}

# ------------------------------------------------------------
# Banner
# ------------------------------------------------------------
echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║   🔍 INVESTMENT TRACKER - VERIFICACIÓN COMPLETA      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ------------------------------------------------------------
# 1. SERVICIOS DOCKER
# ------------------------------------------------------------
print_header "📦 1. ESTADO DE SERVICIOS"

if ! docker compose ps >/dev/null 2>&1; then
    fail "Docker Compose disponible" "No se puede ejecutar 'docker compose ps'"
    echo ""
    echo -e "${RED}⛔ Docker no está corriendo o no estás en el directorio correcto. Abortando.${NC}"
    exit 1
fi
pass "Docker Compose responde"

docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# ------------------------------------------------------------
# 2. SALUD DE POSTGRESQL
# ------------------------------------------------------------
print_header "🏥 2. SALUD DE POSTGRESQL"

if docker compose exec -T postgres pg_isready -U investor -d investment_tracker >/dev/null 2>&1; then
    pass "PostgreSQL responde en investment_tracker"
else
    fail "PostgreSQL responde en investment_tracker" "pg_isready falló"
    echo ""
    echo -e "${RED}⛔ PostgreSQL no está disponible. Abortando verificaciones SQL.${NC}"
    exit 1
fi

# ------------------------------------------------------------
# 3. CONTEO DE REGISTROS
# ------------------------------------------------------------
print_header "📊 3. CONTEO DE REGISTROS POR TABLA"

docker compose exec -T postgres psql -U investor -d investment_tracker <<'SQL'
SELECT tabla, registros FROM (
    SELECT 'Roles' AS tabla, COUNT(*) AS registros FROM investment_tracker.roles
    UNION ALL SELECT 'Usuarios', COUNT(*) FROM investment_tracker.usuarios
    UNION ALL SELECT 'Usuario_Roles', COUNT(*) FROM investment_tracker.usuario_roles
    UNION ALL SELECT 'Monedas', COUNT(*) FROM investment_tracker.monedas
    UNION ALL SELECT 'Paises', COUNT(*) FROM investment_tracker.paises
    UNION ALL SELECT 'Plataformas', COUNT(*) FROM investment_tracker.plataformas
    UNION ALL SELECT 'Comisiones', COUNT(*) FROM investment_tracker.comisiones
    UNION ALL SELECT 'Transacciones', COUNT(*) FROM investment_tracker.transacciones
    UNION ALL SELECT 'Calculos_Hist', COUNT(*) FROM investment_tracker.calculos_hist
    UNION ALL SELECT 'Auditoria_Usuarios', COUNT(*) FROM investment_tracker.auditoria_usuarios
    UNION ALL SELECT 'Schema_Version', COUNT(*) FROM investment_tracker.schema_version
) AS conteos
ORDER BY tabla;
SQL

# ------------------------------------------------------------
# 4. USUARIOS
# ------------------------------------------------------------
print_header "👤 4. USUARIOS REGISTRADOS"

docker compose exec -T postgres psql -U investor -d investment_tracker <<'SQL'
SELECT u.username, u.email, u.nombre_completo, u.celular, p.nombre AS pais, u.activo, u.created_at::date AS creado
FROM investment_tracker.usuarios u
LEFT JOIN investment_tracker.paises p ON u.pais_id = p.id
ORDER BY u.username;
SQL

# ------------------------------------------------------------
# 5. FUNCIONES PL/pgSQL
# ------------------------------------------------------------
print_header "⚡ 5. PRUEBA DE FUNCIONES PL/pgSQL"

check_sql "Función obtener_comision_actual existe" \
    "SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='investment_tracker' AND p.proname='obtener_comision_actual';" \
    "1"

check_sql "Función calcular_comision existe" \
    "SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='investment_tracker' AND p.proname='calcular_comision';" \
    "1"

check_sql "Función resumen_inversiones existe" \
    "SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='investment_tracker' AND p.proname='resumen_inversiones';" \
    "1"

check_sql "Función calcular_venta_optima existe" \
    "SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='investment_tracker' AND p.proname='calcular_venta_optima';" \
    "1"

echo ""
echo "  🧮 Cálculo de ejemplo (AAPL, ganancia \$500):"
docker compose exec -T postgres psql -U investor -d investment_tracker <<'SQL'
SELECT * FROM investment_tracker.calcular_venta_optima(
    'd4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f8a'::UUID,
    'AAPL', 500.00,
    'f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f8a9b0c'::UUID
);
SQL

# ------------------------------------------------------------
# 6. VERSIONES INSTALADAS
# ------------------------------------------------------------
print_header "📌 6. VERSIONES INSTALADAS"

docker compose exec -T postgres psql -U investor -d investment_tracker <<'SQL'
SELECT version, descripcion, script_name, ejecutado_en::date AS fecha
FROM investment_tracker.schema_version
ORDER BY ejecutado_en, script_name;
SQL

# ------------------------------------------------------------
# 7. AUDITORÍA DE USUARIOS
# ------------------------------------------------------------
print_header "📜 7. AUDITORÍA DE USUARIOS"

check_sql "Tabla auditoria_usuarios existe" \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='investment_tracker' AND table_name='auditoria_usuarios';" \
    "1"

check_sql "Trigger trg_audit_usuarios instalado en usuarios" \
    "SELECT COUNT(*) FROM pg_trigger WHERE tgname='trg_audit_usuarios' AND tgrelid='investment_tracker.usuarios'::regclass AND NOT tgisinternal;" \
    "1"

check_sql "Función fn_audit_usuarios existe" \
    "SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='investment_tracker' AND p.proname='fn_audit_usuarios';" \
    "1"

check_sql "Función fn_audit_usuarios es SECURITY DEFINER" \
    "SELECT prosecdef FROM pg_proc p JOIN pg_namespace n ON p.pronamespace=n.oid WHERE n.nspname='investment_tracker' AND p.proname='fn_audit_usuarios';" \
    "t"

check_sql "Índice idx_auditoria_usuarios_usuario_id existe" \
    "SELECT COUNT(*) FROM pg_indexes WHERE schemaname='investment_tracker' AND indexname='idx_auditoria_usuarios_usuario_id';" \
    "1"

check_sql "Índice idx_auditoria_usuarios_fecha existe" \
    "SELECT COUNT(*) FROM pg_indexes WHERE schemaname='investment_tracker' AND indexname='idx_auditoria_usuarios_fecha';" \
    "1"

check_sql "Índice idx_auditoria_usuarios_operacion existe" \
    "SELECT COUNT(*) FROM pg_indexes WHERE schemaname='investment_tracker' AND indexname='idx_auditoria_usuarios_operacion';" \
    "1"

echo ""
echo "  🧪 Prueba funcional del trigger (dentro de transacción con ROLLBACK):"
AUDIT_TEST_RESULT=$(docker compose exec -T postgres psql -U investor -d investment_tracker -t -A -q 2>&1 <<'SQL'
BEGIN;
INSERT INTO investment_tracker.usuarios (id, username, password_hash, email, nombre_completo, activo)
VALUES ('00000000-dead-beef-0000-000000000999', 'checkall_test', 'hash', 'checkall@test.local', 'Check Test', true);
UPDATE investment_tracker.usuarios SET nombre_completo='Check Test 2' WHERE username='checkall_test';
DELETE FROM investment_tracker.usuarios WHERE username='checkall_test';
SELECT COUNT(*) FROM investment_tracker.auditoria_usuarios WHERE usuario_id='00000000-dead-beef-0000-000000000999';
ROLLBACK;
SQL
)
AUDIT_TEST_RESULT=$(echo "$AUDIT_TEST_RESULT" | tr -d '[:space:]')
if [ "$AUDIT_TEST_RESULT" = "3" ]; then
    pass "Trigger registra INSERT + UPDATE + DELETE (3 registros)"
else
    fail "Trigger registra INSERT + UPDATE + DELETE" "esperado=3 obtenido='$AUDIT_TEST_RESULT'"
fi

# ------------------------------------------------------------
# 8. USUARIO DE BD DE LA APLICACIÓN (investment_app)
# ------------------------------------------------------------
print_header "🔐 8. USUARIO DE BD DE LA APLICACIÓN (investment_app)"

check_sql "Rol investment_app existe" \
    "SELECT COUNT(*) FROM pg_roles WHERE rolname='investment_app';" \
    "1"

check_sql "investment_app puede hacer LOGIN" \
    "SELECT rolcanlogin FROM pg_roles WHERE rolname='investment_app';" \
    "t"

# --- Permisos DENEGADOS sobre auditoría ---
check_sql "DENEGADO: SELECT sobre auditoria_usuarios" \
    "SELECT has_table_privilege('investment_app','investment_tracker.auditoria_usuarios','SELECT');" \
    "f"

check_sql "DENEGADO: INSERT sobre auditoria_usuarios" \
    "SELECT has_table_privilege('investment_app','investment_tracker.auditoria_usuarios','INSERT');" \
    "f"

check_sql "DENEGADO: UPDATE sobre auditoria_usuarios" \
    "SELECT has_table_privilege('investment_app','investment_tracker.auditoria_usuarios','UPDATE');" \
    "f"

check_sql "DENEGADO: DELETE sobre auditoria_usuarios" \
    "SELECT has_table_privilege('investment_app','investment_tracker.auditoria_usuarios','DELETE');" \
    "f"

check_sql "DENEGADO: USAGE sobre secuencia auditoria_usuarios_id_seq" \
    "SELECT has_sequence_privilege('investment_app','investment_tracker.auditoria_usuarios_id_seq','USAGE');" \
    "f"

# --- Permisos PERMITIDOS sobre usuarios ---
check_sql "PERMITIDO: SELECT sobre usuarios" \
    "SELECT has_table_privilege('investment_app','investment_tracker.usuarios','SELECT');" \
    "t"

check_sql "PERMITIDO: INSERT sobre usuarios" \
    "SELECT has_table_privilege('investment_app','investment_tracker.usuarios','INSERT');" \
    "t"

check_sql "PERMITIDO: UPDATE sobre usuarios" \
    "SELECT has_table_privilege('investment_app','investment_tracker.usuarios','UPDATE');" \
    "t"

check_sql "PERMITIDO: DELETE sobre usuarios" \
    "SELECT has_table_privilege('investment_app','investment_tracker.usuarios','DELETE');" \
    "t"

# --- Permisos PERMITIDOS sobre tablas de negocio ---
for tbl in roles usuario_roles monedas paises plataformas comisiones transacciones calculos_hist; do
    check_sql "PERMITIDO: SELECT sobre $tbl" \
        "SELECT has_table_privilege('investment_app','investment_tracker.$tbl','SELECT');" \
        "t"
done

# --- Resumen de privilegios de investment_app ---
echo ""
echo "  📋 Resumen de privilegios por tabla:"
docker compose exec -T postgres psql -U investor -d investment_tracker <<'SQL'
SELECT
    t.table_name,
    CASE WHEN has_table_privilege('investment_app', 'investment_tracker.'||t.table_name, 'SELECT') THEN 'S' ELSE '-' END AS sel,
    CASE WHEN has_table_privilege('investment_app', 'investment_tracker.'||t.table_name, 'INSERT') THEN 'I' ELSE '-' END AS ins,
    CASE WHEN has_table_privilege('investment_app', 'investment_tracker.'||t.table_name, 'UPDATE') THEN 'U' ELSE '-' END AS upd,
    CASE WHEN has_table_privilege('investment_app', 'investment_tracker.'||t.table_name, 'DELETE') THEN 'D' ELSE '-' END AS del
FROM information_schema.tables t
WHERE t.table_schema = 'investment_tracker'
ORDER BY t.table_name;
SQL

# ------------------------------------------------------------
# 9. LOGIN REAL CON investment_app (opcional)
# ------------------------------------------------------------
print_header "🔑 9. LOGIN REAL CON investment_app"

if [ -n "${INVESTMENT_APP_DB_PASSWORD:-}" ]; then
    if docker compose exec -T -e PGPASSWORD="$INVESTMENT_APP_DB_PASSWORD" postgres \
        psql -U investment_app -d investment_tracker -c "SELECT 1;" >/dev/null 2>&1; then
        pass "Login real con investment_app exitoso"
    else
        fail "Login real con investment_app" "verifica INVESTMENT_APP_DB_PASSWORD"
    fi
else
    echo -e "  ${YELLOW}⚠️${NC}  INVESTMENT_APP_DB_PASSWORD no definida, se omite la prueba de login real"
    echo -e "     ${YELLOW}↳${NC} Ejecuta: export INVESTMENT_APP_DB_PASSWORD='tu_password'"
fi

# ------------------------------------------------------------
# RESUMEN FINAL
# ------------------------------------------------------------
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗"
echo -e "║                  📊 RESUMEN FINAL                    ║"
echo -e "╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}✅ PASS:${NC} $PASS"
echo -e "  ${RED}❌ FAIL:${NC} $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}${BOLD}  ⛔ Verificaciones fallidas:${NC}"
    for c in "${FAILED_CHECKS[@]}"; do
        echo -e "     ${RED}•${NC} $c"
    done
    echo ""
    echo -e "${RED}${BOLD}❌ VERIFICACIÓN COMPLETADA CON ERRORES${NC}"
    exit 1
else
    echo -e "${GREEN}${BOLD}✅ VERIFICACIÓN COMPLETADA - TODO OK${NC}"
    exit 0
fi
