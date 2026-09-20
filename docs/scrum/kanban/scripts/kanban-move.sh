#!/usr/bin/env bash
# =========================================================
# kanban-move.sh — Mueve un issue del Project V2 a un estado
# Uso: ./kanban-move.sh <issue-number> <status>
# Alias de status:
#   backlog | ready | progress | review | done
# Nombres exactos en el tablero:
#   Backlog | Ready | In progress | In review | Done
# =========================================================
set -euo pipefail

OWNER="42mrnobody42-alt"
PROJECT=2
CONFIG="/prog/datos/investment-tracker/docs/scrum/kanban/.kanban-config.env"

if [ $# -lt 2 ]; then
  echo "Uso: $0 <issue-number> <status>"
  echo "  status: backlog | ready | progress | review | done"
  exit 1
fi

ISSUE="$1"
STATUS_ARG="$2"

# --- 1. Normalizar argumento al nombre EXACTO de GitHub
case "$(echo "$STATUS_ARG" | tr '[:upper:]' '[:lower:]')" in
  todo|backlog)                    TARGET_NAME="Backlog" ;;
  ready)                           TARGET_NAME="Ready" ;;
  "in progress"|progress|doing)    TARGET_NAME="In progress" ;;
  "in review"|review)              TARGET_NAME="In review" ;;
  done)                            TARGET_NAME="Done" ;;
  *) echo "❌ Estado inválido: $STATUS_ARG"; exit 1 ;;
esac

# --- 2. Cargar/crear config con los IDs estables
if [ ! -f "$CONFIG" ]; then
  PROJECT_ID=$(gh api graphql -f query='
    query($owner: String!) {
      user(login: $owner) { projectV2(number: 2) { id } }
    }' -f owner="$OWNER" --jq '.data.user.projectV2.id')

  STATUS_FIELD_ID=$(gh api graphql -f query='
    query($project: ID!) {
      node(id: $project) {
        ... on ProjectV2 {
          field(name: "Status") { ... on ProjectV2SingleSelectField { id } }
        }
      }
    }' -f project="$PROJECT_ID" --jq '.data.node.field.id')

  printf 'PROJECT_ID=%s\nSTATUS_FIELD_ID=%s\n' "$PROJECT_ID" "$STATUS_FIELD_ID" > "$CONFIG"
fi

# shellcheck disable=SC1090
source "$CONFIG"

# --- 3. Obtener option-id dinámicamente por nombre
OPTION_ID=$(gh api graphql -f query='
  query($project: ID!) {
    node(id: $project) {
      ... on ProjectV2 {
        field(name: "Status") {
          ... on ProjectV2SingleSelectField {
            options { id name }
          }
        }
      }
    }
  }' -f project="$PROJECT_ID" \
  --jq ".data.node.field.options[] | select(.name == \"$TARGET_NAME\") | .id")

if [ -z "$OPTION_ID" ]; then
  echo "❌ No existe la opción '$TARGET_NAME' en el campo Status."
  echo "   Opciones disponibles:"
  gh api graphql -f query='
    query($project: ID!) {
      node(id: $project) {
        ... on ProjectV2 {
          field(name: "Status") {
            ... on ProjectV2SingleSelectField { options { name } }
          }
        }
      }
    }' -f project="$PROJECT_ID" --jq '.data.node.field.options[].name' | sed 's/^/     - /'
  exit 1
fi

# --- 4. Obtener item-id del issue
ITEM_ID=$(gh project item-list "$PROJECT" --owner "$OWNER" --format json --limit 500 \
  --jq ".items[] | select(.content.number == $ISSUE) | .id" 2>/dev/null | head -1)

if [ -z "$ITEM_ID" ]; then
  echo "❌ Issue #$ISSUE no está en el Project #$PROJECT"
  exit 1
fi

# --- 5. Mover
gh project item-edit \
  --id "$ITEM_ID" \
  --field-id "$STATUS_FIELD_ID" \
  --project-id "$PROJECT_ID" \
  --single-select-option-id "$OPTION_ID" >/dev/null

echo "✅ #$ISSUE → $TARGET_NAME"
