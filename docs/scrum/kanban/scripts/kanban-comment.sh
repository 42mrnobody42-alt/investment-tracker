#!/usr/bin/env bash
# =========================================================
# kanban-comment.sh — Comenta SHA + cambios en un issue
# Uso: ./kanban-comment.sh <issue-number> <sha> [<template>]
# Template por defecto: /tmp/ts-010-comment.txt
# Placeholders soportados: {SHA}, {STATS}
# El bloque {STATS} se sustituye por `git show --stat <sha>`.
# =========================================================
set -euo pipefail

OWNER="42mrnobody42-alt"
REPO="investment-tracker"

if [ $# -lt 2 ]; then
  echo "Uso: $0 <issue-number> <sha> [<template>]"
  exit 1
fi

ISSUE="$1"
SHA="$2"
TEMPLATE="${3:-/tmp/ts-010-comment.txt}"

if [ ! -f "$TEMPLATE" ]; then
  echo "❌ No existe el template: $TEMPLATE"
  exit 1
fi

# 1. Stats a archivo temporal (evita corte al pegar)
STATS_FILE=$(mktemp)
git show --stat --pretty=format: "$SHA" | sed '/^$/d' > "$STATS_FILE"

# 2. Sustituir {SHA} y {STATS} en el template
BODY_FILE=$(mktemp)
awk -v sha="$SHA" -v statsfile="$STATS_FILE" '
  /\{SHA\}/  { gsub(/\{SHA\}/, sha) }
  /\{STATS\}/ {
    while ((getline line < statsfile) > 0) print line
    close(statsfile)
    next
  }
  { print }
' "$TEMPLATE" > "$BODY_FILE"

# 3. Publicar con --body-file (nunca se corta)
gh issue comment "$ISSUE" --repo "$OWNER/$REPO" --body-file "$BODY_FILE"

rm -f "$STATS_FILE" "$BODY_FILE"
echo "✅ Comentario publicado en #$ISSUE"
