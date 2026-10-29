#!/usr/bin/env bash
# ============================================================================
# validate-ts016.sh — Validación TS-016 (#621) Husky + pre-commit
# Invocado por ../validate-task-in-kanban.sh <issue-number>
# Env vars heredadas: ISSUE_NUM, TS_CODE, LOG_FILE
# Flags: RUN_BEHAVIOR=0|1 (default 1)
#
# Debug en TODOS los checks: comando ejecutado + salida real (para
# que el usuario sepa QUÉ se ejecutó y QUÉ se obtuvo, en éxito o fallo).
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
ISSUE_NUM="${ISSUE_NUM:-621}"
TS_CODE="${TS_CODE:-TS-016}"
RUN_BEHAVIOR="${RUN_BEHAVIOR:-1}"

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
  if [ -n "$ref" ]; then
    echo "  Dónde verificar : $ref"
  fi
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

# ── CA_01 ──────────────────────────────────────────────────────────────────
V_H=$(jq -r '.devDependencies.husky // "no"' "$FRONTEND/package.json")
V_L=$(jq -r '.devDependencies["lint-staged"] // "no"' "$FRONTEND/package.json")
DEBUG_01="\$ jq -r '.devDependencies.husky, .devDependencies[\"lint-staged\"]' frontend/package.json
$(jq -r '.devDependencies.husky, .devDependencies["lint-staged"]' "$FRONTEND/package.json" 2>/dev/null)"
R=0; [ "$V_H" = "9.1.7" ] && [ "$V_L" = "17.6.0" ] && R=1
check "CA_01" "husky+lint-staged pinneados (--save-exact)" "9.1.7/17.6.0" "$V_H/$V_L" "$R" \
  "frontend/package.json → devDependencies" \
  "$DEBUG_01"

# ── CA_02 ──────────────────────────────────────────────────────────────────
E=0; X=0
[ -f "$FRONTEND/.husky/pre-commit" ] && E=1
[ -x "$FRONTEND/.husky/pre-commit" ] && X=1
M=$(git -C "$REPO" ls-files --stage frontend/.husky/pre-commit 2>/dev/null | awk '{print $1}')
[ -z "$M" ] && M="(untracked)"
DEBUG_02="\$ ls -la frontend/.husky/pre-commit
$(ls -la "$FRONTEND/.husky/pre-commit" 2>/dev/null)
\$ git ls-files --stage frontend/.husky/pre-commit
$(git -C "$REPO" ls-files --stage frontend/.husky/pre-commit 2>/dev/null)"
R=0; [ "$E" -eq 1 ] && [ "$X" -eq 1 ] && [ "$M" = "100755" ] && R=1
[ "$E" -eq 1 ] && [ "$X" -eq 1 ] && [ "$M" = "(untracked)" ] && R=2
check "CA_02" "pre-commit existe+ejecutable+100755" "1/1/100755" "$E/$X/$M" "$R" \
  "frontend/.husky/pre-commit (ls -l) + git ls-files --stage" \
  "$DEBUG_02"

# ── CA_03 ──────────────────────────────────────────────────────────────────
F1=$(cnt "npx lint-staged" "$FRONTEND/.husky/pre-commit")
F2=$(cnt "npm run type-check" "$FRONTEND/.husky/pre-commit")
DEBUG_03="\$ grep -nE 'lint-staged|type-check' frontend/.husky/pre-commit
$(grep -nE 'lint-staged|type-check' "$FRONTEND/.husky/pre-commit" 2>/dev/null)"
R=0; [ "$F1" -ge 1 ] && [ "$F2" -ge 1 ] && R=1
check "CA_03" "pre-commit → lint-staged+type-check" "1/1" "$F1/$F2" "$R" \
  "frontend/.husky/pre-commit (contenido)" \
  "$DEBUG_03"

# ── CA_04 ──────────────────────────────────────────────────────────────────
E=0; J=0; T1=0; T2=0; T3=0
[ -f "$FRONTEND/.lintstagedrc.json" ] && E=1
node -e 'JSON.parse(require("fs").readFileSync("'"$FRONTEND"'/.lintstagedrc.json","utf8"))' 2>/dev/null && J=1
T1=$(cnt '"*.{ts,tsx}"' "$FRONTEND/.lintstagedrc.json")
T2=$(cnt '"*.css"' "$FRONTEND/.lintstagedrc.json")
T3=$(cnt '"*.{json,md,yml,yaml}"' "$FRONTEND/.lintstagedrc.json")
DEBUG_04="\$ cat frontend/.lintstagedrc.json
$(cat "$FRONTEND/.lintstagedrc.json" 2>/dev/null)"
R=0; [ "$E" -eq 1 ] && [ "$J" -eq 1 ] && [ "$T1" -ge 1 ] && [ "$T2" -ge 1 ] && [ "$T3" -ge 1 ] && R=1
check "CA_04" ".lintstagedrc.json existe+JSON+globs" "1/1/1/1/1" "$E/$J/$T1/$T2/$T3" "$R" \
  "frontend/.lintstagedrc.json" \
  "$DEBUG_04"

# ── CA_05 ──────────────────────────────────────────────────────────────────
V=$(jq -r '.scripts.prepare // "(no)"' "$FRONTEND/package.json")
DEBUG_05="\$ jq -r '.scripts.prepare' frontend/package.json
$(jq -r '.scripts.prepare // "(no)"' "$FRONTEND/package.json" 2>/dev/null)"
R=0; [ "$V" != "(no)" ] && [ "$V" != "null" ] && R=1
check "CA_05" "scripts.prepare configurado" "no nulo" "$V" "$R" \
  "frontend/package.json → scripts.prepare" \
  "$DEBUG_05"

# ── CA_06 ──────────────────────────────────────────────────────────────────
ROOT_GI=$(cnt "\.husky/_" "$FRONTEND/.gitignore")
SELF_GI=0; [ -f "$FRONTEND/.husky/_/.gitignore" ] && SELF_GI=1
DEBUG_06="\$ cat frontend/.husky/_/.gitignore
$(cat "$FRONTEND/.husky/_/.gitignore" 2>/dev/null)
\$ git check-ignore frontend/.husky/_/pre-commit
$(git -C "$REPO" check-ignore frontend/.husky/_/pre-commit 2>/dev/null)"
R=0; { [ "$ROOT_GI" -ge 1 ] || [ "$SELF_GI" -eq 1 ]; } && R=1
check "CA_06" ".husky/_/ ignorado" "root>=1 o self=1" "root=$ROOT_GI self=$SELF_GI" "$R" \
  "frontend/.husky/_/.gitignore (self) o frontend/.gitignore" \
  "$DEBUG_06"

# ── CA_07..CA_09 behavior ──────────────────────────────────────────────────
if [ "$RUN_BEHAVIOR" = "1" ]; then
  SAVED_HEAD=$(git -C "$REPO" rev-parse HEAD)

  # CA_07: ESLint error → rechaza
  TF="$FRONTEND/src/__ts016_ca07__.ts"
  echo "const unused = 'violation';" > "$TF"
  git -C "$REPO" add "frontend/src/__ts016_ca07__.ts"
  bash "$FRONTEND/.husky/pre-commit" >/tmp/ca07.log 2>&1; EX=$?
  git -C "$REPO" reset HEAD "frontend/src/__ts016_ca07__.ts" >/dev/null 2>&1; rm -f "$TF"
  DEBUG_07="\$ echo 'const unused = \"violation\";' > src/__ts016_ca07__.ts
\$ git add src/__ts016_ca07__.ts && bash frontend/.husky/pre-commit
$(grep -E 'error|✖|Failed|unused' /tmp/ca07.log 2>/dev/null | head -5)"
  [ -z "$(echo "$DEBUG_07" | tail -1)" ] && DEBUG_07=$(printf "%s\n%s" "$DEBUG_07" "$(tail -5 /tmp/ca07.log 2>/dev/null)")
  R=0; [ "$EX" -ne 0 ] && R=1
  check "CA_07" "ESLint error → hook rechaza" "exit!=0" "exit=$EX" "$R" \
    "frontend/.husky/pre-commit (ejecutado con archivo ESLint-error)" \
    "$DEBUG_07"

  # CA_08: Prettier → autofixea
  TF="$FRONTEND/src/__ts016_ca08__.ts"
  echo "export const testFormat    =    'sin formatear';" > "$TF"
  git -C "$REPO" add "frontend/src/__ts016_ca08__.ts"
  bash "$FRONTEND/.husky/pre-commit" >/tmp/ca08.log 2>&1; EX=$?
  MOD=0; grep -q "testFormat =" "$TF" 2>/dev/null && MOD=1
  git -C "$REPO" reset HEAD "frontend/src/__ts016_ca08__.ts" >/dev/null 2>&1; rm -f "$TF"
  DEBUG_08="\$ echo 'export const testFormat    =    \"sin formatear\";' > src/__ts016_ca08__.ts
\$ git add src/__ts016_ca08__.ts && bash frontend/.husky/pre-commit
$(grep -E 'prettier|Prettier|unchanged|fixed|ms$' /tmp/ca08.log 2>/dev/null | head -5)"
  [ -z "$(echo "$DEBUG_08" | tail -1)" ] && DEBUG_08=$(printf "%s\n%s" "$DEBUG_08" "$(tail -5 /tmp/ca08.log 2>/dev/null)")
  R=0; [ "$EX" -eq 0 ] && [ "$MOD" -eq 1 ] && R=1
  check "CA_08" "Prettier → autofixea+permite" "exit=0+formateado" "exit=$EX mod=$MOD" "$R" \
    "frontend/.husky/pre-commit (ejecutado con archivo Prettier-roto)" \
    "$DEBUG_08"

  # CA_09: tsc error → rechaza
  TF="$FRONTEND/src/__ts016_ca09__.ts"
  echo "export const x: number = 'string';" > "$TF"
  git -C "$REPO" add "frontend/src/__ts016_ca09__.ts"
  bash "$FRONTEND/.husky/pre-commit" >/tmp/ca09.log 2>&1; EX=$?
  git -C "$REPO" reset HEAD "frontend/src/__ts016_ca09__.ts" >/dev/null 2>&1; rm -f "$TF"
  DEBUG_09="\$ echo 'export const x: number = \"string\";' > src/__ts016_ca09__.ts
\$ git add src/__ts016_ca09__.ts && bash frontend/.husky/pre-commit
$(grep -E 'error TS|error:|TypeScript' /tmp/ca09.log 2>/dev/null | head -5)"
  [ -z "$(echo "$DEBUG_09" | tail -1)" ] && DEBUG_09=$(printf "%s\n%s" "$DEBUG_09" "$(tail -5 /tmp/ca09.log 2>/dev/null)")
  R=0; [ "$EX" -ne 0 ] && R=1
  check "CA_09" "tsc error → hook rechaza" "exit!=0" "exit=$EX" "$R" \
    "frontend/.husky/pre-commit (ejecutado con archivo tsc-error)" \
    "$DEBUG_09"

  CUR=$(git -C "$REPO" rev-parse HEAD)
  [ "$CUR" != "$SAVED_HEAD" ] && git -C "$REPO" reset --mixed "$SAVED_HEAD" >/dev/null 2>&1 || true
else
  echo ""
  echo "  CA_07 SKIP (RUN_BEHAVIOR=0)"
  echo "  CA_08 SKIP (RUN_BEHAVIOR=0)"
  echo "  CA_09 SKIP (RUN_BEHAVIOR=0)"
fi

# ── CA_10 ──────────────────────────────────────────────────────────────────
V=$(cnt "^run_hooks()" "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh")
DEBUG_10="\$ grep -n -A3 '^run_hooks()' frontend/tests/shellTest/Frontend-test-Dev.sh
$(grep -n -A3 "^run_hooks()" "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh" 2>/dev/null | head -5)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_10" "run_hooks() definido en runner" ">=1" "$V" "$R" \
  "frontend/tests/shellTest/Frontend-test-Dev.sh → run_hooks()" \
  "$DEBUG_10"

# ── CA_11 ──────────────────────────────────────────────────────────────────
V=$(cnt "^  run_hooks || true" "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh")
DEBUG_11="\$ grep -n 'run_hooks || true' frontend/tests/shellTest/Frontend-test-Dev.sh
$(grep -n 'run_hooks || true' "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_11" "run_hooks() llamado en main" ">=1" "$V" "$R" \
  "frontend/tests/shellTest/Frontend-test-Dev.sh → main()" \
  "$DEBUG_11"

# ── CA_12 ──────────────────────────────────────────────────────────────────
LATEST_LOG=$(ls -t "$REPO/logs/Frontend/Dev/Frontend-test-Dev_"*.log 2>/dev/null | head -1)
if [ -n "$LATEST_LOG" ]; then
  GREEN=$(sed -E 's/\x1b\[[0-9;]*m//g' "$LATEST_LOG" 2>/dev/null | grep -c "TODO VERDE" | head -1)
  GREEN="${GREEN:-0}"
  DEBUG_12="\$ grep 'TODO VERDE' $(basename "$LATEST_LOG")
$(sed -E 's/\x1b\[[0-9;]*m//g' "$LATEST_LOG" 2>/dev/null | grep -E "TODO VERDE" | head -1)"
  [ -z "$(echo "$DEBUG_12" | tail -1)" ] && DEBUG_12=$(printf "%s\n%s" "$DEBUG_12" "$(sed -E 's/\x1b\[[0-9;]*m//g' "$LATEST_LOG" 2>/dev/null | tail -3)")
  R=0; [ "$GREEN" -ge 1 ] && R=1
  check "CA_12" "runner sigue verde" "verde" "$( [ "$GREEN" -ge 1 ] && echo 'verde' || echo 'rojo' )" "$R" \
    "$LATEST_LOG" \
    "$DEBUG_12"
else
  check "CA_12" "runner sigue verde" "verde" "(sin log — ejecutar runner primero)" 0 \
    "logs/Frontend/Dev/Frontend-test-Dev_*.log" \
    "(no hay log)"
fi

# ── CA_13 ──────────────────────────────────────────────────────────────────
V=$(cnt "Husky + pre-commit\|husky/pre-commit" "$REPO/README.md")
DEBUG_13="\$ grep -nE 'Husky \+ pre-commit|husky/pre-commit' README.md
$(grep -nE "Husky \+ pre-commit|husky/pre-commit" "$REPO/README.md" 2>/dev/null | head -3)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_13" "README menciona Husky + pre-commit" ">=1" "$V" "$R" \
  "README.md (buscar 'Husky + pre-commit' o 'husky/pre-commit')" \
  "$DEBUG_13"

# ── CA_14 ──────────────────────────────────────────────────────────────────
V=$(cnt "Pre-commit hook" "$REPO/docs/prompts/prompt_inicial.md")
DEBUG_14="\$ grep -n 'Pre-commit hook' docs/prompts/prompt_inicial.md
$(grep -n "Pre-commit hook" "$REPO/docs/prompts/prompt_inicial.md" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_14" "prompt_inicial regla pre-commit" ">=1" "$V" "$R" \
  "docs/prompts/prompt_inicial.md (regla 33)" \
  "$DEBUG_14"

# ── CA_15 ──────────────────────────────────────────────────────────────────
V=$(cnt "Husky + pre-commit\|husky/pre-commit" "$REPO/docs/prompts/agente-frontend.md")
DEBUG_15="\$ grep -nE 'Husky \+ pre-commit' docs/prompts/agente-frontend.md
$(grep -nE "Husky \+ pre-commit" "$REPO/docs/prompts/agente-frontend.md" 2>/dev/null | head -3)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_15" "agente-frontend sección Husky+pre-commit" ">=1" "$V" "$R" \
  "docs/prompts/agente-frontend.md §14.8" \
  "$DEBUG_15"

# ── CA_16 ──────────────────────────────────────────────────────────────────
V=$(cnt "Pre-commit.*Husky v9\|pre-commit" "$REPO/docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md")
DEBUG_16="\$ grep -nE 'Pre-commit.*Husky v9|pre-commit' docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md
$(grep -nE "Pre-commit.*Husky v9|pre-commit" "$REPO/docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_16" "convenciones bullet pre-commit" ">=1" "$V" "$R" \
  "docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md §6" \
  "$DEBUG_16"

# ── CA_17 ──────────────────────────────────────────────────────────────────
V=$(cnt "RUN_HOOKS" "$REPO/docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md")
DEBUG_17="\$ grep -n 'RUN_HOOKS' docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md
$(grep -n "RUN_HOOKS" "$REPO/docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md" 2>/dev/null | head -3)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_17" "pruebas.md documenta RUN_HOOKS" ">=1" "$V" "$R" \
  "docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md (Árbol de control)" \
  "$DEBUG_17"

# ── CA_18 ──────────────────────────────────────────────────────────────────
V_F=$(cnt 'start_npm_service "frontend-dev"' "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh")
V_S=$(cnt 'start_npm_service "storybook-dev"' "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh")
DEBUG_18="\$ grep -nE 'start_npm_service \"(frontend-dev|storybook-dev)\"' frontend/tests/shellTest/Frontend-test-Dev.sh
$(grep -nE 'start_npm_service "(frontend-dev|storybook-dev)"' "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh" 2>/dev/null | head -2)"
R=0; [ "$V_F" -ge 1 ] && [ "$V_S" -ge 1 ] && R=1
check "CA_18" "setup_services levanta frontend-dev + storybook-dev" "1/1" "$V_F/$V_S" "$R" \
  "frontend/tests/shellTest/Frontend-test-Dev.sh → setup_services()" \
  "$DEBUG_18"

# ── CA_19 ──────────────────────────────────────────────────────────────────
V_FN=$(cnt '^verify_ports_released_after_cleanup()' "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh")
V_CALL=$(cnt 'verify_ports_released_after_cleanup' "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh")
DEBUG_19="\$ grep -n 'verify_ports_released_after_cleanup' frontend/tests/shellTest/Frontend-test-Dev.sh
$(grep -n "verify_ports_released_after_cleanup" "$FRONTEND/tests/shellTest/Frontend-test-Dev.sh" 2>/dev/null | head -3)"
R=0; [ "$V_FN" -ge 1 ] && [ "$V_CALL" -ge 2 ] && R=1
check "CA_19" "verify_ports_released_after_cleanup existe+llamado" "1/>=2" "$V_FN/$V_CALL" "$R" \
  "frontend/tests/shellTest/Frontend-test-Dev.sh → cleanup_on_exit()" \
  "$DEBUG_19"

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
