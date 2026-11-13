#!/usr/bin/env bash
# ============================================================================
# VALIDATION-template.sh — Plantilla de shell de validación de criterios
# ============================================================================
# Copiar a docs/scrum/kanban/scripts/validators/validate-tsXXX.sh (SÍ versionado).
#
# REGLA: cada criterio de aceptación del issue DEBE tener un código único
# **CA_##** en el body (`- [ ] **CA_01:** ...`). Ese MISMO código se usa como
# primer argumento de check().
#
# Regla de nombres (para evitar colisión con colores):
#   - Colores: CLR_RED, CLR_GREEN, CLR_YELLOW, CLR_CYAN, CLR_BOLD, CLR_NC
#   - Veredicto por check: RESULT (0=no, 1=sí, 2=contradicción)
#   - Contadores: PASS, FAIL, CONTRA
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
DOCS="$REPO/docs"
README="$REPO/README.md"
ISSUE_NUM="${ISSUE_NUM:-629}"
TS_CODE="${TS_CODE:-TS-024}"

# Log (heredado del wrapper o creado si se ejecuta directo)
LOG_FILE="${LOG_FILE:-}"
if [ -z "$LOG_FILE" ]; then
  LOG_DIR="$REPO/logs/Kanban"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/Validacion-criterios-aceptacion-${TS_CODE}.log"
  : > "$LOG_FILE"
  if [ -t 1 ]; then
    exec > >(tee -a "$LOG_FILE") 2>&1
  else
    exec >> "$LOG_FILE" 2>&1
  fi
fi

PASS=0; FAIL=0; CONTRA=0

if [[ -t 1 ]]; then
  CLR_RED=$'\033[0;31m'; CLR_GREEN=$'\033[0;32m'; CLR_YELLOW=$'\033[1;33m'
  CLR_CYAN=$'\033[0;36m'; CLR_BOLD=$'\033[1m'; CLR_NC=$'\033[0m'
else
  CLR_RED=''; CLR_GREEN=''; CLR_YELLOW=''; CLR_CYAN=''; CLR_BOLD=''; CLR_NC=''
fi

# check <CA_##> <título> <esperado> <obtenido> <verdict> [<dónde verificar>] [<debug>]
#
#   En DEBUG, incluir SIEMPRE el comando ejecutado (\$ ...) y su salida real
#   para que el usuario pueda reproducirlo o entender el valor obtenido,
#   tanto en éxito como en fallo (máx 30 líneas).
#   verdict: 1=aprobó, 2=contradicción, 0=no aprobó
#   ref     (opcional): dónde el usuario puede inspeccionar el resultado
#   debug   (opcional): salida real del comando ejecutado (máx 30 líneas, ideal 1-3)
check() {
  local ca_code="$1" title="$2" expected="$3" obtained="$4" verdict="$5" ref="${6:-}" debug="${7:-}"
  echo ""
  echo "${CLR_CYAN}${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"
  echo "  CRITERIO $ca_code — $title"
  echo "${CLR_CYAN}════════════════════════════════════════════════════════════════════${CLR_NC}"
  echo "  Esperado : $expected"
  echo "  Obtenido : $obtained"
  if [ -n "$ref" ]; then
    echo "  Dónde verificar : $ref"
  fi
  if [ -n "$debug" ]; then
    echo "  Debug :"
    echo "$debug" | head -30 | sed 's/^/    /'
  fi
  case "$verdict" in
    1) echo "  ${CLR_GREEN}Resultado: ✅ APROBÓ${CLR_NC}";           PASS=$((PASS+1)) ;;
    2) echo "  ${CLR_YELLOW}Resultado: ⚠️  CONTRADICCIÓN${CLR_NC}";   CONTRA=$((CONTRA+1)) ;;
    *) echo "  ${CLR_RED}Resultado: ❌ NO APROBÓ${CLR_NC}";           FAIL=$((FAIL+1)) ;;
  esac

  # Append compacto al log (máx 30 líneas por check)
  if [ -n "$LOG_FILE" ]; then
    {
      echo "--------- $ca_code — $title ---------"
      echo "Esperado: $expected"
      echo "Obtenido: $obtained"
      if [ -n "$ref" ]; then echo "Dónde verificar: $ref"; fi
      if [ -n "$debug" ]; then
        echo "Debug (salida real):"
        echo "$debug" | head -30 | sed 's/^/  /'
      fi
      case "$verdict" in
        1) echo "Resultado: ✅ APROBÓ" ;;
        2) echo "Resultado: ⚠️  CONTRADICCIÓN" ;;
        *) echo "Resultado: ❌ NO APROBÓ" ;;
      esac
      echo ""
    } >> "$LOG_FILE"
  fi
}

# ── CRITERIOS ──────────────────────────────────────────────────────────────

# ── CA_01: 5 CSS branding + 3 themes, sin nombres viejos ────────────────
BRANDING="$FRONTEND/src/styles/branding"
V_COLORS=$([ -f "$BRANDING/colors.css" ] && echo yes || echo no)
V_TYPO=$([ -f "$BRANDING/typography.css" ] && echo yes || echo no)
V_LAYOUT=$([ -f "$BRANDING/layout.css" ] && echo yes || echo no)
V_COMP=$([ -f "$BRANDING/components.css" ] && echo yes || echo no)
V_MOTION=$([ -f "$BRANDING/motion.css" ] && echo yes || echo no)
V_THEMES=0
for t in light dark high-contrast; do
  [ -f "$BRANDING/themes/$t.css" ] && V_THEMES=$((V_THEMES+1))
done
V_OLD=$(grep -rcE '\-\-(color-primary[^-]|btn-[a-z]|z-(base|dropdown|sticky|overlay|modal|popover|tooltip|toast)|duration-[a-z]|ease-[a-z]|stagger-[a-z])' "$BRANDING"/*.css "$BRANDING"/themes/*.css 2>/dev/null | grep -v ':0' | wc -l | tr -d ' ')
V="colors=$V_COLORS typo=$V_TYPO layout=$V_LAYOUT comp=$V_COMP motion=$V_MOTION themes=$V_THEMES old=$V_OLD"
RESULT=0
[ "$V_COLORS" = "yes" ] && [ "$V_TYPO" = "yes" ] && [ "$V_LAYOUT" = "yes" ] && [ "$V_COMP" = "yes" ] && [ "$V_MOTION" = "yes" ] && [ "$V_THEMES" -eq 3 ] && [ "$V_OLD" -eq 0 ] && RESULT=1
check "CA_01" "5 CSS + 3 themes sin nombres viejos" "colors=yes typo=yes layout=yes comp=yes motion=yes themes=3 old=0" "$V" "$RESULT" "frontend/src/styles/branding/"

# ── CA_02: tokens.ts autogenerado ────────────────────────────────────────
TOKENS_TS="$FRONTEND/src/shared/types/tokens.ts"
V_EXIST=$([ -f "$TOKENS_TS" ] && echo yes || echo no)
V_COUNT=$(grep -cE "^\s+\| '--" "$TOKENS_TS" 2>/dev/null | head -1); V_COUNT=${V_COUNT:-0}
V_UNION=$(grep -c 'export type TokenName' "$TOKENS_TS" 2>/dev/null | head -1); V_UNION=${V_UNION:-0}
V="exist=$V_EXIST count=$V_COUNT union=$V_UNION"
RESULT=0
[ "$V_EXIST" = "yes" ] && [ "$V_COUNT" -ge 100 ] && [ "$V_UNION" -ge 1 ] && RESULT=1
check "CA_02" "tokens.ts autogenerado con union TokenName" "exist=yes count>=100 union>=1" "$V" "$RESULT" "frontend/src/shared/types/tokens.ts"

# ── CA_03: ThemeProvider con localStorage ────────────────────────────────
TP="$FRONTEND/src/app/providers/ThemeProvider.tsx"
V_EXIST=$([ -f "$TP" ] && echo yes || echo no)
V_LS=$(grep -cF 'localStorage' "$TP" 2>/dev/null | head -1); V_LS=${V_LS:-0}
V_STORAGE=$(grep -cF 'STORAGE_KEY' "$TP" 2>/dev/null | head -1); V_STORAGE=${V_STORAGE:-0}
V="exist=$V_EXIST localStorage=$V_LS storage_key=$V_STORAGE"
RESULT=0
[ "$V_EXIST" = "yes" ] && [ "$V_LS" -ge 1 ] && [ "$V_STORAGE" -ge 1 ] && RESULT=1
check "CA_03" "ThemeProvider con localStorage" "exist=yes localStorage>=1 storage_key>=1" "$V" "$RESULT" "frontend/src/app/providers/ThemeProvider.tsx"

# ── CA_04: prefers-color-scheme ─────────────────────────────────────────
V_PCS=$(grep -cF 'prefers-color-scheme' "$TP" 2>/dev/null | head -1); V_PCS=${V_PCS:-0}
V="prefers-color-scheme=$V_PCS"
RESULT=0
[ "$V_PCS" -ge 1 ] && RESULT=1
check "CA_04" "ThemeProvider respeta prefers-color-scheme" "pcs>=1" "$V" "$RESULT" "frontend/src/app/providers/ThemeProvider.tsx"

# ── CA_05: DesignTokens/Overview runtime + Compare ─────────────────────
DT="$FRONTEND/src/components/DesignTokens/DesignTokens.tsx"
DC_STORY="$FRONTEND/src/components/DesignTokens/DesignTokensCompare.stories.tsx"
V_GCS=$(grep -cF 'getComputedStyle' "$DT" 2>/dev/null | head -1); V_GCS=${V_GCS:-0}
V_COMPARE=$([ -f "$DC_STORY" ] && echo yes || echo no)
V_THEME=$(grep -cF 'theme' "$DC_STORY" 2>/dev/null | head -1); V_THEME=${V_THEME:-0}
V="getComputedStyle=$V_GCS compare_story=$V_COMPARE theme=$V_THEME"
RESULT=0
[ "$V_GCS" -ge 1 ] && [ "$V_COMPARE" = "yes" ] && [ "$V_THEME" -ge 1 ] && RESULT=1
check "CA_05" "DesignTokens/Overview runtime + Compare" "gcs>=1 compare_story=yes theme>=1" "$V" "$RESULT" "frontend/src/components/DesignTokens/"

# ── CA_06: tsc + runner ────────────────────────────────────────────────
RUNNER_LOG=/tmp/validate-ts024-runner.log
: > "$RUNNER_LOG"
( cd "$FRONTEND" && timeout 300 bash tests/shellTest/Frontend-test-Dev.sh ) > "$RUNNER_LOG" 2>&1
RUNNER_EXIT=$?
V="exit=$RUNNER_EXIT"
RESULT=0
[ "$RUNNER_EXIT" -eq 0 ] && RESULT=1
check "CA_06" "Frontend-test-Dev.sh verde" "exit=0" "$V" "$RESULT" "frontend/tests/shellTest/Frontend-test-Dev.sh" "$(tail -5 "$RUNNER_LOG")"

# ── CA_07: README menciona tokens.ts + ThemeProvider + colors.css ──────
V_TOK=$(grep -cF 'tokens.ts' "$README" 2>/dev/null | head -1); V_TOK=${V_TOK:-0}
V_TP=$(grep -cF 'ThemeProvider' "$README" 2>/dev/null | head -1); V_TP=${V_TP:-0}
V_BRAND=$(grep -cF 'colors.css' "$README" 2>/dev/null | head -1); V_BRAND=${V_BRAND:-0}
V="tokens=$V_TOK themeprovider=$V_TP colors=$V_BRAND"
RESULT=0
[ "$V_TOK" -ge 1 ] && [ "$V_TP" -ge 1 ] && [ "$V_BRAND" -ge 1 ] && RESULT=1
check "CA_07" "README menciona tokens.ts + ThemeProvider + colors.css" "tokens>=1 themeprovider>=1 colors>=1" "$V" "$RESULT" "README.md §Frontend"

# ── CA_08: agente-frontend menciona tokens.ts + ThemeProvider + brand-overrides
AGENTE="$DOCS/prompts/agente-frontend.md"
V_TOK=$(grep -cF 'tokens.ts' "$AGENTE" 2>/dev/null | head -1); V_TOK=${V_TOK:-0}
V_TP=$(grep -cF 'ThemeProvider' "$AGENTE" 2>/dev/null | head -1); V_TP=${V_TP:-0}
V_DTCG=$(grep -cF 'brand-overrides' "$AGENTE" 2>/dev/null | head -1); V_DTCG=${V_DTCG:-0}
V="tokens=$V_TOK themeprovider=$V_TP brand_overrides=$V_DTCG"
RESULT=0
[ "$V_TOK" -ge 1 ] && [ "$V_TP" -ge 1 ] && [ "$V_DTCG" -ge 1 ] && RESULT=1
check "CA_08" "agente-frontend menciona tokens.ts + ThemeProvider + brand-overrides" "tokens>=1 themeprovider>=1 brand_overrides>=1" "$V" "$RESULT" "docs/prompts/agente-frontend.md"
# Un check() por cada CA_## del issue. Patrón:
#   V=$(calcular); RESULT=0; [ condición ] && RESULT=1
#   check "CA_01" "título idéntico al del issue" "esperado" "$V" "$RESULT" "ruta/donde/verificar"

# ── SUMMARY ────────────────────────────────────────────────────────────────
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
# SUMMARY → log
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
