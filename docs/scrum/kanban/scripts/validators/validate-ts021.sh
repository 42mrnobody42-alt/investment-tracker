#!/usr/bin/env bash
# ============================================================================
# validate-ts021.sh — TS-021 (#626) — src/vite-env.d.ts tipado
# Basado en docs/scrum/kanban/templates/VALIDATION-template.sh
# Env: ISSUE_NUM, TS_CODE, LOG_FILE, RUN_BEHAVIOR, RUN_RUNNER
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
DTS="$FRONTEND/src/vite-env.d.ts"
README="$REPO/README.md"
AGENTE="$REPO/docs/prompts/agente-frontend.md"
PROMPT="$REPO/docs/prompts/prompt_inicial.md"
ISSUE_NUM="${ISSUE_NUM:-626}"
TS_CODE="${TS_CODE:-TS-021}"
RUN_BEHAVIOR="${RUN_BEHAVIOR:-0}"
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

# Helper: cuenta ocurrencias (0 si no hay) sin bug "0\n0"
count() {
  local needle="$1" file="$2" n
  if [ ! -f "$file" ]; then
    echo 0
    return 0
  fi
  n=$(grep -cF -- "$needle" "$file" 2>/dev/null | head -1)
  echo "${n:-0}"
}

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
echo "  $TS_CODE (#$ISSUE_NUM) — RUN_BEHAVIOR=$RUN_BEHAVIOR RUN_RUNNER=$RUN_RUNNER"
echo "${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"

# ── CA_01: src/vite-env.d.ts existe con reference a vite/client ──────────
N_REF='/// <reference types="vite/client" />'
V_EXISTE=$([ -f "$DTS" ] && echo yes || echo no)
V_REF=$(count "$N_REF" "$DTS")
V="existe=$V_EXISTE ref=$V_REF"
RESULT=0
[ "$V_EXISTE" = "yes" ] && [ "$V_REF" -ge 1 ] && RESULT=1
DEBUG=$(printf '$ ls -la %s\n%s\n$ grep -nF "%s" %s\n%s\n$ head -15 %s\n%s' \
  "$DTS" "$(ls -la "$DTS" 2>&1)" \
  "$N_REF" "$DTS" "$(grep -nF -- "$N_REF" "$DTS" 2>&1)" \
  "$DTS" "$(head -15 "$DTS" 2>&1)")
check "CA_01" "src/vite-env.d.ts existe con reference a vite/client" \
  "existe=yes ref>=1" "$V" "$RESULT" \
  "frontend/src/vite-env.d.ts" "$DEBUG"

# ── CA_02: ImportMetaEnv con 3 vars (VITE_APP_ENV union estricto) ────────
N_URL='VITE_API_URL: string'
N_ENV="VITE_APP_ENV: 'development' | 'qa' | 'production'"
N_NAME='VITE_APP_NAME: string'
N_ENV_IFACE='interface ImportMetaEnv'
N_META_IFACE='interface ImportMeta'
V_URL=$(count "$N_URL" "$DTS")
V_ENV=$(count "$N_ENV" "$DTS")
V_NAME=$(count "$N_NAME" "$DTS")
V_ENV_IFACE=$(count "$N_ENV_IFACE" "$DTS")
V_META_IFACE=$(count "$N_META_IFACE" "$DTS")
V="url=$V_URL env=$V_ENV name=$V_NAME ifaceEnv=$V_ENV_IFACE ifaceMeta=$V_META_IFACE"
RESULT=0
[ "$V_URL" -ge 1 ] && [ "$V_ENV" -ge 1 ] && [ "$V_NAME" -ge 1 ] \
  && [ "$V_ENV_IFACE" -ge 1 ] && [ "$V_META_IFACE" -ge 1 ] && RESULT=1
DEBUG=$(printf '$ grep -nF "VITE_API_URL: string" %s\n%s\n$ grep -nF "VITE_APP_ENV: union" %s\n%s\n$ grep -nF "VITE_APP_NAME: string" %s\n%s' \
  "$DTS" "$(grep -nF -- "$N_URL" "$DTS" 2>&1)" \
  "$DTS" "$(grep -nF -- "$N_ENV" "$DTS" 2>&1)" \
  "$DTS" "$(grep -nF -- "$N_NAME" "$DTS" 2>&1)")
check "CA_02" "ImportMetaEnv extendida con VITE_API_URL/VITE_APP_ENV (union)/VITE_APP_NAME" \
  "5/5 presentes" "$V" "$RESULT" \
  "frontend/src/vite-env.d.ts" "$DEBUG"

# ── CA_03: 'staging' rechazado por tsc (RUN_BEHAVIOR=1) ─────────────────
if [ "$RUN_BEHAVIOR" = "1" ]; then
  TMP="$FRONTEND/src/_ca03-check.ts"
  cat > "$TMP" << 'TMP_EOF'
// Temporal CA_03 — tsc debe fallar al asignar 'staging'
const _invalid: ImportMetaEnv['VITE_APP_ENV'] = 'staging';
export { _invalid };
TMP_EOF
  TC_LOG=/tmp/validate-ts021-ca03.log
  : > "$TC_LOG"
  ( cd "$FRONTEND" && npm run type-check 2>&1 ) > "$TC_LOG" 2>&1
  CA03_EXIT=$?
  rm -f "$TMP"
  ( cd "$FRONTEND" && npm run type-check 2>&1 ) > /dev/null 2>&1
  CLEANUP_EXIT=$?
  V="tsc_con_staging_exit=$CA03_EXIT, tsc_tras_cleanup_exit=$CLEANUP_EXIT"
  RESULT=0
  [ "$CA03_EXIT" -ne 0 ] && [ "$CLEANUP_EXIT" -eq 0 ] && RESULT=1
  DEBUG=$(printf '$ cat > src/_ca03-check.ts (asignar staging)\n$ npm run type-check (con staging)\n%s\n$ rm src/_ca03-check.ts; npm run type-check\n%s\n\nError tsc (primeras 5 líneas):\n%s' \
    "$CA03_EXIT" "$CLEANUP_EXIT" "$(head -5 "$TC_LOG")")
  check "CA_03" "import.meta.env.VITE_APP_ENV rechaza 'staging' (tsc falla)" \
    "tsc_falla (exit!=0) + cleanup exit=0" "$V" "$RESULT" \
    "frontend/src/vite-env.d.ts + npm run type-check" "$DEBUG"
else
  V=$(count "'staging'" "$DTS")
  RESULT=0
  [ "$V" -eq 0 ] && RESULT=1
  DEBUG=$(printf '$ grep -c "%s" %s\n%s\nNOTA: RUN_BEHAVIOR=0 → solo verificación estática.' "'staging'" "$DTS" "$V")
  check "CA_03" "import.meta.env.VITE_APP_ENV rechaza 'staging' (estático RUN_BEHAVIOR=0)" \
    "sin 'staging' en archivo" "$V" "$RESULT" \
    "frontend/src/vite-env.d.ts" "$DEBUG"
fi

# ── CA_04: npm run type-check exit 0 ──────────────────────────────────────
TC_LOG=/tmp/validate-ts021-ca04.log
: > "$TC_LOG"
( cd "$FRONTEND" && npm run type-check 2>&1 ) > "$TC_LOG" 2>&1
TC_EXIT=$?
V="$TC_EXIT"
RESULT=0
[ "$TC_EXIT" -eq 0 ] && RESULT=1
DEBUG=$(printf '$ cd frontend && npm run type-check\n%s\n\nOutput (primeras 10 líneas):\n%s' \
  "exit=$TC_EXIT" "$(head -10 "$TC_LOG")")
check "CA_04" "npm run type-check (tsc -b) exit 0" \
  "exit=0" "$V" "$RESULT" \
  "frontend/package.json" "$DEBUG"

# ── CA_05: Frontend-test-Dev.sh verde (RUN_RUNNER=1) ─────────────────────
if [ "$RUN_RUNNER" = "1" ]; then
  RUNNER_LOG=/tmp/validate-ts021-runner.log
  : > "$RUNNER_LOG"
  ( setsid bash -c 'cd /prog/datos/investment-tracker/frontend && RUN_LIVE=0 RUN_BEHAVIOR=0 RUN_CLEANUP=0 bash tests/shellTest/Frontend-test-Dev.sh' > "$RUNNER_LOG" 2>&1 < /dev/null )
  RUNNER_EXIT=$?
  V="$RUNNER_EXIT"
  RESULT=0
  [ "$RUNNER_EXIT" -eq 0 ] && RESULT=1
  DEBUG=$(printf '$ setsid bash frontend/tests/shellTest/Frontend-test-Dev.sh\nexit=%s\n\nTail (20 líneas):\n%s' \
    "$RUNNER_EXIT" "$(tail -20 "$RUNNER_LOG")")
  check "CA_05" "Frontend-test-Dev.sh verde (14 grupos, 1 W-DOC, 0 nuevos)" \
    "exit=0" "$V" "$RESULT" \
    "frontend/tests/shellTest/Frontend-test-Dev.sh" "$DEBUG"
else
  V_EXEC=$([ -x "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh" ] && echo yes || echo no)
  V_HOOKS=$(ls "$FRONTEND/.husky/"pre-commit "$FRONTEND/.husky/"commit-msg "$FRONTEND/.husky/"pre-push 2>/dev/null | wc -l | tr -d ' ')
  V="runner_exec=$V_EXEC hooks=$V_HOOKS"
  RESULT=0
  [ "$V_EXEC" = "yes" ] && [ "$V_HOOKS" -eq 3 ] && RESULT=1
  DEBUG=$(printf '$ ls -la frontend/tests/shellTest/Frontend-test-Dev.sh\n%s\n$ ls frontend/.husky/{pre-commit,commit-msg,pre-push}\n%s archivos\nNOTA: RUN_RUNNER=0 → estático (pre-push hook corre runner real en el commit).' \
    "$(ls -la "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh" 2>&1)" "$V_HOOKS")
  check "CA_05" "Frontend-test-Dev.sh verde (estático RUN_RUNNER=0)" \
    "runner ejecutable + 3 hooks" "$V" "$RESULT" \
    "frontend/tests/shellTest + frontend/.husky/" "$DEBUG"
fi

# ── CA_06: README §Frontend → tipado vite-env.d.ts (incluye TOC) ─────────
N_HEAD='##### Tipado con `vite-env.d.ts`'
N_TOC='- [Tipado con `vite-env.d.ts`](#tipado-con-vite-envdts)'
N_REF_TS='/// <reference types="vite/client" />'
N_TS2322='TS2322'
N_TSC_B='tsc -b'
V_HEAD=$(count "$N_HEAD" "$README")
V_TOC=$(count "$N_TOC" "$README")
V_REF=$(count "$N_REF_TS" "$README")
V_TS=$(count "$N_TS2322" "$README")
V_TSC=$(count "$N_TSC_B" "$README")
V="head=$V_HEAD toc=$V_TOC ref=$V_REF ts2322=$V_TS tsc=$V_TSC"
RESULT=0
[ "$V_HEAD" -ge 1 ] && [ "$V_TOC" -ge 1 ] && [ "$V_REF" -ge 1 ] && [ "$V_TS" -ge 1 ] && [ "$V_TSC" -ge 1 ] && RESULT=1
DEBUG=$(grep -nE '##### Tipado con|Tipado con.*tipado-con-vite-envdts|reference types=|TS2322|tsc -b\) valida' "$README" 2>&1 | head -6)
check "CA_06" "README §Frontend nota tipado vite-env.d.ts (heading + TOC + bloque + TS2322 + tsc)" \
  "5/5 presentes" "$V" "$RESULT" \
  "README.md" "$DEBUG"

# ── CA_07: agente-frontend §14.11 → patrón obligatorio ────────────────────
N_TIPADO='**Tipado TS (`src/vite-env.d.ts`)**'
N_IFACE='interface ImportMetaEnv'
N_EXPORT='Sin `export {}`'
N_LINK='proxy-developer.md'
V_TIP=$(count "$N_TIPADO" "$AGENTE")
V_IF=$(count "$N_IFACE" "$AGENTE")
V_EX=$(count "$N_EXPORT" "$AGENTE")
V_TSC=$(count "$N_TSC_B" "$AGENTE")
V_LK=$(count "$N_LINK" "$AGENTE")
V="tip=$V_TIP iface=$V_IF sin_export=$V_EX tsc=$V_TSC link=$V_LK"
RESULT=0
[ "$V_TIP" -ge 1 ] && [ "$V_IF" -ge 1 ] && [ "$V_EX" -ge 1 ] \
  && [ "$V_TSC" -ge 1 ] && [ "$V_LK" -ge 1 ] && RESULT=1
DEBUG=$(grep -nE 'Tipado TS|interface ImportMetaEnv|Sin `export|tsc -b|proxy-developer\.md' "$AGENTE" 2>&1 | head -8)
check "CA_07" "agente-frontend §14.11 patrón obligatorio (bloque + sin export + tsc + link)" \
  "5/5 presentes" "$V" "$RESULT" \
  "docs/prompts/agente-frontend.md" "$DEBUG"

# ── CA_08: prompt_inicial regla 37 → tipado TS ───────────────────────────
N_TIPADO_P='**Tipado TS**: `src/vite-env.d.ts`'
N_UNION="'development' | 'qa' | 'production'"
N_LINK_A='`agente-frontend.md` §14.11'
V_TIP=$(count "$N_TIPADO_P" "$PROMPT")
V_U=$(count "$N_UNION" "$PROMPT")
V_TSC=$(count "$N_TSC_B" "$PROMPT")
V_LK=$(count "$N_LINK_A" "$PROMPT")
V="tip=$V_TIP union=$V_U tsc=$V_TSC link_agente=$V_LK"
RESULT=0
[ "$V_TIP" -ge 1 ] && [ "$V_U" -ge 1 ] && [ "$V_TSC" -ge 1 ] && [ "$V_LK" -ge 1 ] && RESULT=1
DEBUG=$(grep -nE 'Tipado TS|development|qa|production|tsc -b|agente-frontend\.md. §14.11' "$PROMPT" 2>&1 | tail -8)
check "CA_08" "prompt_inicial regla 37 nota tipado TS (sub + union + tsc + link agente)" \
  "4/4 presentes" "$V" "$RESULT" \
  "docs/prompts/prompt_inicial.md" "$DEBUG"

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
