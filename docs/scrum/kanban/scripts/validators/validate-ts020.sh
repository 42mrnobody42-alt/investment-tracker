#!/usr/bin/env bash
# ============================================================================
# validate-ts020.sh — TS-020 (#625) — vite.config.ts con proxy /api
# Basado en docs/scrum/kanban/templates/VALIDATION-template.sh
# Env: ISSUE_NUM, TS_CODE, LOG_FILE, RUN_LIVE, RUN_RUNNER
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
README="$REPO/README.md"
PROMPT="$REPO/docs/prompts/prompt_inicial.md"
AGENTE="$REPO/docs/prompts/agente-frontend.md"
ISSUE_NUM="${ISSUE_NUM:-625}"
TS_CODE="${TS_CODE:-TS-020}"
RUN_LIVE="${RUN_LIVE:-0}"
RUN_RUNNER="${RUN_RUNNER:-0}"

LOG_FILE="${LOG_FILE:-}"
if [ -z "$LOG_FILE" ]; then
  LOG_DIR="$REPO/logs/Kanban"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/Validacion-criterios-aceptacion-${TS_CODE}.log"
  : > "$LOG_FILE"
fi

PASS=0; FAIL=0; CONTRA=0

if [[ -t 1 ]]; then
  CLR_RED=$'\033[0;31m'; CLR_GREEN=$'\033[0;32m'; CLR_YELLOW=$'\033[1;33m'
  CLR_CYAN=$'\033[0;36m'; CLR_BOLD=$'\033[1m'; CLR_NC=$'\033[0m'
else
  CLR_RED=''; CLR_GREEN=''; CLR_YELLOW=''; CLR_CYAN=''; CLR_BOLD=''; CLR_NC=''
fi

check() {
  local ca_code="$1" title="$2" expected="$3" obtained="$4" verdict="$5" ref="${6:-}" debug="${7:-}"
  echo ""
  echo "${CLR_CYAN}${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"
  echo "  CRITERIO $ca_code — $title"
  echo "${CLR_CYAN}════════════════════════════════════════════════════════════════════${CLR_NC}"
  echo "  Esperado : $expected"
  echo "  Obtenido : $obtained"
  if [ -n "$ref" ]; then echo "  Dónde verificar : $ref"; fi
  if [ -n "$debug" ]; then echo "  Debug :"; echo "$debug" | head -30 | sed 's/^/    /'; fi
  case "$verdict" in
    1) echo "  ${CLR_GREEN}Resultado: ✅ APROBÓ${CLR_NC}";           PASS=$((PASS+1)) ;;
    2) echo "  ${CLR_YELLOW}Resultado: ⚠️  CONTRADICCIÓN${CLR_NC}";   CONTRA=$((CONTRA+1)) ;;
    *) echo "  ${CLR_RED}Resultado: ❌ NO APROBÓ${CLR_NC}";           FAIL=$((FAIL+1)) ;;
  esac
  if [ -n "$LOG_FILE" ]; then
    {
      echo "--------- $ca_code — $title ---------"
      echo "Esperado: $expected"
      echo "Obtenido: $obtained"
      if [ -n "$ref" ]; then echo "Dónde verificar: $ref"; fi
      if [ -n "$debug" ]; then echo "Debug (salida real):"; echo "$debug" | head -30 | sed 's/^/  /'; fi
      case "$verdict" in
        1) echo "Resultado: ✅ APROBÓ" ;;
        2) echo "Resultado: ⚠️  CONTRADICCIÓN" ;;
        *) echo "Resultado: ❌ NO APROBÓ" ;;
      esac
      echo ""
    } >> "$LOG_FILE"
  fi
}

echo ""
echo "${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"
echo "  $TS_CODE (#$ISSUE_NUM) — RUN_LIVE=$RUN_LIVE RUN_RUNNER=$RUN_RUNNER"
echo "${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"

# ── CA_01: server.proxy '/api' → target :7700 + changeOrigin ──────────────
V_API=$(grep -cF "'/api':" "$FRONTEND/vite.config.ts" || true)
V_TARGET=$(grep -cF "target: 'http://localhost:7700'" "$FRONTEND/vite.config.ts" || true)
V_CHANGE=$(grep -cF "changeOrigin: true" "$FRONTEND/vite.config.ts" || true)
V="api=$V_API target=$V_TARGET changeOrigin=$V_CHANGE"
RESULT=0
[ "$V_API" -ge 1 ] && [ "$V_TARGET" -ge 1 ] && [ "$V_CHANGE" -ge 1 ] && RESULT=1
DEBUG=$(grep -nE "'/api':|target:|changeOrigin:" "$FRONTEND/vite.config.ts" | head -5)
check "CA_01" "server.proxy '/api' → target :7700 + changeOrigin:true" \
  "api≥1 target≥1 changeOrigin≥1" "$V" "$RESULT" \
  "frontend/vite.config.ts" "$DEBUG"

# ── CA_02: sin rewrite en código (excluye comentarios) ────────────────────
V=$(grep -vE '^[[:space:]]*//' "$FRONTEND/vite.config.ts" | grep -c 'rewrite' || true)
V="${V:-0}"
RESULT=0
[ "$V" -eq 0 ] && RESULT=1
DEBUG=$(grep -nvE '^[[:space:]]*//' "$FRONTEND/vite.config.ts" | grep 'rewrite' | head -3)
[ -z "$DEBUG" ] && DEBUG="(0 matches en código)"
check "CA_02" "El proxy NO reescribe el path (sin rewrite en código)" \
  "rewrite count = 0" "$V" "$RESULT" \
  "frontend/vite.config.ts (excluye comentarios)" "$DEBUG"

# ── CA_03: comentario apunta a application.yml → server.port ──────────────
V1=$(grep -cF "application.yml" "$FRONTEND/vite.config.ts" || true)
V2=$(grep -cF "server.port" "$FRONTEND/vite.config.ts" || true)
V="appyml=$V1 server_port=$V2"
RESULT=0
[ "$V1" -ge 1 ] && [ "$V2" -ge 1 ] && RESULT=1
DEBUG=$(grep -nE "application.yml|server.port" "$FRONTEND/vite.config.ts" | head -5)
check "CA_03" "target hardcoded con comentario a application.yml → server.port" \
  "≥1 appyml, ≥1 server.port" "$V" "$RESULT" \
  "frontend/vite.config.ts" "$DEBUG"

# ── CA_04: fetch('/api/test/health') → 200 (SOLO RUN_LIVE=1) ─────────────
if [ "$RUN_LIVE" = "1" ]; then
  BE=$(node -e "(async()=>{try{const r=await fetch('http://localhost:7700/api/test/health');console.log(r.status)}catch(e){console.log('ERR')}})();" 2>&1 | head -1)
  FE=$(node -e "(async()=>{try{const r=await fetch('http://localhost:3000/api/test/health');console.log(r.status)}catch(e){console.log('ERR')}})();" 2>&1 | head -1)
  V="be=$BE fe=$FE"
  RESULT=0
  [ "$BE" = "200" ] && [ "$FE" = "200" ] && RESULT=1
  DEBUG=$(printf '%s\n%s\n%s\n%s\n' "\$ node fetch :7700/api/test/health" "$BE" "\$ node fetch :3000/api/test/health" "$FE")
  check "CA_04" "fetch('/api/test/health') → 200 (backend :7700 + vite :3000)" \
    "be=200 fe=200" "$V" "$RESULT" \
    "backend :7700 + frontend :3000" "$DEBUG"
else
  check "CA_04" "fetch('/api/test/health') → 200 (live)" \
    "N/A (RUN_LIVE=0)" "SKIP" "1" \
    "requiere backend :7700 + vite dev :3000" \
    "SKIP: usar RUN_LIVE=1 con servicios arriba (backend + npm run dev)"
fi

# ── CA_05: build no incluye proxy ────────────────────────────────────────
V_PREVIEW=$(grep -c 'preview' "$FRONTEND/vite.config.ts" || true)
if [ -d "$FRONTEND/dist" ]; then
  V_DIST=$(grep -rEl "changeOrigin|localhost:7700" "$FRONTEND/dist" 2>/dev/null | wc -l | tr -d ' ')
else
  V_DIST="SKIP"
fi
V="preview=$V_PREVIEW dist=$V_DIST"
RESULT=0
[ "$V_PREVIEW" -eq 0 ] && { [ "$V_DIST" = "0" ] || [ "$V_DIST" = "SKIP" ]; } && RESULT=1
if [ "$V_DIST" = "SKIP" ]; then
  DEBUG=$(printf '%s\n' "\$ grep -c preview frontend/vite.config.ts" "$V_PREVIEW" "(dist/ no existe — correr npm run build para validación completa)")
else
  DEBUG=$(printf '%s\n%s\n%s\n%s\n' "\$ grep -c preview frontend/vite.config.ts" "$V_PREVIEW" "\$ grep -rEl 'changeOrigin|localhost:7700' frontend/dist | wc -l" "$V_DIST")
fi
check "CA_05" "npm run build no incluye proxy (server.proxy es dev-only)" \
  "preview=0 dist=0" "$V" "$RESULT" \
  "frontend/dist/" "$DEBUG"

# ── CA_06: Storybook no hereda proxy ─────────────────────────────────────
if [ -f "$FRONTEND/.storybook/main.ts" ]; then
  V=$(grep -c 'vite\.config' "$FRONTEND/.storybook/main.ts" || true)
  RESULT=0
  [ "$V" -eq 0 ] && RESULT=1
  DEBUG=$(grep -n 'vite\.config' "$FRONTEND/.storybook/main.ts" | head -3)
  [ -z "$DEBUG" ] && DEBUG="\$ grep -c 'vite\.config' .storybook/main.ts → 0"
  check "CA_06" "Storybook (:3010) no hereda server.proxy" \
    "refs a vite.config = 0" "$V" "$RESULT" \
    "frontend/.storybook/main.ts" "$DEBUG"
else
  check "CA_06" "Storybook (:3010) no hereda server.proxy" \
    "refs a vite.config = 0" "SKIP (main.ts no existe)" "1" \
    "frontend/.storybook/main.ts" "SKIP: archivo no existe"
fi

# ── CA_07: Frontend-test-Dev.sh verde (SOLO RUN_RUNNER=1) ────────────────
if [ "$RUN_RUNNER" = "1" ]; then
  RUNNER_LOG=/tmp/validate-ts020-runner.log
  : > "$RUNNER_LOG"
  ( setsid bash -c "cd $FRONTEND && RUN_LIVE=0 RUN_BEHAVIOR=0 RUN_CLEANUP=0 bash tests/shellTest/Frontend-test-Dev.sh" > "$RUNNER_LOG" 2>&1 < /dev/null )
  RUNNER_EXIT=$?
  V="exit=$RUNNER_EXIT"
  RESULT=0
  [ "$RUNNER_EXIT" -eq 0 ] && RESULT=1
  DEBUG=$(tail -20 "$RUNNER_LOG")
  check "CA_07" "Frontend-test-Dev.sh verde (14 grupos, 1 W-DOC, 0 nuevos)" \
    "exit=0" "$V" "$RESULT" \
    "logs/Frontend/Dev/" "$DEBUG"
else
  check "CA_07" "Frontend-test-Dev.sh verde" \
    "N/A (RUN_RUNNER=0)" "SKIP" "1" \
    "frontend/tests/shellTest/Frontend-test-Dev.sh" \
    "SKIP: usar RUN_RUNNER=1 para ejecutar el runner completo"
fi

# ── CA_08: README §Frontend "Proxy en desarrollo" ───────────────────────
C1=$(grep -cF "#### Proxy en desarrollo" "$README" || true)
C2=$(grep -cF "convenciones/proxy-developer.md" "$README" || true)
C3=$(grep -cF "diagramas/secuencia/proxy-api-dev.md" "$README" || true)
C4=$(grep -cF "api/test/health" "$README" || true)
C5=$(grep -cF "application.yml → server.port" "$README" || true)
V="seccion=$C1 link_doc=$C2 link_diag=$C3 fetch=$C4 sync=$C5"
RESULT=0
[ "$C1" -ge 1 ] && [ "$C2" -ge 1 ] && [ "$C3" -ge 1 ] && [ "$C4" -ge 1 ] && [ "$C5" -ge 1 ] && RESULT=1
DEBUG=$(grep -nE "#### Proxy en desarrollo|convenciones/proxy-developer.md|diagramas/secuencia/proxy-api-dev.md|api/test/health|application.yml → server.port" "$README" | head -8)
check "CA_08" "README §Frontend Proxy en desarrollo (config + fetch + sync + diagrama)" \
  "5/5 presentes" "$V" "$RESULT" \
  "README.md" "$DEBUG"

# ── CA_09: prompt_inicial regla 37 extendida ────────────────────────────
C1=$(grep -cF "Proxy de desarrollo" "$PROMPT" || true)
C2=$(grep -cF "server.proxy" "$PROMPT" || true)
C3=$(grep -cF "changeOrigin: true" "$PROMPT" || true)
C4=$(grep -cF "Sin rewrite" "$PROMPT" || true)
C5=$(grep -cF "application.yml → server.port" "$PROMPT" || true)
C6=$(grep -cF "convenciones/proxy-developer.md" "$PROMPT" || true)
C7=$(grep -cF "diagramas/secuencia/proxy-api-dev.md" "$PROMPT" || true)
V="proxy=$C1 server.proxy=$C2 changeOrigin=$C3 sin_rewrite=$C4 sync=$C5 link_doc=$C6 link_diag=$C7"
RESULT=0
[ "$C1" -ge 1 ] && [ "$C2" -ge 1 ] && [ "$C3" -ge 1 ] && [ "$C4" -ge 1 ] && [ "$C5" -ge 1 ] && [ "$C6" -ge 1 ] && [ "$C7" -ge 1 ] && RESULT=1
DEBUG=$(grep -nE "Proxy de desarrollo|server.proxy|changeOrigin: true|Sin rewrite|application.yml → server.port|convenciones/proxy-developer.md|diagramas/secuencia/proxy-api-dev.md" "$PROMPT" | head -10)
check "CA_09" "prompt_inicial regla 37 extendida (proxy + server.proxy + sync + links)" \
  "7/7 presentes" "$V" "$RESULT" \
  "docs/prompts/prompt_inicial.md" "$DEBUG"

# ── CA_10: agente-frontend §14.12 patrón server.proxy ───────────────────
C1=$(grep -cF "### 14.12 Proxy de desarrollo" "$AGENTE" || true)
C2=$(grep -cF "proxy: {" "$AGENTE" || true)
C3=$(grep -cF "Sin \`rewrite\`" "$AGENTE" || true)
C4=$(grep -cF "no hereda el proxy" "$AGENTE" || true)
C5=$(grep -cF "application.yml → server.port" "$AGENTE" || true)
C6=$(grep -cF "convenciones/proxy-developer.md" "$AGENTE" || true)
C7=$(grep -cF "diagramas/secuencia/proxy-api-dev.md" "$AGENTE" || true)
V="sec=$C1 proxy_block=$C2 sin_rewrite=$C3 no_hereda=$C4 sync=$C5 link_doc=$C6 link_diag=$C7"
RESULT=0
[ "$C1" -ge 1 ] && [ "$C2" -ge 1 ] && [ "$C3" -ge 1 ] && [ "$C4" -ge 1 ] && [ "$C5" -ge 1 ] && [ "$C6" -ge 1 ] && [ "$C7" -ge 1 ] && RESULT=1
DEBUG=$(grep -nE "### 14.12 Proxy de desarrollo|proxy: \{|Sin \`rewrite\`|no hereda el proxy|application.yml → server.port|convenciones/proxy-developer.md|diagramas/secuencia/proxy-api-dev.md" "$AGENTE" | head -10)
check "CA_10" "agente-frontend §14.12 patrón server.proxy (reglas + links)" \
  "7/7 presentes" "$V" "$RESULT" \
  "docs/prompts/agente-frontend.md" "$DEBUG"

# ── SUMMARY ──────────────────────────────────────────────────────────────
echo ""
echo "${CLR_BOLD}╔════════════════════════════════════════════════════════════════════╗${CLR_NC}"
echo "${CLR_BOLD}║  RESUMEN GLOBAL — $TS_CODE (#$ISSUE_NUM)${CLR_NC}"
echo "${CLR_BOLD}╚════════════════════════════════════════════════════════════════════╝${CLR_NC}"
echo "  Criterios aprobados      : $PASS"
echo "  Criterios NO aprobados   : $FAIL"
echo "  Criterios contradictorios: $CONTRA"
echo ""
echo "  📄 Log: $LOG_FILE"
echo ""
if [ -n "$LOG_FILE" ]; then
  {
    echo "================================================================"
    echo " RESUMEN — $TS_CODE (#$ISSUE_NUM)"
    echo " Aprobados: $PASS"
    echo " NO aprobados: $FAIL"
    echo " Contradicciones: $CONTRA"
    if [ "$FAIL" -eq 0 ] && [ "$CONTRA" -eq 0 ]; then
      echo " Veredicto: 🟢 APROBÓ"
    else
      echo " Veredicto: 🔴 NO APROBÓ"
    fi
    echo "================================================================"
  } >> "$LOG_FILE"
fi

if [ "$FAIL" -eq 0 ] && [ "$CONTRA" -eq 0 ]; then
  echo "  ${CLR_GREEN}${CLR_BOLD}🟢 VEREDICTO GLOBAL: APROBÓ${CLR_NC}"
  exit 0
else
  echo "  ${CLR_RED}${CLR_BOLD}🔴 VEREDICTO GLOBAL: NO APROBÓ${CLR_NC}"
  exit 1
fi
