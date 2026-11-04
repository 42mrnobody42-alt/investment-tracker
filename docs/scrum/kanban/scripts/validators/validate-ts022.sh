#!/usr/bin/env bash
# ============================================================================
# validate-ts022.sh — TS-022 (#627) — backup + benchmark + decision + Figma
# Invocado por ../validate-task-in-kanban.sh <issue-number>
# Env: ISSUE_NUM, TS_CODE, LOG_FILE
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
DOCS="$REPO/docs"
README="$REPO/README.md"
ISSUE_NUM="${ISSUE_NUM:-627}"
TS_CODE="${TS_CODE:-TS-022}"

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
  echo "${CLR_CYAN}${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"
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
echo "  $TS_CODE (#$ISSUE_NUM)"
echo "${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"

# ── CA_01: backup branding + README rollback ─────────────────────────────
BACKUP_DIR="$FRONTEND/src/styles/branding-backup-v0.1.14"
V_DIR=$([ -d "$BACKUP_DIR" ] && echo yes || echo no)
V_README=$([ -f "$BACKUP_DIR/README.md" ] && echo yes || echo no)
V_CSS=$(ls "$BACKUP_DIR"/*.css 2>/dev/null | wc -l | tr -d ' ')
V="dir=$V_DIR readme=$V_README css=$V_CSS"
RESULT=0
[ "$V_DIR" = "yes" ] && [ "$V_README" = "yes" ] && [ "$V_CSS" = "5" ] && RESULT=1
DEBUG="$(printf '$ ls -la %s\n%s\n$ ls %s/*.css | wc -l\n%s' "$BACKUP_DIR" "$(ls -la "$BACKUP_DIR" 2>&1 | head -10)" "$BACKUP_DIR" "$V_CSS")"
check "CA_01" "backup branding + README rollback" "dir=yes readme=yes css=5" "$V" "$RESULT" "frontend/src/styles/branding-backup-v0.1.14/" "$DEBUG"

# ── CA_02: benchmark 4 tools + videos ────────────────────────────────────
BENCH="$DOCS/tecnica/04-frontend-react-css-moderno/convenciones/benchmark-tokens-2026.md"
V_EXIST=$([ -f "$BENCH" ] && echo yes || echo no)
V_SD=$(grep -cF 'Style Dictionary v5' "$BENCH" 2>/dev/null || echo 0)
V_TS=$(grep -cF 'Tokens Studio' "$BENCH" 2>/dev/null || echo 0)
V_FV=$(grep -cF 'Figma Variables' "$BENCH" 2>/dev/null || echo 0)
V_CSSP=$(grep -cF 'CSS custom properties' "$BENCH" 2>/dev/null || echo 0)
V_VID=$(grep -cF 'Videos de referencia' "$BENCH" 2>/dev/null || echo 0)
V="exist=$V_EXIST sd=$V_SD ts=$V_TS fv=$V_FV cssp=$V_CSSP vid=$V_VID"
RESULT=0
[ "$V_EXIST" = "yes" ] && [ "$V_SD" -ge 1 ] && [ "$V_TS" -ge 1 ] && [ "$V_FV" -ge 1 ] && [ "$V_CSSP" -ge 1 ] && [ "$V_VID" -ge 1 ] && RESULT=1
DEBUG="$(grep -nE 'Style Dictionary v5|Tokens Studio|Figma Variables|CSS custom properties|Videos de referencia' "$BENCH" 2>&1 | head -5)"
check "CA_02" "benchmark 4 tools + videos max 10 min" "exist=yes sd>=1 ts>=1 fv>=1 cssp>=1 vid>=1" "$V" "$RESULT" "docs/tecnica/.../convenciones/benchmark-tokens-2026.md" "$DEBUG"

# ── CA_03: benchmark 2+ DTCG + decision ──────────────────────────────────
V_MGD=$(grep -cF 'Made Good Designs' "$BENCH" 2>/dev/null || echo 0)
V_IBM=$(grep -cF 'IBM Carbon' "$BENCH" 2>/dev/null || echo 0)
V_DEC=$(grep -cF 'Made Good Designs Starter' "$BENCH" 2>/dev/null || echo 0)
V="mgd=$V_MGD ibm=$V_IBM dec=$V_DEC"
RESULT=0
[ "$V_MGD" -ge 1 ] && [ "$V_IBM" -ge 1 ] && [ "$V_DEC" -ge 1 ] && RESULT=1
DEBUG="$(grep -nE 'Made Good Designs|IBM Carbon' "$BENCH" 2>&1 | head -5)"
check "CA_03" "benchmark 2+ DTCG base + decision" "mgd>=1 ibm>=1 dec>=1" "$V" "$RESULT" "docs/tecnica/.../convenciones/benchmark-tokens-2026.md" "$DEBUG"

# ── CA_04: #557 decision tecnica ─────────────────────────────────────────
BODY557=$(gh api repos/42mrnobody42-alt/investment-tracker/issues/557 --jq .body 2>/dev/null)
V_SD=$(printf '%s' "$BODY557" | grep -cF 'Style Dictionary v5' || echo 0)
V_MGD=$(printf '%s' "$BODY557" | grep -cF 'Made Good Designs' || echo 0)
V_IMP=$(printf '%s' "$BODY557" | grep -cF 'frontend/src/components/imported/' || echo 0)
V_147=$(printf '%s' "$BODY557" | grep -cF 'TS-147' || echo 0)
V="sd=$V_SD mgd=$V_MGD imp=$V_IMP t147=$V_147"
RESULT=0
[ "$V_SD" -ge 1 ] && [ "$V_MGD" -ge 1 ] && [ "$V_IMP" -ge 1 ] && [ "$V_147" -ge 1 ] && RESULT=1
DEBUG="$(printf '%s' "$BODY557" | grep -nE 'Style Dictionary|Made Good|imported/|TS-147' | head -5)"
check "CA_04" "#557 decision tecnica completa" "sd>=1 mgd>=1 imp>=1 t147>=1" "$V" "$RESULT" "github.com/.../issues/557" "$DEBUG"

# ── CA_05: doc Figma ─────────────────────────────────────────────────────
FIGMA="$DOCS/tecnica/04-frontend-react-css-moderno/flujo-de-trabajo/figma/00_alcance.md"
V_EXIST=$([ -f "$FIGMA" ] && echo yes || echo no)
V_FF=$(grep -cF 'Figma free' "$FIGMA" 2>/dev/null || echo 0)
V_1M=$(grep -cF '1 modo por coleccion' "$FIGMA" 2>/dev/null || echo 0)
V_TS=$(grep -cF 'Tokens Studio free' "$FIGMA" 2>/dev/null || echo 0)
V_SD=$(grep -cF 'Style Dictionary v5' "$FIGMA" 2>/dev/null || echo 0)
V_IMP=$(grep -cF 'frontend/src/components/imported/' "$FIGMA" 2>/dev/null || echo 0)
V_SEQ=$(grep -cF 'sequenceDiagram' "$FIGMA" 2>/dev/null || echo 0)
V_FLOW=$(grep -cF 'flowchart LR' "$FIGMA" 2>/dev/null || echo 0)
V="exist=$V_EXIST ff=$V_FF 1m=$V_1M ts=$V_TS sd=$V_SD imp=$V_IMP seq=$V_SEQ flow=$V_FLOW"
RESULT=0
[ "$V_EXIST" = "yes" ] && [ "$V_FF" -ge 1 ] && [ "$V_1M" -ge 1 ] && [ "$V_TS" -ge 1 ] && [ "$V_SD" -ge 1 ] && [ "$V_IMP" -ge 1 ] && [ "$V_SEQ" -ge 1 ] && [ "$V_FLOW" -ge 1 ] && RESULT=1
DEBUG="$(grep -nE 'Figma free|1 modo por coleccion|Tokens Studio free|Style Dictionary v5|frontend/src/components/imported/|sequenceDiagram|flowchart LR' "$FIGMA" 2>&1 | head -8)"
check "CA_05" "doc Figma 00_alcance.md completo" "exist=yes ff>=1 1m>=1 ts>=1 sd>=1 imp>=1 seq>=1 flow>=1" "$V" "$RESULT" "docs/tecnica/.../flujo-de-trabajo/figma/00_alcance.md" "$DEBUG"

# ── CA_06: runner verde ─────────────────────────────────────────────────
RUNNER_LOG=/tmp/validate-ts022-runner.log
: > "$RUNNER_LOG"
( cd "$FRONTEND" && timeout 300 bash -c 'RUN_LIVE=0 RUN_BEHAVIOR=0 RUN_CLEANUP=0 bash tests/shellTest/Frontend-test-Dev.sh' ) > "$RUNNER_LOG" 2>&1
RUNNER_EXIT=$?
V="exit=$RUNNER_EXIT"
RESULT=0
[ "$RUNNER_EXIT" -eq 0 ] && RESULT=1
DEBUG="$(tail -10 "$RUNNER_LOG")"
check "CA_06" "Frontend-test-Dev.sh verde" "exit=0" "$V" "$RESULT" "frontend/tests/shellTest/Frontend-test-Dev.sh" "$DEBUG"

# ── CA_07: README item 8 + sin ### duplicada ────────────────────────────
V_ITEM8=$(grep -cF 'docs/plantillasParaDocumentar' "$README" 2>/dev/null || echo 0)
V_PLANT=$(grep -cF '### Plantillas para documentar' "$README" 2>/dev/null | head -1); V_PLANT=${V_PLANT:-0}
V="item8=$V_ITEM8 plant_dup=$V_PLANT"
RESULT=0
[ "$V_ITEM8" -ge 1 ] && [ "$V_PLANT" -eq 0 ] && RESULT=1
DEBUG="$(grep -nE 'docs/plantillasParaDocumentar|### Plantillas para documentar' "$README" 2>&1 | head -5)"
check "CA_07" "README item 8 + sin seccion duplicada" "item8>=1 plant_dup=0" "$V" "$RESULT" "README.md" "$DEBUG"

# ── CA_08: agente-frontend backup + Figma doc ───────────────────────────
AGENTE="$DOCS/prompts/agente-frontend.md"
V_BK=$(grep -cF 'branding-backup-v0.1.14' "$AGENTE" 2>/dev/null || echo 0)
V_FIG=$(grep -cF 'flujo-de-trabajo/figma/00_alcance.md' "$AGENTE" 2>/dev/null || echo 0)
V="backup=$V_BK figma=$V_FIG"
RESULT=0
[ "$V_BK" -ge 1 ] && [ "$V_FIG" -ge 1 ] && RESULT=1
DEBUG="$(grep -nE 'branding-backup-v0.1.14|flujo-de-trabajo/figma/00_alcance.md' "$AGENTE" 2>&1 | head -5)"
check "CA_08" "agente-frontend backup + Figma doc" "backup>=1 figma>=1" "$V" "$RESULT" "docs/prompts/agente-frontend.md" "$DEBUG"

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
