#!/usr/bin/env bash
# ============================================================================
# validate-ts023.sh — TS-023 (#628) — imported/ + brand-overrides + SD v5
# Invocado por ../validate-task-in-kanban.sh 628
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
DOCS="$REPO/docs"
README="$REPO/README.md"
ISSUE_NUM="${ISSUE_NUM:-628}"
TS_CODE="${TS_CODE:-TS-023}"

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
  [ -n "$ref" ] && echo "  Dónde verificar : $ref"
  [ -n "$debug" ] && { echo "  Debug :"; echo "$debug" | head -30 | sed 's/^/    /'; }
  case "$verdict" in
    1) echo "  ${CLR_GREEN}Resultado: ✅ APROBÓ${CLR_NC}";           PASS=$((PASS+1)) ;;
    2) echo "  ${CLR_YELLOW}Resultado: ⚠️  CONTRADICCIÓN${CLR_NC}";   CONTRA=$((CONTRA+1)) ;;
    *) echo "  ${CLR_RED}Resultado: ❌ NO APROBÓ${CLR_NC}";           FAIL=$((FAIL+1)) ;;
  esac
  if [ -n "$LOG_FILE" ]; then
    {
      echo "--------- $ca_code — $title ---------"
      echo "Esperado: $expected"; echo "Obtenido: $obtained"
      [ -n "$ref" ] && echo "Dónde verificar: $ref"
      [ -n "$debug" ] && { echo "Debug:"; echo "$debug" | head -30 | sed 's/^/  /'; }
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

# ── CA_01: estructura imported/ completa ────────────────────────────────
BASE="$FRONTEND/src/components/imported"
V_ATOMS_BTN=$([ -d "$BASE/atoms/buttons" ] && echo yes || echo no)
V_ATOMS_CARDS=$([ -d "$BASE/atoms/cards" ] && echo yes || echo no)
V_ATOMS_SRCH=$([ -d "$BASE/atoms/searchbar" ] && echo yes || echo no)
V_LAYOUT=$([ -d "$BASE/layout" ] && echo yes || echo no)
V_THEMES=$([ -d "$BASE/themes" ] && echo yes || echo no)
V_BRAND=$([ -d "$BASE/brand-overrides" ] && echo yes || echo no)
V="btn=$V_ATOMS_BTN cards=$V_ATOMS_CARDS srch=$V_ATOMS_SRCH layout=$V_LAYOUT themes=$V_THEMES brand=$V_BRAND"
RESULT=0
[ "$V_ATOMS_BTN" = "yes" ] && [ "$V_ATOMS_CARDS" = "yes" ] && [ "$V_ATOMS_SRCH" = "yes" ] && [ "$V_LAYOUT" = "yes" ] && [ "$V_THEMES" = "yes" ] && [ "$V_BRAND" = "yes" ] && RESULT=1
check "CA_01" "estructura imported/ completa" "btn=yes cards=yes srch=yes layout=yes themes=yes brand=yes" "$V" "$RESULT" "frontend/src/components/imported/"

# ── CA_02: DTCG base (JSON válido en atoms/ y layout/) ─────────────────
COUNT_JSON=$(find "$BASE/atoms" "$BASE/layout" -name '*.tokens.json' 2>/dev/null | wc -l | tr -d ' ')
VALID_JSON=0
for f in $(find "$BASE/atoms" "$BASE/layout" -name '*.tokens.json' 2>/dev/null); do
  if node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" 2>/dev/null; then
    VALID_JSON=$((VALID_JSON+1))
  fi
done
V="count=$COUNT_JSON valid=$VALID_JSON"
RESULT=0
[ "$COUNT_JSON" -ge 5 ] && [ "$VALID_JSON" -eq "$COUNT_JSON" ] && RESULT=1
check "CA_02" "DTCG base válido en atoms/ y layout/" "count>=5 valid=count" "$V" "$RESULT" "frontend/src/components/imported/{atoms,layout}/"

# ── CA_03: brand-overrides con cyan, Inter, JetBrains, easings ──────────
V_CYAN=$(grep -cF '#00838f' "$BASE/brand-overrides/color.tokens.json" 2>/dev/null | head -1); V_CYAN=${V_CYAN:-0}
V_INTER=$(grep -cF 'Inter' "$BASE/brand-overrides/typography.tokens.json" 2>/dev/null | head -1); V_INTER=${V_INTER:-0}
V_JB=$(grep -cF 'JetBrains Mono' "$BASE/brand-overrides/typography.tokens.json" 2>/dev/null | head -1); V_JB=${V_JB:-0}
V_SS=$(grep -cF 'springSoft' "$BASE/brand-overrides/motion.tokens.json" 2>/dev/null | head -1); V_SS=${V_SS:-0}
V_SM=$(grep -cF 'springMedium' "$BASE/brand-overrides/motion.tokens.json" 2>/dev/null | head -1); V_SM=${V_SM:-0}
V_EO=$(grep -cF 'expoOut' "$BASE/brand-overrides/motion.tokens.json" 2>/dev/null | head -1); V_EO=${V_EO:-0}
V="cyan=$V_CYAN inter=$V_INTER jb=$V_JB ss=$V_SS sm=$V_SM eo=$V_EO"
RESULT=0
[ "$V_CYAN" -ge 1 ] && [ "$V_INTER" -ge 1 ] && [ "$V_JB" -ge 1 ] && [ "$V_SS" -ge 1 ] && [ "$V_SM" -ge 1 ] && [ "$V_EO" -ge 1 ] && RESULT=1
check "CA_03" "brand-overrides: cyan + Inter + JetBrains + easings" "cyan>=1 inter>=1 jb>=1 ss>=1 sm>=1 eo>=1" "$V" "$RESULT" "frontend/src/components/imported/brand-overrides/"

# ── CA_04: Story DesignTokens/Compare ───────────────────────────────────
STORY="$FRONTEND/src/components/DesignTokens/DesignTokensCompare.stories.tsx"
V_EXIST=$([ -f "$STORY" ] && echo yes || echo no)
V_TITLE=$(grep -cF "title: 'DesignTokens/Compare'" "$STORY" 2>/dev/null | head -1); V_TITLE=${V_TITLE:-0}
V_COMPARE=$(grep -cE 'export const Compare' "$STORY" 2>/dev/null | head -1); V_COMPARE=${V_COMPARE:-0}
V_THEME=$(grep -cF 'theme:' "$STORY" 2>/dev/null | head -1); V_THEME=${V_THEME:-0}
V="exist=$V_EXIST title=$V_TITLE compare=$V_COMPARE theme=$V_THEME"
RESULT=0
[ "$V_EXIST" = "yes" ] && [ "$V_TITLE" -ge 1 ] && [ "$V_COMPARE" -ge 1 ] && [ "$V_THEME" -ge 1 ] && RESULT=1
check "CA_04" "Story DesignTokens/Compare con selector de tema" "exist=yes title>=1 compare>=1 theme>=1" "$V" "$RESULT" "frontend/src/components/DesignTokens/DesignTokensCompare.stories.tsx"

# ── CA_05: SD config + build:tokens produce CSS + TS ────────────────────
CFG="$FRONTEND/style-dictionary.config.js"
V_CFG=$([ -f "$CFG" ] && echo yes || echo no)
V_TOKENS_CSS=$([ -f "$BASE/generated/tokens.css" ] && echo yes || echo no)
V_THEMES_CSS=0
for t in light dark high-contrast; do
  [ -f "$BASE/generated/themes/$t.css" ] && V_THEMES_CSS=$((V_THEMES_CSS+1))
done
V_THEMES_TS=0
for t in light dark high-contrast; do
  [ -f "$BASE/generated/$t.ts" ] && V_THEMES_TS=$((V_THEMES_TS+1))
done
V_UNDEF=$(grep -c 'undefined' "$BASE/generated/tokens.css" 2>/dev/null | head -1); V_UNDEF=${V_UNDEF:-0}
V="cfg=$V_CFG tokens_css=$V_TOKENS_CSS themes_css=$V_THEMES_CSS themes_ts=$V_THEMES_TS undefined=$V_UNDEF"
RESULT=0
[ "$V_CFG" = "yes" ] && [ "$V_TOKENS_CSS" = "yes" ] && [ "$V_THEMES_CSS" -eq 3 ] && [ "$V_THEMES_TS" -eq 3 ] && [ "$V_UNDEF" -eq 0 ] && RESULT=1
check "CA_05" "SD config + build:tokens produce CSS+TS sin undefined" "cfg=yes tokens_css=yes themes_css=3 themes_ts=3 undefined=0" "$V" "$RESULT" "frontend/style-dictionary.config.js + generated/"

# ── CA_06: Frontend-test-Dev.sh sigue verde ─────────────────────────────
RUNNER_LOG=/tmp/validate-ts023-runner.log
: > "$RUNNER_LOG"
( cd "$FRONTEND" && timeout 300 bash tests/shellTest/Frontend-test-Dev.sh ) > "$RUNNER_LOG" 2>&1
RUNNER_EXIT=$?
V="exit=$RUNNER_EXIT"
RESULT=0
[ "$RUNNER_EXIT" -eq 0 ] && RESULT=1
check "CA_06" "Frontend-test-Dev.sh verde" "exit=0" "$V" "$RESULT" "frontend/tests/shellTest/Frontend-test-Dev.sh" "$(tail -5 "$RUNNER_LOG")"

# ── CA_07: README menciona imported/ + build:tokens ─────────────────────
V_IMP=$(grep -cF 'frontend/src/components/imported' "$README" 2>/dev/null | head -1); V_IMP=${V_IMP:-0}
V_BT=$(grep -cF 'npm run build:tokens' "$README" 2>/dev/null | head -1); V_BT=${V_BT:-0}
V="imported=$V_IMP build_tokens=$V_BT"
RESULT=0
[ "$V_IMP" -ge 1 ] && [ "$V_BT" -ge 1 ] && RESULT=1
check "CA_07" "README menciona imported/ + build:tokens" "imported>=1 build_tokens>=1" "$V" "$RESULT" "README.md §Frontend"

# ── CA_08: agente-frontend menciona imported/ + separación ──────────────
AGENTE="$DOCS/prompts/agente-frontend.md"
V_IMP=$(grep -cF 'frontend/src/components/imported' "$AGENTE" 2>/dev/null | head -1); V_IMP=${V_IMP:-0}
V_SEP=$(grep -cF 'brand-overrides' "$AGENTE" 2>/dev/null | head -1); V_SEP=${V_SEP:-0}
V="imported=$V_IMP brand_overrides=$V_SEP"
RESULT=0
[ "$V_IMP" -ge 1 ] && [ "$V_SEP" -ge 1 ] && RESULT=1
check "CA_08" "agente-frontend menciona imported/ + brand-overrides" "imported>=1 brand_overrides>=1" "$V" "$RESULT" "docs/prompts/agente-frontend.md"

# ── SUMMARY ─────────────────────────────────────────────────────────────
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
if [ "$FAIL" -eq 0 ] && [ "$CONTRA" -eq 0 ]; then
  echo "  ${CLR_GREEN}${CLR_BOLD}🟢 VEREDICTO GLOBAL: APROBÓ${CLR_NC}"
  exit 0
else
  echo "  ${CLR_RED}${CLR_BOLD}🔴 VEREDICTO GLOBAL: NO APROBÓ${CLR_NC}"
  exit 1
fi
