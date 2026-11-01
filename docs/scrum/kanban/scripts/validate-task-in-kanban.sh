#!/usr/bin/env bash
# ============================================================================
# validate-task-in-kanban.sh — Validador genérico de criterios de aceptación
# ============================================================================
# Uso: ./validate-task-in-kanban.sh <issue-number>
#
# Flujo:
#   1. Lee el issue vía gh api → extrae TS-XXX del título.
#   2. Verifica que exista scripts/validators/validate-tsXXX.sh.
#   3. Extrae todos los **CA_##:** del body del issue.
#   4. Extrae todos los check "CA_##" del validator específico.
#   5. Compara cobertura (todos los CA_## del issue deben estar en el validador).
#   6. Ejecuta el validator específico heredando ISSUE_NUM y TS_CODE.
#
# Salida no-cero si falta cobertura o si algún CA_## falla.
# ============================================================================
set -uo pipefail

ISSUE="${1:?Uso: $0 <issue-number>}"
REPO="/prog/datos/investment-tracker"
KANBAN="$REPO/docs/scrum/kanban"
VALIDATORS_DIR="$KANBAN/scripts/validators"

if [[ -t 1 ]]; then
  CR=$'\033[0;31m'; CG=$'\033[0;32m'; CY=$'\033[1;33m'
  CC=$'\033[0;36m'; CB=$'\033[1m'; CN=$'\033[0m'
else
  CR=''; CG=''; CY=''; CC=''; CB=''; CN=''
fi

# ── 1. Fetch issue ──────────────────────────────────────────────────────────
echo ""
echo "${CB}════════════════════════════════════════════════════════════════════${CN}"
echo "  Validando issue #$ISSUE"
echo "${CB}════════════════════════════════════════════════════════════════════${CN}"

TITLE=$(gh api "repos/42mrnobody42-alt/investment-tracker/issues/$ISSUE" --jq '.title' 2>/dev/null)
BODY=$(gh api "repos/42mrnobody42-alt/investment-tracker/issues/$ISSUE" --jq '.body' 2>/dev/null)

if [ -z "$TITLE" ]; then
  echo "${CR}❌ No se pudo leer el issue #$ISSUE${CN}"
  exit 1
fi

echo "  Título: $TITLE"

# ── 2. Extract TS-XXX from title ────────────────────────────────────────────
TS_CODE=$(echo "$TITLE" | grep -oE "TS-[0-9]+" | head -1)
if [ -z "$TS_CODE" ]; then
  echo "${CR}❌ No se encontró TS-XXX en el título del issue #$ISSUE${CN}"
  exit 1
fi

TS_NUM=$(echo "$TS_CODE" | sed 's/TS-0*//')
TS_NUM_PADDED=$(printf '%03d' "$TS_NUM")
VALIDATOR="$VALIDATORS_DIR/validate-ts$TS_NUM_PADDED.sh"

echo "  TS: $TS_CODE"
echo "  Validator esperado: $VALIDATOR"

if [ ! -f "$VALIDATOR" ]; then
  echo ""
  echo "${CR}❌ No existe validador específico:${CN}"
  echo "   $VALIDATOR"
  echo ""
  echo "   Para crear uno nuevo, copiar desde:"
  echo "   $KANBAN/templates/VALIDATION-template.sh"
  echo "   y guardarlo como: $VALIDATOR"
  exit 1
fi

# ── 3. Extract CAs from issue body ──────────────────────────────────────────
CA_ISSUE=$(echo "$BODY" | grep -oE '\*\*CA_[0-9]+:\*\*' | sed 's/\*\*//g; s/://g' | sort -u)
if [ -z "$CA_ISSUE" ]; then
  echo "${CR}❌ El issue no tiene criterios CA_## en el body${CN}"
  exit 1
fi

# ── 4. Extract CAs from validator ───────────────────────────────────────────
CA_VALIDATOR=$(grep -oE 'check "CA_[0-9]+"' "$VALIDATOR" 2>/dev/null | sed 's/check "//; s/"//g' | sort -u)

# ── 5. Coverage check ───────────────────────────────────────────────────────
CA_ISSUE_FILE=$(mktemp)
CA_VAL_FILE=$(mktemp)
echo "$CA_ISSUE" > "$CA_ISSUE_FILE"
[ -n "$CA_VALIDATOR" ] && echo "$CA_VALIDATOR" > "$CA_VAL_FILE" || : > "$CA_VAL_FILE"

MISSING=$(comm -23 "$CA_ISSUE_FILE" "$CA_VAL_FILE" | tr '\n' ' ' | sed 's/ $//')
EXTRA=$(comm -13 "$CA_ISSUE_FILE" "$CA_VAL_FILE" | tr '\n' ' ' | sed 's/ $//')
TOTAL_ISSUE=$(wc -l < "$CA_ISSUE_FILE" | tr -d ' ')
TOTAL_VAL=$(wc -l < "$CA_VAL_FILE" | tr -d ' ')

echo ""
echo "${CB}════════════════════════════════════════════════════════════════════${CN}"
echo "  Cobertura de criterios"
echo "${CB}════════════════════════════════════════════════════════════════════${CN}"
echo "  Issue:     $TOTAL_ISSUE CAs ($CA_ISSUE | tr '\n' ' ' | sed 's/ $//')"
echo "  Validator: $TOTAL_VAL checks"

if [ -n "$MISSING" ]; then
  echo ""
  echo "${CR}❌ FALTAN en el validador: $MISSING${CN}"
  echo "   El validator NO cubre todos los criterios del issue."
  rm -f "$CA_ISSUE_FILE" "$CA_VAL_FILE"
  exit 1
fi

if [ -n "$EXTRA" ]; then
  echo ""
  echo "${CY}⚠️ EXTRA en el validador (no están en el issue): $EXTRA${CN}"
fi

echo ""
echo "  ${CG}✅ Cobertura completa${CN}"

rm -f "$CA_ISSUE_FILE" "$CA_VAL_FILE"

# ── 5.5. Preparar log (truncar + header) ────────────────────────────
LOG_DIR="$REPO/logs/Kanban"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/Validacion-criterios-aceptacion-$TS_CODE.log"
: > "$LOG_FILE"
export LOG_FILE

# Header del log (solo al log, NO a consola)
{
  echo "================================================================"
  echo " Validación $TS_CODE (#$ISSUE) — $TITLE"
  echo " Fecha  : $(date '+%Y-%m-%dT%H:%M:%S')"
  echo " Rama   : $(git -C "$REPO" branch --show-current)"
  echo " Commit : $(git -C "$REPO" rev-parse --short HEAD)"
  echo "================================================================"
  echo ""
} >> "$LOG_FILE"

# ── 6. Run validator (heredando ISSUE_NUM y TS_CODE) ────────────────────────
echo ""
echo "${CB}════════════════════════════════════════════════════════════════════${CN}"
echo "  Ejecutando validator específico"
echo "${CB}════════════════════════════════════════════════════════════════════${CN}"

export ISSUE_NUM="$ISSUE"
export TS_CODE="$TS_CODE"
bash "$VALIDATOR"
EXIT=$?

echo ""
echo "${CB}════════════════════════════════════════════════════════════════════${CN}"
if [ "$EXIT" -eq 0 ]; then
  echo "  ${CG}${CB}🟢 WRAPPER VERDE — issue #$ISSUE ($TS_CODE) cubierto y verde${CN}"
else
  echo "  ${CR}${CB}🔴 WRAPPER ROJO — issue #$ISSUE ($TS_CODE) tiene criterios fallidos${CN}"
fi
echo "${CB}════════════════════════════════════════════════════════════════════${CN}"


# Footer del log (solo al log, NO a consola)
{
  echo ""
  echo "================================================================"
  echo " WRAPPER — $TS_CODE (#$ISSUE) — Exit: $EXIT"
  echo "================================================================"
} >> "$LOG_FILE"

exit "$EXIT"
