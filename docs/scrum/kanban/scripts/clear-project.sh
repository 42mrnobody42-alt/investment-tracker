#!/usr/bin/env bash
# =========================================================
# clear-project.sh — Elimina todos los items del Project #2
# (no elimina los issues, solo los desvincula del tablero)
# Pagina para soportar >100 items.
# =========================================================
set -euo pipefail

OWNER="42mrnobody42-alt"
PROJECT_NUMBER=2

PROJECT_ID=$(gh api graphql -f query='
  query($owner: String!, $number: Int!) {
    user(login: $owner) { projectV2(number: $number) { id } }
  }' -f owner="$OWNER" -F number="$PROJECT_NUMBER" \
  --jq '.data.user.projectV2.id')

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "null" ]; then
  echo "✗ No se pudo obtener el ID del Project #$PROJECT_NUMBER"
  exit 1
fi
echo "Project ID: $PROJECT_ID"

# Recolectar TODOS los item IDs paginando
echo "Recolectando item IDs (paginado)..."
declare -a ALL_ITEM_IDS=()
CURSOR=""
PAGE=0

while true; do
  if [ -z "$CURSOR" ]; then
    RES=$(gh api graphql -f query='
      query($projectId: ID!) {
        node(id: $projectId) {
          ... on ProjectV2 {
            items(first: 100) {
              pageInfo { hasNextPage endCursor }
              nodes { id }
            }
          }
        }
      }' -f projectId="$PROJECT_ID")
  else
    RES=$(gh api graphql -f query='
      query($projectId: ID!, $cursor: String!) {
        node(id: $projectId) {
          ... on ProjectV2 {
            items(first: 100, after: $cursor) {
              pageInfo { hasNextPage endCursor }
              nodes { id }
            }
          }
        }
      }' -f projectId="$PROJECT_ID" -f cursor="$CURSOR")
  fi

  while IFS= read -r id; do
    [ -n "$id" ] && ALL_ITEM_IDS+=("$id")
  done < <(echo "$RES" | jq -r '.data.node.items.nodes[].id')

  HAS_NEXT=$(echo "$RES" | jq -r '.data.node.items.pageInfo.hasNextPage')
  PAGE=$((PAGE + 1))
  printf "."
  if [ "$HAS_NEXT" = "true" ]; then
    CURSOR=$(echo "$RES" | jq -r '.data.node.items.pageInfo.endCursor')
  else
    break
  fi
done
echo ""

TOTAL=${#ALL_ITEM_IDS[@]}
echo "Items a eliminar: $TOTAL"
echo ""

COUNT=0
FAILED=0
for ITEM_ID in "${ALL_ITEM_IDS[@]}"; do
  if gh api graphql -f query='
    mutation($projectId: ID!, $itemId: ID!) {
      deleteProjectV2Item(input: {projectId: $projectId, itemId: $itemId}) {
        deletedItemId
      }
    }' -f projectId="$PROJECT_ID" -f itemId="$ITEM_ID" >/dev/null 2>&1; then
    COUNT=$((COUNT + 1))
    printf "."
  else
    FAILED=$((FAILED + 1))
    printf "x"
  fi
done
echo ""
echo ""
echo "✓ Eliminados: $COUNT | ✗ Fallidos: $FAILED"

# Verificación
REMAINING=$(gh api graphql -f query='
  query($projectId: ID!) {
    node(id: $projectId) {
      ... on ProjectV2 { items(first: 1) { totalCount } }
    }
  }' -f projectId="$PROJECT_ID" --jq '.data.node.items.totalCount')
echo "Items restantes en el Project: $REMAINING"

[ "$FAILED" -eq 0 ] || exit 1