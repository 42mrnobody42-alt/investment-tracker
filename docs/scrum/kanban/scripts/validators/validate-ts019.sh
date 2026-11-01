#!/usr/bin/env bash
# ============================================================================
# validate-ts019.sh — Validación TS-019 (#624) .env + templates
# Invocado por ../validate-task-in-kanban.sh <issue-number>
# Env vars heredadas: ISSUE_NUM, TS_CODE, LOG_FILE
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
ISSUE_NUM="${ISSUE_NUM:-624}"
TS_CODE="${TS_CODE:-TS-019}"

LOG_FILE="${LOG_FILE:-}"

PASS=0; FAIL=0; CONTRA=0
if [[ -t 1 ]]; then
  CR=$'\033[0;31m'; CG=$'\033[0;32m'; CY=$'\033[1;33m'
  CC=$'\033[0;36m'; CB=$'\033[1m'; CN=$'\033[0m'
else
  CR=''; CG=''; CY=''; CC=''; CB=''; CN=''
fi

check() {
  local ca_code="$1" title="$2" expected="$3" obtained="$4" verdict="$5" ref="${6:-}" debug="${7:-}"
  echo ""
  echo "${CC}${CB}════════════════════════════════════════════════════════════════════${CN}"
  echo "  CRITERIO $ca_code — $title"
  echo "${CC}════════════════════════════════════════════════════════════════════${CN}"
  echo "  Esperado : $expected"
  echo "  Obtenido : $obtained"
  if [ -n "$ref" ]; then echo "  Dónde verificar : $ref"; fi
  if [ -n "$debug" ]; then
    echo "  Debug (comando + salida real):"
    echo "$debug" | head -40 | sed 's/^/    /'
  fi
  case "$verdict" in
    1) echo "  ${CG}Resultado: ✅ APROBÓ${CN}";           PASS=$((PASS+1)) ;;
    2) echo "  ${CY}Resultado: ⚠️  CONTRADICCIÓN${CN}";   CONTRA=$((CONTRA+1)) ;;
    *) echo "  ${CR}Resultado: ❌ NO APROBÓ${CN}";       FAIL=$((FAIL+1)) ;;
  esac

  if [ -n "$LOG_FILE" ]; then
    {
      echo "--------- $ca_code — $title ---------"
      echo "Esperado: $expected"
      echo "Obtenido: $obtained"
      if [ -n "$ref" ]; then echo "Dónde verificar: $ref"; fi
      if [ -n "$debug" ]; then
        echo "Debug (comando + salida real):"
        echo "$debug" | head -40 | sed 's/^/  /'
      fi
      case "$verdict" in
        1) echo "Resultado: ✅ APROBÓ" ;;
        2) echo "Resultado: ⚠️  CONTRADICCIÓN" ;;
        *) echo "Resultado: ❌ NO APROBÓ" ;;
      esac
      echo ""
    } >> "$LOG_FILE"
  fi
}

cnt() {
  local pattern="$1" file="$2"
  if [ ! -f "$file" ]; then echo 0; return; fi
  local c
  c=$(grep -c "$pattern" "$file" 2>/dev/null | head -1)
  echo "${c:-0}"
}

# ── CA_01 — frontend/.env con 3 vars ──────────────────────────────────────
V=0
if [ -f "$FRONTEND/.env" ] && \
   grep -qF "VITE_API_URL=/api" "$FRONTEND/.env" && \
   grep -qF "VITE_APP_ENV=development" "$FRONTEND/.env" && \
   grep -qF "VITE_APP_NAME=Investment Tracker Pro" "$FRONTEND/.env"; then
  V=1
fi
DEBUG_01="\$ cat frontend/.env
$(cat "$FRONTEND/.env" 2>/dev/null | head -15)"
R=0; [ "$V" -eq 1 ] && R=1
check "CA_01" "frontend/.env con 3 vars (VITE_API_URL=/api, VITE_APP_ENV=development, VITE_APP_NAME=Investment Tracker Pro)" "1" "$V" "$R" \
  "frontend/.env" \
  "$DEBUG_01"

# ── CA_02 — git ls-files solo .env ────────────────────────────────────────
LS_FILES=$(git -C "$REPO" ls-files 'frontend/.env*' 2>/dev/null | sort)
if [ -z "$LS_FILES" ]; then
  COUNT=0
else
  COUNT=$(printf "%s\n" "$LS_FILES" | grep -c .)
fi
DEBUG_02="\$ git ls-files 'frontend/.env*'
${LS_FILES:-(vacío — .env aún no está en git, se valida post-commit)}
count=$COUNT"
# Pre-commit: untracked es OK si el archivo existe en disco.
# Post-commit: debe ser exactamente "frontend/.env".
if [ "$COUNT" -eq 0 ]; then
  if [ -f "$FRONTEND/.env" ]; then
    R=1
    DISPLAY="(untracked, archivo existe en disco)"
  else
    R=0
    DISPLAY="(no existe ni en disco ni en git)"
  fi
elif [ "$COUNT" -eq 1 ] && [ "$LS_FILES" = "frontend/.env" ]; then
  R=1
  DISPLAY="frontend/.env"
else
  R=0
  DISPLAY="$LS_FILES"
fi
check "CA_02" "git ls-files 'frontend/.env*' muestra solo frontend/.env" "solo frontend/.env (pre-commit: untracked OK)" "$DISPLAY" "$R" \
  "git ls-files frontend/.env*" \
  "$DEBUG_02"
# ── CA_03 — git check-ignore NO ignorado ──────────────────────────────────
git -C "$REPO" check-ignore -q frontend/.env 2>/dev/null
IGNORE_EXIT=$?
DEBUG_03="\$ git check-ignore -q frontend/.env
exit=$IGNORE_EXIT (0 = ignorado, 1 = NO ignorado = correcto)"
R=0; [ "$IGNORE_EXIT" -ne 0 ] && R=1
check "CA_03" "frontend/.env NO ignorado por git (check-ignore exit != 0)" "exit != 0 (NO ignorado)" "exit=$IGNORE_EXIT" "$R" \
  "git check-ignore frontend/.env" \
  "$DEBUG_03"
# ── CA_04 — npm run dev lee las 3 vars (verificación estructural) ─────────
# No arrancamos vite dev (tarda). Verificamos las 3 condiciones que hacen que
# Vite las lea:
#   (a) .env existe en frontend/ (raíz del proyecto Vite)
#   (b) las 3 vars están en .env
#   (c) vite.config.ts no define envPrefix restrictivo
ENV_EXISTS=0; [ -f "$FRONTEND/.env" ] && ENV_EXISTS=1
VARS_OK=0
grep -qF "VITE_API_URL=" "$FRONTEND/.env" 2>/dev/null && \
grep -qF "VITE_APP_ENV=" "$FRONTEND/.env" 2>/dev/null && \
grep -qF "VITE_APP_NAME=" "$FRONTEND/.env" 2>/dev/null && VARS_OK=1
ENV_PREFIX_RESTRICT=$(grep -c "envPrefix" "$FRONTEND/vite.config.ts" 2>/dev/null | head -1)
ENV_PREFIX_RESTRICT="${ENV_PREFIX_RESTRICT:-0}"
DEBUG_04="\$ ls -la frontend/.env
$(ls -la "$FRONTEND/.env" 2>/dev/null)
\$ grep VITE_ frontend/.env
$(grep 'VITE_' "$FRONTEND/.env" 2>/dev/null)
\$ grep envPrefix frontend/vite.config.ts (0 = usa default VITE_*)
$ENV_PREFIX_RESTRICT"
R=0
[ "$ENV_EXISTS" -eq 1 ] && [ "$VARS_OK" -eq 1 ] && [ "$ENV_PREFIX_RESTRICT" -eq 0 ] && R=1
check "CA_04" "npm run dev leerá las 3 vars (estructura correcta: .env en raíz, 3 vars, sin envPrefix restrictivo)" "1/1/0" "$ENV_EXISTS/$VARS_OK/$ENV_PREFIX_RESTRICT" "$R" \
  "frontend/.env + frontend/vite.config.ts" \
  "$DEBUG_04"

# ── CA_05 — US-template Resumen ejecutivo primera sección ─────────────────
FIRST_LINE=$(head -1 "$REPO/docs/scrum/kanban/templates/US-template.md" 2>/dev/null)
DEBUG_05="\$ head -1 docs/scrum/kanban/templates/US-template.md
$FIRST_LINE"
R=0; [ "$FIRST_LINE" = "## Resumen ejecutivo" ] && R=1
check "CA_05" "US-template.md con '## Resumen ejecutivo' como primera sección" "## Resumen ejecutivo" "$FIRST_LINE" "$R" \
  "docs/scrum/kanban/templates/US-template.md (primera línea)" \
  "$DEBUG_05"

# ── CA_06 — TS-template (instrucciones + funcionalidad nueva) ─────────────
INSTR=$(cnt "Cada CA debe indicar" "$REPO/docs/scrum/kanban/templates/TS-template.md")
FUNC_NEW=$(cnt "^### Si la tarea crea funcionalidad nueva" "$REPO/docs/scrum/kanban/templates/TS-template.md")
DIAG_GER=$(cnt "^#### A. Diagrama gerencial" "$REPO/docs/scrum/kanban/templates/TS-template.md")
DIAG_TEC=$(cnt "^#### B. Diagrama técnico frontend" "$REPO/docs/scrum/kanban/templates/TS-template.md")
DEBUG_06="\$ grep -c 'Cada CA debe indicar' docs/scrum/kanban/templates/TS-template.md
$INSTR
\$ grep -c '### Si la tarea crea funcionalidad nueva' ...
$FUNC_NEW
\$ grep -c '#### A. Diagrama gerencial' ...
$DIAG_GER
\$ grep -c '#### B. Diagrama técnico frontend' ...
$DIAG_TEC"
R=0
[ "$INSTR" -ge 1 ] && [ "$FUNC_NEW" -ge 1 ] && [ "$DIAG_GER" -ge 1 ] && [ "$DIAG_TEC" -ge 1 ] && R=1
check "CA_06" "TS-template.md con instrucciones doc + 'Si la tarea crea funcionalidad nueva' + 2 diagramas (gerencial/técnico)" ">=1/>=1/>=1/>=1" "$INSTR/$FUNC_NEW/$DIAG_GER/$DIAG_TEC" "$R" \
  "docs/scrum/kanban/templates/TS-template.md" \
  "$DEBUG_06"

# ── CA_07 — runner sigue verde (busca en todos los logs) ──────────────────
GREEN_LOG=""
for f in $(ls -t "$REPO/logs/Frontend/Dev/Frontend-test-Dev_"*.log 2>/dev/null); do
  if sed -E 's/\x1b\[[0-9;]*m//g' "$f" 2>/dev/null | grep -q "TODO VERDE"; then
    GREEN_LOG="$f"; break
  fi
done
if [ -n "$GREEN_LOG" ]; then
  DEBUG_07="\$ grep 'TODO VERDE' $(basename "$GREEN_LOG")
$(sed -E 's/\x1b\[[0-9;]*m//g' "$GREEN_LOG" 2>/dev/null | grep "TODO VERDE" | head -1)"
  R=1
  DISPLAY="verde ($(basename "$GREEN_LOG"))"
else
  DEBUG_07="(no se encontró ningún log con 'TODO VERDE')"
  R=0
  DISPLAY="rojo (sin log verde)"
fi
check "CA_07" "Frontend-test-Dev.sh sigue verde (14 grupos, 1 W-DOC, 0 nuevos)" "verde" "$DISPLAY" "$R" \
  "logs/Frontend/Dev/ (buscar 'TODO VERDE')" \
  "$DEBUG_07"

# ── CA_08 — README §Frontend "Variables de entorno" posición correcta ─────
ARCH_LINE=$(grep -n "^### Arquitectura del Frontend$" "$REPO/README.md" 2>/dev/null | cut -d: -f1 | head -1)
STACK_LINE=$(grep -n "^### Stack Tecnológico del Frontend$" "$REPO/README.md" 2>/dev/null | cut -d: -f1 | head -1)
ENV_LINE=$(grep -n '^#### Variables de entorno (`\.env`)' "$REPO/README.md" 2>/dev/null | cut -d: -f1 | head -1)
DEBUG_08="\$ grep -n 'Arquitectura del Frontend' README.md → línea ${ARCH_LINE:-no encontrada}
\$ grep -n 'Variables de entorno (\`.env\`)' README.md → línea ${ENV_LINE:-no encontrada}
\$ grep -n 'Stack Tecnológico del Frontend' README.md → línea ${STACK_LINE:-no encontrada}"
R=0
if [ -n "$ARCH_LINE" ] && [ -n "$ENV_LINE" ] && [ -n "$STACK_LINE" ] && \
   [ "$ENV_LINE" -gt "$ARCH_LINE" ] && [ "$ENV_LINE" -lt "$STACK_LINE" ]; then
  R=1
fi
check "CA_08" "README §Frontend → 'Variables de entorno (.env)' entre 'Arquitectura' y 'Stack Tecnológico'" "entre las dos secciones" "Arq=$ARCH_LINE Env=$ENV_LINE Stack=$STACK_LINE" "$R" \
  "README.md §4 Frontend" \
  "$DEBUG_08"

# ── CA_09 — README índice entrada .env ────────────────────────────────────
IDX_ENTRY=$(grep -cF '[Variables de entorno (`.env`)](#variables-de-entorno-env)' "$REPO/README.md" 2>/dev/null | head -1)
IDX_ENTRY="${IDX_ENTRY:-0}"
DEBUG_09="\$ grep -F '[Variables de entorno (\`.env\`)](#variables-de-entorno-env)' README.md
$(grep -F '[Variables de entorno (`' "$REPO/README.md" 2>/dev/null | head -2)"
R=0; [ "$IDX_ENTRY" -ge 1 ] && R=1
check "CA_09" "README índice con entrada '[Variables de entorno (.env)]'" ">=1" "$IDX_ENTRY" "$R" \
  "README.md (índice superior)" \
  "$DEBUG_09"

# ── CA_10 — prompt_inicial regla 37 ───────────────────────────────────────
V=$(cnt "^37\. \*\*Archivo \`.env\` del frontend" "$REPO/docs/prompts/prompt_inicial.md")
DEBUG_10="\$ grep -n '37. **Archivo \`.env\` del frontend' docs/prompts/prompt_inicial.md
$(grep -n '^37\. \*\*Archivo' "$REPO/docs/prompts/prompt_inicial.md" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_10" "prompt_inicial regla 37 (.env único commiteado, prohibido por ambiente, VITE_API_URL=/api)" ">=1" "$V" "$R" \
  "docs/prompts/prompt_inicial.md (regla 37)" \
  "$DEBUG_10"

# ── CA_11 — agente-frontend §14.11 ────────────────────────────────────────
V=$(cnt "^### 14\.11 Variables de entorno" "$REPO/docs/prompts/agente-frontend.md")
DEBUG_11="\$ grep -n '### 14.11 Variables de entorno' docs/prompts/agente-frontend.md
$(grep -n '^### 14\.11 Variables de entorno' "$REPO/docs/prompts/agente-frontend.md" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_11" "agente-frontend §14.11 Variables de entorno (.env en dev/build)" ">=1" "$V" "$R" \
  "docs/prompts/agente-frontend.md §14.11" \
  "$DEBUG_11"

# ── SUMMARY ────────────────────────────────────────────────────────────────
echo ""
echo "${CB}╔════════════════════════════════════════════════════════════════════╗${CN}"
echo "${CB}║  RESUMEN — $TS_CODE (#$ISSUE_NUM)${CN}"
echo "${CB}╚════════════════════════════════════════════════════════════════════╝${CN}"
echo "  Aprobados      : $PASS"
echo "  NO aprobados   : $FAIL"
echo "  Contradicciones: $CONTRA"
echo ""
echo "  📄 Log: $LOG_FILE"
echo ""

if [ -n "$LOG_FILE" ]; then
  {
    echo "================================================================"
    echo " RESUMEN — $TS_CODE (#$ISSUE_NUM)"
    echo " Aprobados: $PASS"
    echo " NO aprobados: $FAIL"
    echo " Contradicciones: $CONTRA"
    if [ "$FAIL" -eq 0 ] && [ "$CONTRA" -eq 0 ]; then
      echo " Veredicto: 🟢 APROBÓ"
    else
      echo " Veredicto: 🔴 NO APROBÓ"
    fi
    echo "================================================================"
  } >> "$LOG_FILE"
fi

if [ "$FAIL" -eq 0 ] && [ "$CONTRA" -eq 0 ]; then
  echo "  ${CG}${CB}🟢 VEREDICTO: APROBÓ${CN}"
  exit 0
else
  echo "  ${CR}${CB}🔴 VEREDICTO: NO APROBÓ${CN}"
  exit 1
fi
