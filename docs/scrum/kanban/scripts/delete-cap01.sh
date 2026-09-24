#!/usr/bin/env bash
# =========================================================
# delete-cap01.sh — Elimina CAP-01 + todas sus FT/US/TS
# Formato de kanban-ids.env esperado:
#   CAP=363
#   FT_001=364
#   US_001=373
#   TS_001=414
#
# Todo por REST (no consume GraphQL).
# Idempotente: funciona sin kanban-ids.env y sin issues.
# =========================================================
set -euo pipefail

REPO="42mrnobody42-alt/investment-tracker"
KANBAN_DIR="/prog/datos/investment-tracker/docs/scrum/kanban"

echo "══════════════════════════════════════════════════════"
echo "  Eliminando CAP-01 y toda su jerarquía en $REPO"
echo "══════════════════════════════════════════════════════"

IDS=""

# --- 1) Leer IDs del env (si existe) ----------------------------------
if [ -f "$KANBAN_DIR/kanban-ids.env" ]; then
  echo "==> Leyendo IDs desde kanban-ids.env..."
  # shellcheck disable=SC1090
  source "$KANBAN_DIR/kanban-ids.env"
  for var in $(compgen -v | grep -E '^(CAP|FT_[0-9]+|US_[0-9]+|TS_[0-9]+)$' || true); do
    val="${!var}"
    [ -n "$val" ] && IDS="$IDS $val"
  done
fi

# --- 2) Fallback: buscar por labels vía REST --------------------------
echo "==> Buscando issues por labels (REST)..."
for label in capability feature user-story task; do
  LABEL_IDS=$(gh api --paginate \
    "repos/$REPO/issues?labels=$label&state=all&per_page=100" \
    --jq '.[].number' 2>/dev/null || echo "")
  for n in $LABEL_IDS; do
    case " $IDS " in
      *" $n "*) ;;
      *) IDS="$IDS $n" ;;
    esac
  done
done

# --- 3) Normalizar IDs (robusto ante vacío + pipefail) ----------------
# Cada pipe con '|| true' para no morir si grep no encuentra nada.
IDS=$(echo "$IDS" | tr ' ' '\n' | grep -E '^[0-9]+$' || true)
IDS=$(echo "$IDS" | sort -un | tr '\n' ' ' || true)
# Trim
IDS=$(echo "$IDS" | xargs || true)

TOTAL=0
[ -n "$IDS" ] && TOTAL=$(echo "$IDS" | wc -w)

echo "==> Issues detectados: $TOTAL"
[ "$TOTAL" -gt 0 ] && echo "    $IDS"
echo ""

if [ "$TOTAL" -eq 0 ]; then
  echo "No hay issues para eliminar. Nada que hacer."
  exit 0
fi

# --- 4) Confirmación --------------------------------------------------
read -r -p "¿Eliminar los $TOTAL issues? (escribe SI para confirmar): " CONFIRM
if [ "$CONFIRM" != "SI" ]; then
  echo "Cancelado por el usuario."
  exit 1
fi

# --- 5) Cerrar antes de eliminar (sub-issues bloquean delete) ---------
echo "==> Cerrando issues..."
for iss in $IDS; do
  gh api -X PATCH "repos/$REPO/issues/$iss" -f state=closed >/dev/null 2>&1 || true
done

# --- 6) Eliminar (REST + fallback gh issue delete) --------------------
echo "==> Eliminando issues..."
DELETED=0
FAILED=0
FAILED_LIST=""

for iss in $IDS; do
  # Intento 1: REST DELETE (no consume GraphQL)
  if gh api -X DELETE "repos/$REPO/issues/$iss" >/dev/null 2>&1; then
    printf "."
    DELETED=$((DELETED + 1))
    continue
  fi
  # Intento 2: gh issue delete
  if gh issue delete "$iss" --repo "$REPO" --yes >/dev/null 2>&1; then
    printf "."
    DELETED=$((DELETED + 1))
    continue
  fi
  printf "x"
  FAILED=$((FAILED + 1))
  FAILED_LIST="$FAILED_LIST $iss"
done
echo ""
echo ""

# --- 7) Respaldar kanban-ids.env (si aún existe) ----------------------
if [ -f "$KANBAN_DIR/kanban-ids.env" ]; then
  mv "$KANBAN_DIR/kanban-ids.env" "$KANBAN_DIR/kanban-ids.env.bak.$(date +%s)"
  echo "   ✓ kanban-ids.env respaldado"
fi

# --- 8) Resumen -------------------------------------------------------
echo ""
echo "══════════════════════════════════════════════════════"
echo "  Eliminados: $DELETED | Fallidos: $FAILED"
if [ "$FAILED" -gt 0 ]; then
  echo "  No eliminados:$FAILED_LIST"
fi
echo "══════════════════════════════════════════════════════"

[ "$FAILED" -eq 0 ] || exit 1