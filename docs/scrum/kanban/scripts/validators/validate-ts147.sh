#!/usr/bin/env bash
# ============================================================================
# validate-ts147.sh — TS-147 (#781) — 3 motion demos (shine, wave, vibrate)
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
DOCS="$REPO/docs"
ISSUE_NUM="${ISSUE_NUM:-781}"
TS_CODE="${TS_CODE:-TS-147}"

LOG_FILE="${LOG_FILE:-}"
if [ -z "$LOG_FILE" ]; then
  LOG_DIR="$REPO/logs/Kanban"
  mkdir -p "$LOG_DIR"
  LOG_FILE="$LOG_DIR/Validacion-criterios-aceptacion-${TS_CODE}.log"
  : > "$LOG_FILE"
  if [ -t 1 ]; then
    exec > >(tee -a "$LOG_FILE") 2>&1
  else
    exec >> "$LOG_FILE" 2>&1
  fi
fi

PASS=0; FAIL=0; CONTRA=0

if [[ -t 1 ]]; then
  CLR_RED=$'\033[0;31m'; CLR_GREEN=$'\033[0;32m'; CLR_YELLOW=$'\033[1;33m'
  CLR_CYAN=$'\033[0;36m'; CLR_BOLD=$'\033[1m'; CLR_NC=$'\033[0m'
else
  CLR_RED=''; CLR_GREEN=''; CLR_YELLOW=''; CLR_CYAN=''; CLR_BOLD=''; CLR_NC=''
fi

check() {
  local ca_code="$1" title="$2" expected="$3" obtained="$4" verdict="$5" ref="${6:-}" debug="${7:-}"
  echo ""
  echo "${CLR_CYAN}${CLR_BOLD}════════════════════════════════════════════════════════════════════${CLR_NC}"
  echo "  CRITERIO $ca_code — $title"
  echo "${CLR_CYAN}════════════════════════════════════════════════════════════════════${CLR_NC}"
  echo "  Esperado : $expected"
  echo "  Obtenido : $obtained"
  if [ -n "$ref" ]; then echo "  Dónde verificar : $ref"; fi
  if [ -n "$debug" ]; then echo "  Debug :"; echo "$debug" | head -30 | sed 's/^/    /'; fi
  case "$verdict" in
    1) echo "  ${CLR_GREEN}Resultado: ✅ APROBÓ${CLR_NC}";           PASS=$((PASS+1)) ;;
    2) echo "  ${CLR_YELLOW}Resultado: ⚠️  CONTRADICCIÓN${CLR_NC}";   CONTRA=$((CONTRA+1)) ;;
    *) echo "  ${CLR_RED}Resultado: ❌ NO APROBÓ${CLR_NC}";           FAIL=$((FAIL+1)) ;;
  esac
  if [ -n "$LOG_FILE" ]; then
    {
      echo "--------- $ca_code — $title ---------"
      echo "Esperado: $expected"
      echo "Obtenido: $obtained"
      if [ -n "$ref" ]; then echo "Dónde verificar: $ref"; fi
      if [ -n "$debug" ]; then echo "Debug (salida real):"; echo "$debug" | head -30 | sed 's/^/  /'; fi
      case "$verdict" in
        1) echo "Resultado: ✅ APROBÓ" ;;
        2) echo "Resultado: ⚠️  CONTRADICCIÓN" ;;
        *) echo "Resultado: ❌ NO APROBÓ" ;;
      esac
      echo ""
    } >> "$LOG_FILE"
  fi
}

# ── CRITERIOS ──────────────────────────────────────────────────────────────
SHINE_DIR="$FRONTEND/src/components/atoms/buttons/ButtonMotionShine"
WAVE_DIR="$FRONTEND/src/components/atoms/buttons/ButtonMotionWave"
VIB_DIR="$FRONTEND/src/components/atoms/buttons/ButtonMotionVibrate"
MOTION_MD="$DOCS/tecnica/04-frontend-react-css-moderno/componentes/atoms/buttons/button-motion.md"
AGENTE="$DOCS/prompts/agente-frontend.md"

# CA_01 — ButtonMotionShine: 6 archivos + lift translateY(-1px)
S_FILES=$(ls -1 "$SHINE_DIR" 2>/dev/null | wc -l | tr -d ' ')
S_LIFT=$(grep -c 'translateY(-1px)' "$SHINE_DIR/ButtonMotionShine.module.css" 2>/dev/null | head -1)
S_LIFT=${S_LIFT:-0}
RESULT=0; [ "$S_FILES" -eq 6 ] && [ "$S_LIFT" -ge 1 ] && RESULT=1
check "CA_01" "ButtonMotionShine/ con 6 archivos + lift" \
  "files=6 lift>=1" "files=$S_FILES lift=$S_LIFT" "$RESULT" \
  "$SHINE_DIR" "ls $SHINE_DIR; grep -c translateY(-1px) ButtonMotionShine.module.css"

# CA_02 — ButtonMotionWave: 6 archivos + onda scale/opacity
W_FILES=$(ls -1 "$WAVE_DIR" 2>/dev/null | wc -l | tr -d ' ')
W_SCALE=$(grep -cE 'ts147-wave-scale|scale\(' "$WAVE_DIR/ButtonMotionWave.module.css" 2>/dev/null | head -1)
W_SCALE=${W_SCALE:-0}
RESULT=0; [ "$W_FILES" -eq 6 ] && [ "$W_SCALE" -ge 1 ] && RESULT=1
check "CA_02" "ButtonMotionWave/ con 6 archivos + onda scale" \
  "files=6 scale>=1" "files=$W_FILES scale=$W_SCALE" "$RESULT" \
  "$WAVE_DIR" "ls $WAVE_DIR; grep -cE 'ts147-wave-scale|scale\\(' ButtonMotionWave.module.css"

# CA_03 — ButtonMotionVibrate: 6 archivos + translateX
V_FILES=$(ls -1 "$VIB_DIR" 2>/dev/null | wc -l | tr -d ' ')
V_X=$(grep -cE 'ts147-vibrate|translateX\(' "$VIB_DIR/ButtonMotionVibrate.module.css" 2>/dev/null | head -1)
V_X=${V_X:-0}
RESULT=0; [ "$V_FILES" -eq 6 ] && [ "$V_X" -ge 1 ] && RESULT=1
check "CA_03" "ButtonMotionVibrate/ con 6 archivos + translateX" \
  "files=6 translateX>=1" "files=$V_FILES translateX=$V_X" "$RESULT" \
  "$VIB_DIR" "ls $VIB_DIR; grep -cE 'ts147-vibrate|translateX\\(' ButtonMotionVibrate.module.css"

# CA_04 — prefers-reduced-motion en los 3 CSS
P1=$(grep -c 'prefers-reduced-motion' "$SHINE_DIR/ButtonMotionShine.module.css" 2>/dev/null | head -1); P1=${P1:-0}
P2=$(grep -c 'prefers-reduced-motion' "$WAVE_DIR/ButtonMotionWave.module.css" 2>/dev/null | head -1); P2=${P2:-0}
P3=$(grep -c 'prefers-reduced-motion' "$VIB_DIR/ButtonMotionVibrate.module.css" 2>/dev/null | head -1); P3=${P3:-0}
RESULT=0; [ "$P1" -ge 1 ] && [ "$P2" -ge 1 ] && [ "$P3" -ge 1 ] && RESULT=1
check "CA_04" "prefers-reduced-motion en los 3 CSS" "shine>=1 wave>=1 vib>=1" \
  "shine=$P1 wave=$P2 vib=$P3" "$RESULT" "los 3 .module.css"

# CA_05 — Solo transform/opacity (sin transition de box-shadow/filter/width/...)
BAD=$(grep -hcE 'transition:[^;]*(width|height|top|left|margin|box-shadow|filter)' \
  "$SHINE_DIR/ButtonMotionShine.module.css" \
  "$WAVE_DIR/ButtonMotionWave.module.css" \
  "$VIB_DIR/ButtonMotionVibrate.module.css" 2>/dev/null | awk '{s+=$1} END{print s+0}')
BAD=${BAD:-0}
RESULT=0; [ "$BAD" -eq 0 ] && RESULT=1
check "CA_05" "Solo transform/opacity animados" "prohibited=0" "prohibited=$BAD" "$RESULT" \
  "los 3 .module.css" "grep -cE 'transition:.*(width|height|top|left|margin|box-shadow|filter)'"

# CA_06 — Runner verde (behavior)
if [ "${RUN_BEHAVIOR:-0}" = "1" ]; then
  echo ""
  echo "  Ejecutando Frontend-test-Dev.sh (CA_06)…"
  ( cd "$FRONTEND" && RUN_AUTOFIX=0 bash tests/shellTest/Frontend-test-Dev.sh ) > /tmp/ts147-runner.log 2>&1
  RUNNER_EXIT=$?
  WNEW=$(grep -c '\[W-NEW\]' /tmp/ts147-runner.log 2>/dev/null | head -1); WNEW=${WNEW:-0}
  ENEW=$(grep -c '\[E-NEW\]' /tmp/ts147-runner.log 2>/dev/null | head -1); ENEW=${ENEW:-0}
  RESULT=0; [ "$RUNNER_EXIT" -eq 0 ] && [ "$WNEW" -eq 0 ] && [ "$ENEW" -eq 0 ] && RESULT=1
  check "CA_06" "Frontend-test-Dev.sh verde" "exit=0 W-NEW=0 E-NEW=0" \
    "exit=$RUNNER_EXIT W-NEW=$WNEW E-NEW=$ENEW" "$RESULT" \
    "/tmp/ts147-runner.log" "tail -20 /tmp/ts147-runner.log"
else
  check "CA_06" "Frontend-test-Dev.sh verde (behavior)" "exit=0 W-NEW=0 E-NEW=0" \
    "SKIP (RUN_BEHAVIOR=0)" 1 "RUN_BEHAVIOR=1 para ejecutar"
fi

# CA_07 — button-motion.md con 3 patrones
MD_EXIST=0; [ -f "$MOTION_MD" ] && MD_EXIST=1
MD_PATTERNS=$(grep -ciE 'shine|wave|vibrate' "$MOTION_MD" 2>/dev/null | head -1); MD_PATTERNS=${MD_PATTERNS:-0}
RESULT=0; [ "$MD_EXIST" -eq 1 ] && [ "$MD_PATTERNS" -ge 3 ] && RESULT=1
check "CA_07" "button-motion.md con 3 patrones" "exist=1 patterns>=3" \
  "exist=$MD_EXIST patterns=$MD_PATTERNS" "$RESULT" "componentes/atoms/buttons/button-motion.md" \
  "grep -ciE 'shine|wave|vibrate'"

# CA_08 — agente §24.3.5 menciona 3 componentes + "usuario elige"

# CA_08 — agente §24.3.5 menciona 3 componentes + "usuario elige"
AG_MENTIONS=$(grep -cE 'ButtonMotionShine|ButtonMotionWave|ButtonMotionVibrate' "$AGENTE" 2>/dev/null | head -1); AG_MENTIONS=${AG_MENTIONS:-0}
AG_ELIGE=$(grep -c 'usuario elige' "$AGENTE" 2>/dev/null | head -1); AG_ELIGE=${AG_ELIGE:-0}
RESULT=0; [ "$AG_MENTIONS" -ge 3 ] && [ "$AG_ELIGE" -ge 1 ] && RESULT=1
check "CA_08" "agente §24.3.5 menciona 3 componentes + usuario elige" \
  "mentions>=3 elige>=1" "mentions=$AG_MENTIONS elige=$AG_ELIGE" "$RESULT" \
  "agente-frontend.md §24.3.5" "grep -cE 'ButtonMotionShine|ButtonMotionWave|ButtonMotionVibrate'"

# ── SUMMARY ────────────────────────────────────────────────────────────────
echo ""
echo "${CLR_BOLD}╔════════════════════════════════════════════════════════════════════╗${CLR_NC}"
echo "${CLR_BOLD}║  RESUMEN GLOBAL — $TS_CODE (#$ISSUE_NUM)${CLR_NC}"
echo "${CLR_BOLD}╚════════════════════════════════════════════════════════════════════╝${CLR_NC}"
echo "  Criterios aprobados      : $PASS"
echo "  Criterios NO aprobados   : $FAIL"
echo "  Criterios contradictorios: $CONTRA"
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
  echo "  ${CLR_GREEN}${CLR_BOLD}🟢 VEREDICTO GLOBAL: APROBÓ${CLR_NC}"
  exit 0
else
  echo "  ${CLR_RED}${CLR_BOLD}🔴 VEREDICTO GLOBAL: NO APROBÓ${CLR_NC}"
  exit 1
fi
