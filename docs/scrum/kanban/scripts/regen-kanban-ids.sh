#!/usr/bin/env bash
# =========================================================
# regen-kanban-ids.sh
# Regenera kanban-ids.env leyendo los issues del repo por REST.
# =========================================================
set -euo pipefail

REPO="42mrnobody42-alt/investment-tracker"
OUT="/prog/datos/investment-tracker/docs/scrum/kanban/kanban-ids.env"

echo "Obteniendo issues por label (con paginación)..."
TMP=$(mktemp)

for label in capability feature user-story task; do
  gh api --paginate "repos/$REPO/issues?labels=$label&state=all&per_page=100" \
    --jq '.[] | "\(.number)|\(.title)"' >> "$TMP"
done

# Ordenar numéricamente y quitar duplicados
sort -t'|' -k1 -n -u "$TMP" > "${TMP}.sorted"

TOTAL=$(wc -l < "${TMP}.sorted")
echo "Issues únicos encontrados: $TOTAL"
echo ""

# Mapear títulos a variables
declare -A IDS
while IFS='|' read -r num title; do
  if   [[ "$title" =~ ^CAP-([0-9]+) ]]; then
    IDS["CAP"]="$num"
  elif [[ "$title" =~ ^FT-([0-9]+) ]]; then
    N=$((10#${BASH_REMATCH[1]}))          # <-- fuerza base 10
    IDS["FT_$(printf '%03d' "$N")"]="$num"
  elif [[ "$title" =~ ^US-([0-9]+) ]]; then
    N=$((10#${BASH_REMATCH[1]}))
    IDS["US_$(printf '%03d' "$N")"]="$num"
  elif [[ "$title" =~ ^TS-([0-9]+) ]]; then
    N=$((10#${BASH_REMATCH[1]}))
    IDS["TS_$(printf '%03d' "$N")"]="$num"
  fi
done < "${TMP}.sorted"

# Escribir el archivo en orden
{
  echo "CAP=${IDS[CAP]:-}"
  for i in $(seq -f '%03g' 1 9);   do echo "FT_${i}=${IDS[FT_${i}]:-}"; done
  for i in $(seq -f '%03g' 1 41);  do echo "US_${i}=${IDS[US_${i}]:-}"; done
  for i in $(seq -f '%03g' 1 141); do echo "TS_${i}=${IDS[TS_${i}]:-}"; done
} > "$OUT"

echo "✓ Generado: $OUT"
echo "Variables escritas: $(wc -l < "$OUT")"

# Mostrar resumen
echo ""
echo "Resumen:"
grep -c "^FT_" "$OUT" | xargs echo "  FT encontradas:"
grep -c "^US_" "$OUT" | xargs echo "  US encontradas:"
grep -c "^TS_" "$OUT" | xargs echo "  TS encontradas:"
grep -c "=$" "$OUT" | xargs echo "  Variables vacías:"

rm -f "$TMP" "${TMP}.sorted"