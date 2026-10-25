#!/usr/bin/env bash
# ============================================================================
# VALIDATION-template.sh — Plantilla de shell de validación de criterios
# ============================================================================
# Copiar a /tmp/validate-tsXXX.sh por cada tarea (la instancia NO se comitea).
# Esta plantilla SÍ se comitea como scaffold reutilizable.
#
# Regla de nombres:
#   - Colores: CLR_RED, CLR_GREEN, CLR_YELLOW, CLR_CYAN, CLR_BOLD, CLR_NC
#   - Veredicto por check: RESULT (0 o 1), nunca reutilizar nombres de color
#   - Contadores: PASS, FAIL, CONTRA (inmutables durante el check)
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
DOCS="$REPO/docs"
README="$REPO/README.md"
ISSUE_NUM="XXX"

PASS=0; FAIL=0; CONTRA=0

if [[ -t 1 ]]; then
  CLR_RED=$'\033[0;31m'; CLR_GREEN=$'\033[0;32m'; CLR_YELLOW=$'\033[1;33m'
  CLR_CYAN=$'\033[0;36m'; CLR_BOLD=$'\033[1m'; CLR_NC=$'\033[0m'
else
  CLR_RED=''; CLR_GREEN=''; CLR_YELLOW=''; CLR_CYAN=''; CLR_BOLD=''; CLR_NC=''
fi

check() {
  local num="$1" title="$2" expected="$3" obtained="$4" verdict="$5"
  echo ""
  echo "${CLR_CYAN}${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"
  echo "  CRITERIO $num — $title"
  echo "${CLR_CYAN}════════════════════════════════════════════════════════════════════${CLR_NC}"
  echo "  Esperado : $expected"
  echo "  Obtenido : $obtained"
  case "$verdict" in
    1) echo "  ${CLR_GREEN}Resultado: ✅ APROBÓ${CLR_NC}";           PASS=$((PASS+1)) ;;
    2) echo "  ${CLR_YELLOW}Resultado: ⚠️  CONTRADICCIÓN${CLR_NC}";   CONTRA=$((CONTRA+1)) ;;
    *) echo "  ${CLR_RED}Resultado: ❌ NO APROBÓ${CLR_NC}";           FAIL=$((FAIL+1)) ;;
  esac
}

# ── CRITERIOS ──────────────────────────────────────────────────────────────
# Patrón por cada criterio:
#   V=$(calcular); RESULT=0; [ condición ] && RESULT=1
#   check N "título" "esperado" "$V" "$RESULT"

# ── SUMMARY ────────────────────────────────────────────────────────────────
echo ""
echo "${CLR_BOLD}╔════════════════════════════════════════════════════════════════════╗${CLR_NC}"
echo "${CLR_BOLD}║  RESUMEN GLOBAL — TS-XXX (#NNN)                                   ║${CLR_NC}"
echo "${CLR_BOLD}╚════════════════════════════════════════════════════════════════════╝${CLR_NC}"
echo "  Criterios aprobados      : $PASS"
echo "  Criterios NO aprobados   : $FAIL"
echo "  Criterios contradictorios: $CONTRA"
echo ""
if [ "$FAIL" -eq 0 ] && [ "$CONTRA" -eq 0 ]; then
  echo "  ${CLR_GREEN}${CLR_BOLD}🟢 VEREDICTO GLOBAL: APROBÓ — todos los criterios verdes.${CLR_NC}"
  echo "     Commit autorizado."
  exit 0
else
  echo "  ${CLR_RED}${CLR_BOLD}🔴 VEREDICTO GLOBAL: NO APROBÓ — $FAIL fallido(s), $CONTRA contradictorio(s).${CLR_NC}"
  echo "     Commit bloqueado hasta corregir."
  exit 1
fi
