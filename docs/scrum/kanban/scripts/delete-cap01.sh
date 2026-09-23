#!/usr/bin/env bash
# =========================================================
# delete-cap01.sh — Elimina CAP-01 + todas sus FT/US/TS
# =========================================================
set -euo pipefail

REPO="42mrnobody42-alt/investment-tracker"
KANBAN_DIR="/prog/datos/investment-tracker/docs/scrum/kanban"

echo "══════════════════════════════════════════════════════"
echo "  Eliminando CAP-01 y toda su jerarquía en $REPO"
echo "══════════════════════════════════════════════════════"

# --- 1) Recolectar IDs --------------------------------------------------
IDS=""

if [ -f "$KANBAN_DIR/kanban-ids.env" ]; then
  echo "==> Leyendo IDs desde kanban-ids.env..."
  # shellcheck disable=SC1090
  source "$KANBAN_DIR/kanban-ids.env"
  for var in $(compgen -v | grep -E '^(CAP|FT[0-9]+|US[0-9]+|TS[0-9]+)$'); do
    val="${!var}"
    [ -n "$val" ] && IDS="$IDS $val"
  done
fi

# Fallback: buscar por labels si kanban-ids.env no existe o está incompleto
echo "==> Buscando issues por labels (capability/feature/user-story/task)..."
LABEL_IDS=$(gh issue list --repo "$REPO" --state all --limit 1000 \
  --json number,labels \
  --jq '.[] | select(.labels | map(.name) | any(. == "capability" or . == "feature" or . == "user-story" or . == "task")) | .number' \
  2>/dev/null || echo "")

for n in $LABEL_IDS; do
  case " $IDS " in
    *" $n "*) ;;                # ya está
    *) IDS="$IDS $n" ;;
  esac
done

# Filtrar vacíos y duplicados
IDS=$(echo "$IDS" | tr ' ' '\n' | grep -E '^[0-9]+$' | sort -un | tr '\n' ' ')

TOTAL=$(echo "$IDS" | wc -w)
echo "==> Issues detectados: $TOTAL"
echo "    $IDS"
echo ""

if [ "$TOTAL" -eq 0 ]; then
  echo "No hay issues para eliminar. Nada que hacer."
  exit 0
fi

# --- 2) Confirmación ---------------------------------------------------
read -r -p "¿Eliminar los $TOTAL issues? (escribe SI para confirmar): " CONFIRM
if [ "$CONFIRM" != "SI" ]; then
  echo "Cancelado por el usuario."
  exit 1
fi

# --- 3) Eliminar -------------------------------------------------------
DELETED=0
FAILED=0
FAILED_LIST=""

for iss in $IDS; do
  if gh issue delete "$iss" --repo "$REPO" --yes >/dev/null 2>&1; then
    echo "   ✓ #$iss eliminado"
    DELETED=$((DELETED + 1))
  else
    echo "   ⚠ #$iss no se pudo eliminar (¿permisos? ¿ya no existe?)"
    FAILED=$((FAILED + 1))
    FAILED_LIST="$FAILED_LIST $iss"
  fi
done

# --- 4) Limpiar kanban-ids.env ----------------------------------------
if [ -f "$KANBAN_DIR/kanban-ids.env" ]; then
  mv "$KANBAN_DIR/kanban-ids.env" "$KANBAN_DIR/kanban-ids.env.bak.$(date +%s)"
  echo "   ✓ kanban-ids.env respaldado"
fi

echo ""
echo "══════════════════════════════════════════════════════"
echo "  Eliminados: $DELETED | Fallidos: $FAILED"
if [ "$FAILED" -gt 0 ]; then
  echo "  No eliminados:$FAILED_LIST"
fi
echo "══════════════════════════════════════════════════════"

[ "$FAILED" -eq 0 ] || exit 1