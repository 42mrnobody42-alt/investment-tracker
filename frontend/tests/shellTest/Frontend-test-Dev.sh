#!/usr/bin/env bash
# ============================================================================
# Frontend-test-Dev.sh — Runner unificado de tests frontend (ambiente DEV)
# Uso:    bash Frontend-test-Dev.sh [--debug]
#         ALLOW_NEW=1 bash Frontend-test-Dev.sh     # modo WIP
#         RUN_SERVICES=0 bash Frontend-test-Dev.sh  # sin setup de servicios
#         RUN_CLEANUP=0 bash Frontend-test-Dev.sh   # sin cleanup (debug)
# ============================================================================
set -uo pipefail
IFS=$'\n\t'

# ── 1. THRESHOLDS ───────────────────────────────────────────────────────────
ESLINT_MIN_SUCCESSES="${ESLINT_MIN_SUCCESSES:-1}"
STYLELINT_MIN_SUCCESSES="${STYLELINT_MIN_SUCCESSES:-1}"
PRETTIER_MIN_SUCCESSES="${PRETTIER_MIN_SUCCESSES:-1}"
TYPECHECK_MIN_SUCCESSES="${TYPECHECK_MIN_SUCCESSES:-1}"
VITEST_MIN_SUCCESSES="${VITEST_MIN_SUCCESSES:-55}"
SMOKE_MIN_SUCCESSES="${SMOKE_MIN_SUCCESSES:-14}"
A11Y_MIN_SUCCESSES="${A11Y_MIN_SUCCESSES:-7}"
VITE_BUILD_MIN_SUCCESSES="${VITE_BUILD_MIN_SUCCESSES:-1}"
STORYBOOK_BUILD_MIN_SUCCESSES="${STORYBOOK_BUILD_MIN_SUCCESSES:-1}"
STORYBOOK_MANAGER_MIN_SUCCESSES="${STORYBOOK_MANAGER_MIN_SUCCESSES:-2}"

# ── 2. ÁRBOL DE EJECUCIÓN ───────────────────────────────────────────────────
RUN_AUTOFIX="${RUN_AUTOFIX:-1}"   # auto-fix antes de los checks (Prettier → Stylelint → ESLint)
RUN_LINT="${RUN_LINT:-1}"
  RUN_ESLINT="${RUN_ESLINT:-1}"; RUN_STYLELINT="${RUN_STYLELINT:-1}"; RUN_PRETTIER="${RUN_PRETTIER:-1}"
RUN_TYPES="${RUN_TYPES:-1}"
  RUN_TYPECHECK="${RUN_TYPECHECK:-1}"
RUN_UNIT="${RUN_UNIT:-1}"
  RUN_VITEST="${RUN_VITEST:-1}"
RUN_BUILD="${RUN_BUILD:-1}"
  RUN_VITE_BUILD="${RUN_VITE_BUILD:-1}"; RUN_STORYBOOK_BUILD="${RUN_STORYBOOK_BUILD:-1}"
RUN_E2E="${RUN_E2E:-1}"
  RUN_SMOKE="${RUN_SMOKE:-1}"; RUN_A11Y="${RUN_A11Y:-1}"; RUN_STORYBOOK_MANAGER="${RUN_STORYBOOK_MANAGER:-1}"
RUN_SERVICES="${RUN_SERVICES:-1}"   # 0 = Playwright webServer gestiona; 1 = levantada manual
RUN_CLEANUP="${RUN_CLEANUP:-1}"     # 0 = no ejecuta cleanup_services al final

# ── 3. DEBUG / WIP ──────────────────────────────────────────────────────────
DEBUG="${DEBUG:-0}"
ALLOW_NEW="${ALLOW_NEW:-0}"
[[ "${1:-}" == "--debug" ]] && DEBUG=1

# ── 4. CONSTANTES ───────────────────────────────────────────────────────────
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly FRONTEND_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
readonly PROJECT_ROOT="$(cd "$FRONTEND_DIR/.." && pwd)"
readonly LOG_DIR="$PROJECT_ROOT/logs/Frontend/Dev"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
readonly LOG_FILE="$LOG_DIR/Frontend-test-Dev_${TIMESTAMP}.log"
readonly APPROVED_FILE="$SCRIPT_DIR/approved-warnings.txt"

# Puertos (override por env; default desde config del proyecto)
STORYBOOK_PORT="${STORYBOOK_PORT:-}"
if [ -z "$STORYBOOK_PORT" ]; then
  STORYBOOK_PORT=$(grep -E '"storybook"[[:space:]]*:' "$FRONTEND_DIR/package.json" 2>/dev/null \
    | grep -oE -- '-p [0-9]+' | head -1 | awk '{print $2}')
  STORYBOOK_PORT="${STORYBOOK_PORT:-3010}"
fi
FRONTEND_PORT="${FRONTEND_PORT:-}"
if [ -z "$FRONTEND_PORT" ]; then
  FRONTEND_PORT=$(sed -nE 's/.*port:[[:space:]]*([0-9]+).*/\1/p' "$FRONTEND_DIR/vite.config.ts" 2>/dev/null | head -1)
  FRONTEND_PORT="${FRONTEND_PORT:-3000}"
fi

if [[ -t 1 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
  CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; NC=$'\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; NC=''
fi

# ── 5. ESTADO GLOBAL ────────────────────────────────────────────────────────
declare -a W_DOC_LIST=() W_NEW_LIST=() E_DOC_LIST=() E_NEW_LIST=() SUCCESS_LIST=() SKIPPED_LIST=()
declare -a PIDS_LAUNCHED=()
declare -a APPROVED_IDS=() APPROVED_GROUPS=() APPROVED_CATEGORIES=() APPROVED_MESSAGES=() APPROVED_PATTERNS=() APPROVED_REFS=()

# ── 6. UTILIDADES ───────────────────────────────────────────────────────────
debug() {
  if [[ "$DEBUG" == "1" ]]; then
    printf "${YELLOW}[DEBUG]${NC} %s\n" "$*"
    printf "[DEBUG] %s\n" "$*" >> "$LOG_FILE"
  fi
}

print_banner() {
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║   🧪 FRONTEND TEST RUNNER — DEV                                  ║${NC}"
  if [[ "$ALLOW_NEW" == "1" ]]; then
    echo -e "${BOLD}║   ${YELLOW}⚠️  MODO WIP — ALLOW_NEW=1${NC}${BOLD}                                 ║${NC}"
  fi
  echo -e "${BOLD}║   Log: ${LOG_FILE}${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════╝${NC}"
}

print_group_header() {
  echo ""
  echo -e "${CYAN}${BOLD}▶ $1${NC}"
  echo -e "${CYAN}──────────────────────────────────────────────────────────────────${NC}"
  echo "▶ $1" >> "$LOG_FILE"
  echo "──────────────────────────────────────────────────────────────────" >> "$LOG_FILE"
}

load_approved() {
  [[ -f "$APPROVED_FILE" ]] || { debug "approved-warnings.txt no existe"; return 0; }
  local id="" cat="" grp="" ref="" msg="" pat=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    if [[ "$line" =~ ^\[(.+)\]$ ]]; then
      id="${BASH_REMATCH[1]}"; cat=""; grp=""; ref=""; msg=""; pat=""
    elif [[ "$line" =~ ^category[[:space:]]*=[[:space:]]*(.+)$ ]]; then cat="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^group[[:space:]]*=[[:space:]]*(.+)$ ]]; then grp="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^ref[[:space:]]*=[[:space:]]*(.+)$ ]]; then ref="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^message[[:space:]]*=[[:space:]]*(.+)$ ]]; then msg="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^pattern[[:space:]]*=[[:space:]]*(.+)$ ]]; then
      pat="${BASH_REMATCH[1]}"
      APPROVED_IDS+=("$id"); APPROVED_CATEGORIES+=("$cat"); APPROVED_GROUPS+=("$grp")
      APPROVED_REFS+=("$ref"); APPROVED_MESSAGES+=("$msg"); APPROVED_PATTERNS+=("$pat")
    fi
  done < "$APPROVED_FILE"
  debug "approved loaded: ${#APPROVED_IDS[@]} entradas"
}

classify_item() {
  local group="$1" msg="$2" i
  for i in "${!APPROVED_IDS[@]}"; do
    [[ "${APPROVED_GROUPS[$i]}" == "$group" ]] || continue
    if printf "%s" "$msg" | grep -qE "${APPROVED_PATTERNS[$i]}" 2>/dev/null; then
      printf "DOC|%s|%s|%s\n" "${APPROVED_IDS[$i]}" "${APPROVED_REFS[$i]}" "${APPROVED_MESSAGES[$i]}"
      return 0
    fi
  done
  printf "NEW\n"
}

extract_items() {
  local group="$1" output="$2" exit_code="$3"
  output=$(printf "%s" "$output" | sed -E 's/\x1b\[[0-9;]*m//g')
  case "$group" in
    eslint|stylelint) printf "%s" "$output" | grep -E "^\s+[0-9]+:[0-9]+\s+(error|warning)" || true ;;
    prettier) printf "%s" "$output" | grep -E "^\[warn\]|Code style issues" || true ;;
    typescript) printf "%s" "$output" | grep -E "error TS[0-9]+" || true ;;
    storybook-build) printf "%s" "$output" | grep -E "Some chunks are larger|Skipping docgen|\(!\)" || true ;;
    vite-build) printf "%s" "$output" | grep -E "\(!\)|error during build|Some chunks are larger" || true ;;
    vitest|playwright-smoke|playwright-a11y|storybook-manager)
      printf "%s" "$output" | grep -E "FAILED|✘|Error:" | head -50 || true ;;
    *)
      if [[ "$exit_code" -ne 0 ]]; then
        printf "%s" "$output" | grep -Ei "error|fail" | head -10 || true
      fi ;;
  esac
}

run_check() {
  local group="$1" name="$2" cmd="$3" min_success="$4" parser="${5:-}"
  print_group_header "$name"
  debug "cmd=$cmd min_success=$min_success"

  local output exit_code
  set +e
  output=$(cd "$FRONTEND_DIR" || exit 99; eval "$cmd" 2>&1)
  exit_code=$?
  set +e
  printf "%s\n" "$output" >> "$LOG_FILE"
  [[ $exit_code -ne 0 || "$DEBUG" == "1" ]] && printf "%s\n" "$output"

  local success_count=0 err_count=0
  if [[ -n "$parser" ]] && declare -f "$parser" >/dev/null 2>&1; then
    "$parser" "$output"
  else
    if [[ $exit_code -eq 0 ]]; then success_count=1; else err_count=1; fi
  fi

  local items_raw
  items_raw=$(extract_items "$group" "$output" "$exit_code")
  if [[ -n "$items_raw" ]]; then
    while IFS= read -r item; do
      [[ -z "$item" ]] && continue
      local classification
      classification=$(classify_item "$group" "$item")
      if [[ "$classification" == DOC* ]]; then
        local cls_rest="${classification#DOC|}"
        local doc_id="${cls_rest%%|*}"
        local rest="${cls_rest#*|}"
        local doc_ref="${rest%%|*}"
        local doc_msg="${rest##*|}"
        if [[ "$doc_id" == W-* ]]; then
          W_DOC_LIST+=("$doc_id|$group|$doc_msg|$doc_ref")
        else
          E_DOC_LIST+=("$doc_id|$group|$doc_msg|$doc_ref")
        fi
      else
        if [[ $exit_code -ne 0 ]]; then
          E_NEW_LIST+=("$group|$item")
        else
          W_NEW_LIST+=("$group|$item")
        fi
      fi
    done <<< "$items_raw"
  fi

  if (( success_count >= min_success )) && (( exit_code == 0 )); then
    SUCCESS_LIST+=("$name|exit=$exit_code success=$success_count")
    printf "  ${GREEN}✅ %s${NC} (exit=%s success=%s)\n" "$name" "$exit_code" "$success_count"
  else
    printf "  ${RED}❌ %s${NC} (exit=%s success=%s)\n" "$name" "$exit_code" "$success_count"
  fi
  return 0
}

parse_vitest() {
  local out="$1"; out=$(printf "%s" "$out" | sed -E 's/\x1b\[[0-9;]*m//g')
  success_count=$(printf "%s" "$out" | grep -E "^ *Tests +[0-9]+ passed" | tail -1 | grep -oE "[0-9]+" | head -1 || true)
  success_count="${success_count:-0}"
  err_count=$(printf "%s" "$out" | grep -E "^ *Tests +[0-9]+ failed" | tail -1 | grep -oE "[0-9]+" | head -1 || true)
  err_count="${err_count:-0}"
}

parse_playwright() {
  local out="$1"; out=$(printf "%s" "$out" | sed -E 's/\x1b\[[0-9;]*m//g')
  success_count=$(printf "%s" "$out" | grep -E "^ *[0-9]+ passed" | tail -1 | awk '{print $1}' || true)
  success_count="${success_count:-0}"
  err_count=$(printf "%s" "$out" | grep -E "^ *[0-9]+ failed" | tail -1 | awk '{print $1}' || true)
  err_count="${err_count:-0}"
}

# ── 7. SERVICIOS (setup/teardown con setsid — desacoplado del TTY) ──────────
wait_for_http() {
  local url="$1" name="$2" max_wait="${3:-30}" i=0
  while [ $i -lt "$max_wait" ]; do
    if curl -sf -o /dev/null --max-time 2 "$url" 2>/dev/null; then
      debug "$name OK ($url)"; return 0
    fi
    sleep 1; i=$((i+1))
  done
  debug "$name TIMEOUT ($url)"; return 1
}

start_npm_service() {
  local name="$1" cmd="$2" url="$3" logfile="$4" max_wait="$5"
  local pid

  if wait_for_http "$url" "$name" 3; then
    echo "  ${GREEN}✅ $name ya arriba${NC}"
    return 0
  fi

  echo "  ${CYAN}→ levantando $name (setsid, log: $logfile)${NC}"
  setsid bash -c "cd '$FRONTEND_DIR' && $cmd" > "$logfile" 2>&1 < /dev/null &
  pid=$!
  PIDS_LAUNCHED+=("$pid")
  debug "$name PID=$pid (process group)"

  local i=0
  while [ $i -lt "$max_wait" ]; do
    if wait_for_http "$url" "$name" 1; then
      echo "  ${GREEN}✅ $name arriba (${i}s)${NC}"
      return 0
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
      echo "  ${RED}❌ $name murió al arrancar${NC}"
      tail -20 "$logfile" 2>/dev/null | sed 's/^/    /'
      E_NEW_LIST+=("services|$name murió al arrancar — ver $logfile")
      return 1
    fi
    i=$((i+1))
  done

  echo "  ${RED}❌ $name timeout ${max_wait}s${NC}"
  tail -20 "$logfile" 2>/dev/null | sed 's/^/    /'
  E_NEW_LIST+=("services|$name timeout ${max_wait}s")
  return 1
}

setup_services() {
  [[ "$RUN_SERVICES" == "1" ]] || { SKIPPED_LIST+=("SERVICES"); return 0; }
  print_group_header "Servicios locales (setup manual)"
  start_npm_service "storybook-dev" "npm run storybook" "http://localhost:${STORYBOOK_PORT}" "/tmp/storybook-dev.log" 90 \
    && SUCCESS_LIST+=("Servicios|storybook-dev arriba (setup manual)") \
    || return 1
  return 0
}

cleanup_services() {
  local pid pgid

  (( ${#PIDS_LAUNCHED[@]} == 0 )) && {
    echo ""
    echo "  ${CYAN}→ cleanup: sin procesos que cerrar${NC}"
    return 0
  }

  echo ""
  echo "  ${CYAN}→ cleanup: cerrando process groups: ${PIDS_LAUNCHED[*]}${NC}"

  # SIGTERM al process group (solo si es líder de grupo → es nuestro setsid)
  for pid in "${PIDS_LAUNCHED[@]}"; do
    if ! kill -0 "$pid" 2>/dev/null; then
      debug "PID $pid ya no existe"
      continue
    fi
    pgid=$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ')
    if [[ "$pgid" == "$pid" ]]; then
      debug "SIGTERM process group $pid"
      kill -TERM -- "-$pid" 2>/dev/null || true
    else
      debug "PID $pid no es líder (PGID=$pgid), SIGTERM solo PID"
      kill -TERM "$pid" 2>/dev/null || true
    fi
  done

  sleep 3

  # SIGKILL solo si sigue vivo Y sigue siendo líder de grupo
  for pid in "${PIDS_LAUNCHED[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      pgid=$(ps -o pgid= -p "$pid" 2>/dev/null | tr -d ' ')
      if [[ "$pgid" == "$pid" ]]; then
        echo "  ${YELLOW}→ SIGKILL process group $pid${NC}"
        kill -KILL -- "-$pid" 2>/dev/null || true
      fi
    fi
  done

  PIDS_LAUNCHED=()
}

# ── REGLA DE SEGURIDAD: nunca matar procesos por puerto ─────────────────────
# Ningún cleanup usa `lsof`+`kill` ni `pkill`. Solo se mata lo que está en
# PIDS_LAUNCHED (procesos que este script lanzó con setsid). Si el usuario
# tiene otro Storybook/vite corriendo en los puertos, NO se toca: el runner
# reutiliza el existente vía `wait_for_http` en start_npm_service.
check_ports_occupied() {
  local port pid count
  for port in "${STORYBOOK_PORT:-3010}" "${FRONTEND_PORT:-3000}"; do
    [ -z "$port" ] && continue
    count=$(lsof -ti:"$port" 2>/dev/null | wc -l)
    if [ "$count" -eq 1 ]; then
      pid=$(lsof -ti:"$port" 2>/dev/null)
      # 1 solo match: podría ser un proceso legítimo del usuario (Storybook ya
      # corriendo) o un edge case. NUNCA se mata — solo se informa.
      echo "  ${CYAN}ℹ️  puerto $port ya tiene 1 proceso (PID $pid) — se reutilizará${NC}"
    elif [ "$count" -gt 1 ]; then
      echo "  ${YELLOW}⚠️  puerto $port tiene $count PIDs — revisar manualmente${NC}"
    fi
  done
}


# ── 8. GRUPOS ───────────────────────────────────────────────────────────────
run_autofix() {
  [[ "$RUN_AUTOFIX" == "1" ]] || { SKIPPED_LIST+=("AUTOFIX"); return 0; }
  print_group_header "Auto-fix pre-run (Prettier → Stylelint → ESLint)"
  debug "scope: frontend/ solo (src/, tests/, configs). NO toca docs/."

  local e1=0 e2=0 e3=0
  echo "── Prettier ──" >> "$LOG_FILE"
  ( cd "$FRONTEND_DIR" \
    && npx prettier --write \
         "src/**/*.{ts,tsx,css}" \
         "tests/**/*.{ts,tsx,html}" \
         "*.ts" \
         "tsconfig*.json" \
         ".storybook/*.ts" \
         2>&1 ) | tee -a "$LOG_FILE" || e1=$?
  echo "" >> "$LOG_FILE"

  echo "── Stylelint ──" >> "$LOG_FILE"
  ( cd "$FRONTEND_DIR" \
    && npx stylelint "src/**/*.css" --fix \
         2>&1 ) | tee -a "$LOG_FILE" || e2=$?
  echo "" >> "$LOG_FILE"

  echo "── ESLint ──" >> "$LOG_FILE"
  ( cd "$FRONTEND_DIR" \
    && npx eslint \
         "src/**/*.{ts,tsx}" \
         "tests/**/*.{ts,tsx}" \
         "*.ts" \
         ".storybook/*.ts" \
         --fix \
         2>&1 ) | tee -a "$LOG_FILE" || e3=$?
  echo "" >> "$LOG_FILE"

  local detail="prettier=$e1 stylelint=$e2 eslint=$e3"
  if (( e1 == 0 && e2 == 0 && e3 == 0 )); then
    SUCCESS_LIST+=("Auto-fix pre-run|$detail")
    printf "  ${GREEN}✅ Auto-fix OK${NC} (%s)\n" "$detail"
    printf "✅ Auto-fix pre-run (%s)\n" "$detail" >> "$LOG_FILE"
  else
    E_NEW_LIST+=("autofix|auto-fix falló ($detail) — ver $LOG_FILE")
    printf "  ${RED}❌ Auto-fix falló${NC} (%s) — ver %s\n" "$detail" "$LOG_FILE"
    printf "❌ Auto-fix pre-run (%s)\n" "$detail" >> "$LOG_FILE"
  fi
  return 0
}


run_lint() {
  [[ "$RUN_LINT" == "1" ]] || { SKIPPED_LIST+=("LINT"); return 0; }
  [[ "$RUN_ESLINT" == "1" ]] && run_check "eslint" "ESLint" "npm run lint" "$ESLINT_MIN_SUCCESSES"
  [[ "$RUN_STYLELINT" == "1" ]] && run_check "stylelint" "Stylelint" "npm run lint:css" "$STYLELINT_MIN_SUCCESSES"
  [[ "$RUN_PRETTIER" == "1" ]] && run_check "prettier" "Prettier" "npm run format:check" "$PRETTIER_MIN_SUCCESSES"
  return 0
}
run_types() {
  [[ "$RUN_TYPES" == "1" ]] || { SKIPPED_LIST+=("TYPES"); return 0; }
  [[ "$RUN_TYPECHECK" == "1" ]] && run_check "typescript" "TypeScript" "npm run type-check" "$TYPECHECK_MIN_SUCCESSES"
  return 0
}
run_unit() {
  [[ "$RUN_UNIT" == "1" ]] || { SKIPPED_LIST+=("UNIT"); return 0; }
  [[ "$RUN_VITEST" == "1" ]] && run_check "vitest" "Vitest (unit)" "npm run test:run" "$VITEST_MIN_SUCCESSES" "parse_vitest"
  return 0
}
run_build() {
  [[ "$RUN_BUILD" == "1" ]] || { SKIPPED_LIST+=("BUILD"); return 0; }
  [[ "$RUN_VITE_BUILD" == "1" ]] && run_check "vite-build" "Vite build" "npm run build" "$VITE_BUILD_MIN_SUCCESSES"
  [[ "$RUN_STORYBOOK_BUILD" == "1" ]] && run_check "storybook-build" "Storybook build" "npm run build-storybook" "$STORYBOOK_BUILD_MIN_SUCCESSES"
  return 0
}
run_e2e() {
  [[ "$RUN_E2E" == "1" ]] || { SKIPPED_LIST+=("E2E"); return 0; }
  [[ "$RUN_SMOKE" == "1" ]] && run_check "playwright-smoke" "Playwright smoke (7 proyectos)" "npx playwright test tests/e2e/smoke.spec.ts" "$SMOKE_MIN_SUCCESSES" "parse_playwright"
  [[ "$RUN_A11Y" == "1" ]] && run_check "playwright-a11y" "Playwright a11y (7 proyectos)" "npx playwright test tests/e2e/a11y.spec.ts" "$A11Y_MIN_SUCCESSES" "parse_playwright"
  [[ "$RUN_STORYBOOK_MANAGER" == "1" ]] && run_check "storybook-manager" "Storybook manager E2E" "npx playwright test --config playwright.storybook.config.ts" "$STORYBOOK_MANAGER_MIN_SUCCESSES" "parse_playwright"
  return 0
}

# ── 9. RESUMEN ──────────────────────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║                 📊 RESUMEN FINAL — FRONTEND DEV                   ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════╝${NC}"

  if (( ${#W_DOC_LIST[@]} > 0 )); then
    echo ""; echo -e "${CYAN}${BOLD}── WARNINGS DOCUMENTADOS (${#W_DOC_LIST[@]}) ──${NC}"
    for w in "${W_DOC_LIST[@]}"; do
      IFS='|' read -r id grp msg ref <<< "$w"
      printf "  ${CYAN}[%s]${NC} %s\n" "$id" "$grp"
      printf "    ${CYAN}↳${NC} Mensaje: %s\n" "$msg"
      printf "    ${CYAN}↳${NC} Ref: %s\n" "$ref"
    done
  fi

  if (( ${#W_NEW_LIST[@]} > 0 )); then
    echo ""; echo -e "${YELLOW}${BOLD}── WARNINGS NUEVOS (${#W_NEW_LIST[@]}) ──${NC}"
    local i=1
    for w in "${W_NEW_LIST[@]}"; do
      IFS='|' read -r grp msg <<< "$w"
      printf "  ${YELLOW}[W-NEW-%03d]${NC} %s\n" "$i" "$grp"
      printf "    ${YELLOW}↳${NC} Mensaje: %s\n" "$msg"
      i=$((i+1))
    done
  fi

  if (( ${#E_DOC_LIST[@]} > 0 )); then
    echo ""; echo -e "${CYAN}${BOLD}── ERRORES DOCUMENTADOS (${#E_DOC_LIST[@]}) ──${NC}"
    for e in "${E_DOC_LIST[@]}"; do
      IFS='|' read -r id grp msg ref <<< "$e"
      printf "  ${CYAN}[%s]${NC} %s\n" "$id" "$grp"
      printf "    ${CYAN}↳${NC} Mensaje: %s\n" "$msg"
      printf "    ${CYAN}↳${NC} Ref: %s\n" "$ref"
    done
  fi

  if (( ${#E_NEW_LIST[@]} > 0 )); then
    echo ""; echo -e "${RED}${BOLD}── ERRORES NUEVOS (${#E_NEW_LIST[@]}) ──${NC}"
    local i=1
    for e in "${E_NEW_LIST[@]}"; do
      IFS='|' read -r grp msg <<< "$e"
      printf "  ${RED}[E-NEW-%03d]${NC} %s\n" "$i" "$grp"
      printf "    ${RED}↳${NC} Mensaje: %s\n" "$msg"
      i=$((i+1))
    done
  fi

  if (( ${#SUCCESS_LIST[@]} > 0 )); then
    echo ""; echo -e "${GREEN}${BOLD}── ÉXITOS (${#SUCCESS_LIST[@]}) ──${NC}"
    local i=1
    for s in "${SUCCESS_LIST[@]}"; do
      IFS='|' read -r name detail <<< "$s"
      printf "  ${GREEN}[S-%03d]${NC} %s (%s)\n" "$i" "$name" "$detail"
      i=$((i+1))
    done
  fi

  if (( ${#SKIPPED_LIST[@]} > 0 )); then
    echo ""; echo -e "${CYAN}── OMITIDOS (${#SKIPPED_LIST[@]}) ──${NC}"
    for s in "${SKIPPED_LIST[@]}"; do echo "  [SKIP] $s"; done
  fi

  echo ""
  echo -e "${BOLD}── TOTALES ──${NC}"
  printf "  ✅ PASS: %d\n" "${#SUCCESS_LIST[@]}"
  printf "  ⚠️  WARN: %d documentados, %d nuevos\n" "${#W_DOC_LIST[@]}" "${#W_NEW_LIST[@]}"
  printf "  ❌ ERR:  %d documentados, %d nuevos\n" "${#E_DOC_LIST[@]}" "${#E_NEW_LIST[@]}"
  printf "  ⏭️  SKIP: %d\n" "${#SKIPPED_LIST[@]}"
  echo "  📄 Log: $LOG_FILE"
}

# ── 10. MAIN ────────────────────────────────────────────────────────────────
main() {
  mkdir -p "$LOG_DIR"
  : > "$LOG_FILE"
  load_approved
  print_banner
  debug "FRONTEND_DIR=$FRONTEND_DIR"
  debug "ALLOW_NEW=$ALLOW_NEW RUN_SERVICES=$RUN_SERVICES RUN_CLEANUP=$RUN_CLEANUP"

  run_autofix || true
  run_lint || true
  run_types || true
  run_unit || true
  run_build || true

  # ⬇️ Comentar esta línea para NO levantar servicios manualmente
  check_ports_occupied || true
  setup_services || true

  run_e2e || true

  print_summary

  local blocking=$(( ${#W_NEW_LIST[@]} + ${#E_NEW_LIST[@]} ))
  if (( blocking > 0 )); then
    if [[ "$ALLOW_NEW" == "1" ]]; then
      echo ""
      echo -e "${YELLOW}${BOLD}🚨 MODO WIP — $blocking nuevos sin documentar. NO PUSH. NO MERGE.${NC}"
      exit 0
    fi
    echo ""
    echo -e "${RED}${BOLD}🔴 COMMIT BLOQUEADO — $blocking nuevos sin documentar.${NC}"
    exit 1
  fi

  echo ""
  echo -e "${GREEN}${BOLD}✅ TODO VERDE.${NC}"
  exit 0
}

cleanup_on_exit() {
  if [[ "$RUN_CLEANUP" == "1" ]]; then
    cleanup_services
  else
    echo ""
    echo "  ${YELLOW}⚠️  RUN_CLEANUP=0 — cleanup_services NO ejecutado${NC}"
    if (( ${#PIDS_LAUNCHED[@]} > 0 )); then
      echo "  ${YELLOW}   PIDs vivos: ${PIDS_LAUNCHED[*]} (mátalos manualmente si es necesario)${NC}"
    fi
  fi
}
# Comentar la siguiente línea para NO ejecutar cleanup en absoluto
trap 'cleanup_on_exit' EXIT

main "$@"
