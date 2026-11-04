#!/usr/bin/env bash
# ============================================================================
# PLANTILLA: agregar-diagrama-mermaid-en-documento.sh
# ============================================================================
# Inserta un bloque Mermaid bien formado en un documento .md,
# REEMPLAZANDO una etiqueta de marcador (o insertando en una línea).
#
# ── PROCEDIMIENTO OBLIGATORIO (seguir siempre en este orden) ──
#
#   1. Copiar esta plantilla a /tmp/<nombre>.sh
#   2. Rellenar las variables de CONFIGURACIÓN (ARCHIVO, ETIQUETA|LINEA, TIPO, CONTENIDO)
#   3. Verificar que la etiqueta esté en el archivo, sola (sin duplicados):
#        grep -nF "{tu etiqueta}" "$ARCHIVO"
#      - 0 ocurrencias → abortar con error (etiqueta no encontrada)
#      - 1 ocurrencia  → OK, insertar en esa línea
#      - 2+ ocurrencias → abortar y pedir --linea N como override
#   4. Ejecutar el shell temporal
#   5. Verificar el resultado visualmente (diff o cat)
#   6. Borrar el shell temporal antes del commit
#
# ── USO ──
#
#   A) Por etiqueta (recomendado):
#      ARCHIVO="ruta.md"
#      ETIQUETA="{pon aqui tu diagrama}"
#      TIPO="sequence"
#      CONTENIDO="/tmp/bloque.md"
#
#   B) Por línea (override cuando hay ambigüedad):
#      ARCHIVO="ruta.md"
#      LINEA=40
#      TIPO="sequence"
#      CONTENIDO="/tmp/bloque.md"
#
#   C) CLI (alternativa):
#      ./agregar-diagrama-mermaid-en-documento.sh \
#        --archivo ruta.md --etiqueta "{...}" --tipo sequence --contenido /tmp/b.md
#      ./agregar-diagrama-mermaid-en-documento.sh \
#        --archivo ruta.md --linea 40 --tipo flowchart --contenido /tmp/b.md
#
# ── COMPORTAMIENTO ──
#
#   - Si encuentra ETIQUETA exactamente 1 vez → reemplaza esa línea por el bloque ```mermaid
#   - Si encuentra ETIQUETA 0 veces → error: "etiqueta no encontrada en <archivo>"
#   - Si encuentra ETIQUETA 2+ veces → error: "etiqueta ambigua (N ocurrencias en líneas X, Y, Z). Usá --linea N"
#   - Si usa LINEA → inserta ANTES de esa línea (idempotente: si ya hay ```mermaid, no inserta)
#   - Fix estático en flowchart: envuelve en comillas los labels con {} * / espacios
#   - Valida que no queden {} sin comillas en flowchart
#   - Crea backup temporal y lo borra al terminar
#   - NO toca el archivo si la validación falla
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"

# ── CONFIGURACIÓN (rellenar antes de ejecutar) ─────────────────────────────
ARCHIVO=""
ETIQUETA=""
LINEA=""
TIPO=""
CONTENIDO=""
# ──────────────────────────────────────────────────────────────────────────

# CLI: sobreescribe las variables si se pasan por args
while [ $# -gt 0 ]; do
  case "$1" in
    --archivo) ARCHIVO="$2"; shift 2 ;;
    --etiqueta) ETIQUETA="$2"; shift 2 ;;
    --linea) LINEA="$2"; shift 2 ;;
    --tipo) TIPO="$2"; shift 2 ;;
    --contenido) CONTENIDO="$2"; shift 2 ;;
    *) echo "❌ Argumento desconocido: $1"; exit 1 ;;
  esac
done

# ── Validaciones básicas ────────────────────────────────────────────────────
[ -n "$ARCHIVO" ] || { echo "❌ Falta ARCHIVO"; exit 1; }
[ -n "$TIPO" ] || { echo "❌ Falta TIPO"; exit 1; }
[ -n "$CONTENIDO" ] || { echo "❌ Falta CONTENIDO"; exit 1; }
[ -n "$ETIQUETA" ] || [ -n "$LINEA" ] || { echo "❌ Falta ETIQUETA (o LINEA)"; exit 1; }
[ -f "$REPO/$ARCHIVO" ] || { echo "❌ No existe: $REPO/$ARCHIVO"; exit 1; }
[ -f "$CONTENIDO" ] || { echo "❌ No existe: $CONTENIDO"; exit 1; }
case "$TIPO" in sequence|flowchart) ;; *) echo "❌ TIPO inválido: $TIPO"; exit 1 ;; esac

ARCHIVO_FULL="$REPO/$ARCHIVO"

# ── Resolver línea a insertar (o abortar por error de usuario) ────────────
LINEA_FINAL=""

if [ -n "$ETIQUETA" ]; then
  # Buscar la etiqueta en el archivo
  MATCHES=$(grep -nF "$ETIQUETA" "$ARCHIVO_FULL" 2>/dev/null | cut -d: -f1 || true)
  N_MATCHES=$(printf '%s\n' "$MATCHES" | grep -c '^[0-9]' || true)
  N_MATCHES=${N_MATCHES:-0}

  if [ "$N_MATCHES" -eq 0 ]; then
    echo "❌ Etiqueta no encontrada en el archivo:"
    echo "   etiqueta : $ETIQUETA"
    echo "   archivo  : $ARCHIVO_FULL"
    exit 1
  elif [ "$N_MATCHES" -eq 1 ]; then
    LINEA_FINAL="$MATCHES"
    echo "✅ Etiqueta encontrada en línea $LINEA_FINAL"
  else
    echo "❌ Etiqueta ambigua: $N_MATCHES ocurrencias."
    echo "   etiqueta : $ETIQUETA"
    echo "   archivo  : $ARCHIVO_FULL"
    echo "   líneas   : $(printf '%s' "$MATCHES" | tr '\n' ' ')"
    echo ""
    echo "   Especificá la línea exacta con: --linea <N>"
    exit 1
  fi
fi

# Si vino --linea (override), se usa esa
if [ -n "$LINEA" ]; then
  LINEA_FINAL="$LINEA"
  echo "✅ Usando línea $LINEA_FINAL (override)"
fi

# Validar que la línea exista
TOTAL_LINEAS=$(wc -l < "$ARCHIVO_FULL" | tr -d ' ')
if [ "$LINEA_FINAL" -gt "$TOTAL_LINEAS" ]; then
  echo "❌ Línea $LINEA_FINAL excede el total ($TOTAL_LINEAS) del archivo $ARCHIVO_FULL"
  exit 1
fi

# Idempotencia: si la línea ya tiene ```mermaid, no insertar
LINEA_CONTENIDO=$(sed -n "${LINEA_FINAL}p" "$ARCHIVO_FULL")
if printf '%s' "$LINEA_CONTENIDO" | grep -qF '```mermaid'; then
  echo "ℹ️  La línea $LINEA_FINAL ya contiene un bloque Mermaid. No se reinserta."
  exit 0
fi

# ── Backup ──────────────────────────────────────────────────────────────────
BACKUP="/tmp/mermaid-tpl-backup-$$.md"
cp "$ARCHIVO_FULL" "$BACKUP"

# ── Fix estático del bloque (flowchart: comillas en labels) ────────────────
CONT_FIXED="/tmp/mermaid-tpl-cont-$$.md"
awk '
  /^```/ || /^    ```/ || /^sequenceDiagram/ || /^    sequenceDiagram/ || /^flowchart/ || /^    flowchart/ { print; next }
  {
    line = $0
    if (line ~ /\[/) {
      changed = 1
      while (changed) {
        changed = 0
        new_line = ""
        i = 1
        while (i <= length(line)) {
          c = substr(line, i, 1)
          if (c == "[") {
            j = i + 1; close_pos = 0; depth = 0
            while (j <= length(line)) {
              cj = substr(line, j, 1)
              if (cj == "[") depth++
              if (cj == "]") { if (depth == 0) { close_pos = j; break } depth-- }
              j++
            }
            if (close_pos > 0) {
              inner = substr(line, i+1, close_pos - i - 1)
              if (substr(inner, 1, 1) != "\"" && (index(inner, "{") > 0 || index(inner, " ") > 0 || index(inner, "*") > 0 || index(inner, "/") > 0)) {
                new_line = new_line "[\"" inner "\"]"
                i = close_pos + 1
                changed = 1
                continue
              }
            }
          }
          new_line = new_line c
          i++
        }
        line = new_line
      }
    }
    print line
  }
' "$CONTENIDO" > "$CONT_FIXED"

# Validar flowchart
if [ "$TIPO" = "flowchart" ]; then
  BAD=$(grep -cE '\[[^"]*\{' "$CONT_FIXED" || true)
  BAD=${BAD:-0}
  if [ "$BAD" -gt 0 ]; then
    echo "❌ Validación falló: $BAD nodo(s) con { sin comillas en el bloque."
    cp "$BACKUP" "$ARCHIVO_FULL"
    rm -f "$BACKUP" "$CONT_FIXED"
    exit 1
  fi
fi

# ── Insertar / reemplazar ──────────────────────────────────────────────────
TMP_NEW="/tmp/mermaid-tpl-new-$$.md"

if [ -n "$ETIQUETA" ]; then
  # Reemplazar la línea de la etiqueta por el bloque
  {
    head -n $((LINEA_FINAL - 1)) "$ARCHIVO_FULL"
    echo '```mermaid'
    cat "$CONT_FIXED"
    echo '```'
    tail -n +$((LINEA_FINAL + 1)) "$ARCHIVO_FULL"
  } > "$TMP_NEW"
else
  # Insertar ANTES de la línea N
  {
    head -n $((LINEA_FINAL - 1)) "$ARCHIVO_FULL"
    echo '```mermaid'
    cat "$CONT_FIXED"
    echo '```'
    tail -n +"$LINEA_FINAL" "$ARCHIVO_FULL"
  } > "$TMP_NEW"
fi

cp "$TMP_NEW" "$ARCHIVO_FULL"

# ── Diff ───────────────────────────────────────────────────────────────────
echo "=== Diff aplicado a $ARCHIVO ==="
diff -u "$BACKUP" "$ARCHIVO_FULL" | head -40 || true

# ── Limpieza ───────────────────────────────────────────────────────────────
rm -f "$BACKUP" "$CONT_FIXED" "$TMP_NEW"
echo "✅ Bloque Mermaid insertado en $ARCHIVO (línea $LINEA_FINAL)"
exit 0
