#!/usr/bin/env bash
# ============================================================================
# make-commit-template.sh — Genera y valida una plantilla de commit
# ============================================================================
# Uso:
#   /prog/datos/investment-tracker/docs/scrum/kanban/scripts/make-commit-template.sh \
#     <tipo> <issue> <subject> <body-file> <footer-file> [<output>]
#
# Reglas (docs/prompts/agente-frontend.md §14.9 + README §106):
#   - tipo ∈ feat|fix|docs|refactor|test|chore|style|perf|build|ci|revert
#   - header ≤ 100 chars, sin punto final
#   - body-leading-blank, footer-leading-blank
#   - body-max-line-length: 100
#   - footer-max-line-length: 100
# ============================================================================
set -euo pipefail

if [ $# -lt 5 ]; then
  echo "Uso: $0 <tipo> <issue> <subject> <body-file> <footer-file> [<output>]"
  exit 1
fi

TIPO="$1"
ISSUE="$2"
SUBJECT="$3"
BODY_FILE="$4"
FOOTER_FILE="$5"
OUTPUT="${6:-/tmp/ts${ISSUE}-commit.txt}"

TYPES="feat fix docs refactor test chore style perf build ci revert"
if ! echo "$TYPES" | grep -qw "$TIPO"; then
  echo "❌ Tipo '$TIPO' no permitido. Válidos: $TYPES"
  exit 1
fi

[ -f "$BODY_FILE" ] || { echo "❌ No existe body-file: $BODY_FILE"; exit 1; }
[ -f "$FOOTER_FILE" ] || { echo "❌ No existe footer-file: $FOOTER_FILE"; exit 1; }

# 1. Construir
HEADER="${TIPO}(#${ISSUE}): ${SUBJECT}"
{
  printf '%s\n' "$HEADER"
  printf '\n'
  cat "$BODY_FILE"
  printf '\n'
  cat "$FOOTER_FILE"
} > /tmp/.commit-candidate.txt

# 2. Validar longitudes
echo ""
echo "── Validando longitudes (≤ 100 chars por línea) ──"
if awk 'length > 100 { printf "  ❌ Línea %d (%d chars): %s\n", NR, length, $0; found=1 } END { exit found }' /tmp/.commit-candidate.txt; then
  echo "  ✅ Todas las líneas ≤ 100 chars"
else
  echo "  ❌ Hay líneas > 100. Abortando."
  rm -f /tmp/.commit-candidate.txt
  exit 1
fi

# 3. Validar commitlint
echo ""
echo "── Validando con commitlint ──"
FRONTEND="$(git rev-parse --show-toplevel)/frontend"
[ -d "$FRONTEND" ] || { echo "❌ No se encontró frontend/"; rm -f /tmp/.commit-candidate.txt; exit 1; }

if ( cd "$FRONTEND" && cat /tmp/.commit-candidate.txt | npx commitlint --verbose ); then
  echo "  ✅ commitlint OK"
else
  echo "  ❌ commitlint FALLÓ. Abortando."
  rm -f /tmp/.commit-candidate.txt
  exit 1
fi

# 4. Escribir output
mv /tmp/.commit-candidate.txt "$OUTPUT"
echo ""
echo "✅ Plantilla creada: $OUTPUT"
echo ""
echo "── Contenido ──"
cat "$OUTPUT"
