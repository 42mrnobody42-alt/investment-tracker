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
ISSUE_NUM="${ISSUE_NUM:-XXX}"
TS_CODE="${TS_CODE:-TS-XXX}"

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
