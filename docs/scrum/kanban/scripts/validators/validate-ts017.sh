#!/usr/bin/env bash
# ============================================================================
# validate-ts017.sh — Validación TS-017 (#622) commitlint + commit-msg
# Invocado por ../validate-task-in-kanban.sh <issue-number>
# Env vars heredadas: ISSUE_NUM, TS_CODE, LOG_FILE
# ============================================================================
set -uo pipefail

REPO="/prog/datos/investment-tracker"
FRONTEND="$REPO/frontend"
ISSUE_NUM="${ISSUE_NUM:-622}"
TS_CODE="${TS_CODE:-TS-017}"

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

# Helper: probar commitlint con un mensaje. Devuelve exit code.
test_commitlint_msg() {
  local msg="$1"
  local tmp
  tmp=$(mktemp)
  echo "$msg" > "$tmp"
  ( cd "$FRONTEND" && npx commitlint --edit "$tmp" >/dev/null 2>&1 )
  local rc=$?
  rm -f "$tmp"
  return $rc
}

# ── CA_01 — commitlint pineado ─────────────────────────────────────────────
V_CLI=$(jq -r '.devDependencies["@commitlint/cli"] // "no"' "$FRONTEND/package.json")
V_CFG=$(jq -r '.devDependencies["@commitlint/config-conventional"] // "no"' "$FRONTEND/package.json")
DEBUG_01="\$ jq -r '.devDependencies[\"@commitlint/cli\"], .devDependencies[\"@commitlint/config-conventional\"]' frontend/package.json
$(jq -r '.devDependencies["@commitlint/cli"], .devDependencies["@commitlint/config-conventional"]' "$FRONTEND/package.json" 2>/dev/null)"
R=0; [ "$V_CLI" = "21.2.4" ] && [ "$V_CFG" = "21.2.4" ] && R=1
check "CA_01" "commitlint + config-conventional 21.2.4 pineados" "21.2.4/21.2.4" "$V_CLI/$V_CFG" "$R" \
  "frontend/package.json → devDependencies" \
  "$DEBUG_01"

# ── CA_02 — commitlint.config.js existe + ESM + lint ───────────────────────
E=0; ESM=0
[ -f "$FRONTEND/commitlint.config.js" ] && E=1
node -e 'import("'"$FRONTEND"'/commitlint.config.js").then(() => process.exit(0)).catch(() => process.exit(1))' 2>/dev/null && ESM=1
DEBUG_02="\$ ls -la frontend/commitlint.config.js
$(ls -la "$FRONTEND/commitlint.config.js" 2>/dev/null)
\$ node -e 'import(\"./commitlint.config.js\")'
ESM_LOAD=$([ "$ESM" -eq 1 ] && echo '✅ OK' || echo '❌ FALLÓ')"
R=0; [ "$E" -eq 1 ] && [ "$ESM" -eq 1 ] && R=1
check "CA_02" "commitlint.config.js existe + ESM válido" "1/1" "$E/$ESM" "$R" \
  "frontend/commitlint.config.js" \
  "$DEBUG_02"

# ── CA_03 — commitlint.config.d.ts existe con types ────────────────────────
E=0; HP=0; TE=0
[ -f "$FRONTEND/commitlint.config.d.ts" ] && E=1
HP=$(cnt "headerPattern" "$FRONTEND/commitlint.config.d.ts")
TE=$(cnt "type-enum" "$FRONTEND/commitlint.config.d.ts")
DEBUG_03="\$ ls -la frontend/commitlint.config.d.ts
$(ls -la "$FRONTEND/commitlint.config.d.ts" 2>/dev/null)
\$ grep -c 'headerPattern\|type-enum' frontend/commitlint.config.d.ts
headerPattern: $HP | type-enum: $TE"
R=0; [ "$E" -eq 1 ] && [ "$HP" -ge 1 ] && [ "$TE" -ge 1 ] && R=1
check "CA_03" "commitlint.config.d.ts con headerPattern + type-enum" "1/>=1/>=1" "$E/$HP/$TE" "$R" \
  "frontend/commitlint.config.d.ts" \
  "$DEBUG_03"

# ── CA_04 — headerPattern custom ───────────────────────────────────────────
HP_CONFIG=$(grep -oE 'headerPattern: /\^.*\$/' "$FRONTEND/commitlint.config.js" 2>/dev/null | head -1)
DEBUG_04="\$ grep 'headerPattern' frontend/commitlint.config.js
$(grep -n "headerPattern" "$FRONTEND/commitlint.config.js" 2>/dev/null | head -2)"
R=0; [ -n "$HP_CONFIG" ] && R=1
check "CA_04" "headerPattern custom documentado" "presente" "${HP_CONFIG:-no encontrado}" "$R" \
  "frontend/commitlint.config.js → parserPreset.parserOpts" \
  "$DEBUG_04"

# ── CA_05 — .husky/commit-msg ──────────────────────────────────────────────
E=0; X=0; H=0
[ -f "$FRONTEND/.husky/commit-msg" ] && E=1
[ -x "$FRONTEND/.husky/commit-msg" ] && X=1
grep -q "commitlint --edit" "$FRONTEND/.husky/commit-msg" 2>/dev/null && H=1
M=$(git -C "$REPO" ls-files --stage frontend/.husky/commit-msg 2>/dev/null | awk '{print $1}')
[ -z "$M" ] && M="(untracked)"
DEBUG_05="\$ ls -la frontend/.husky/commit-msg
$(ls -la "$FRONTEND/.husky/commit-msg" 2>/dev/null)
\$ cat frontend/.husky/commit-msg
$(cat "$FRONTEND/.husky/commit-msg" 2>/dev/null)
\$ git ls-files --stage frontend/.husky/commit-msg
$(git -C "$REPO" ls-files --stage frontend/.husky/commit-msg 2>/dev/null)"
# CA_05: se ejecuta ANTES del commit. Si está untracked, es normal (el archivo
# se valida en disco, aún no commiteado). Si ya está en git, debe tener
# mode 100755 (para detectar chmod accidental que rompa el hook).
if [ "$E" -eq 1 ] && [ "$X" -eq 1 ] && [ "$H" -eq 1 ]; then
  if [ "$M" = "100755" ] || [ "$M" = "(untracked)" ]; then
    R=1
  else
    R=0
  fi
else
  R=0
fi
check "CA_05" "commit-msg existe+ejecutable+invoca commitlint" "1/1/1" "$E/$X/$H (mode: $M)" "$R" "frontend/.husky/commit-msg (mode en git: $M)" "$DEBUG_05"

# ── CA_06..CA_13 — behavior tests (CLI real) ───────────────────────────────

# CA_06: feat(#620): algo → válido
test_commitlint_msg "feat(#620): agregar runner unificado"; EX=$?
DEBUG_06="\$ echo 'feat(#620): agregar runner unificado' > /tmp/msg.txt
\$ commitlint --edit /tmp/msg.txt
exit=$EX $([ $EX -eq 0 ] && echo '(aprobado)' || echo '(rechazado)')"
R=0; [ "$EX" -eq 0 ] && R=1
check "CA_06" "feat(#620): algo → válido" "exit=0" "exit=$EX" "$R" \
  "commitlint CLI (mensaje real)" \
  "$DEBUG_06"

# CA_07: fix(#123)!: breaking → válido
test_commitlint_msg "fix(#123)!: romper compatibilidad de la API"; EX=$?
DEBUG_07="\$ echo 'fix(#123)!: romper compatibilidad de la API' > /tmp/msg.txt
\$ commitlint --edit /tmp/msg.txt
exit=$EX"
R=0; [ "$EX" -eq 0 ] && R=1
check "CA_07" "fix(#123)!: breaking → válido" "exit=0" "exit=$EX" "$R" \
  "commitlint CLI (breaking change con issue)" \
  "$DEBUG_07"

# CA_08: chore: bump deps → válido
test_commitlint_msg "chore: bumpear dependencias"; EX=$?
DEBUG_08="\$ echo 'chore: bumpear dependencias' > /tmp/msg.txt
\$ commitlint --edit /tmp/msg.txt
exit=$EX"
R=0; [ "$EX" -eq 0 ] && R=1
check "CA_08" "chore: bump deps → válido (sin issue)" "exit=0" "exit=$EX" "$R" \
  "commitlint CLI (commit sin issue)" \
  "$DEBUG_08"

# CA_09: feat!: x → válido
test_commitlint_msg "feat!: breaking change sin issue"; EX=$?
DEBUG_09="\$ echo 'feat!: breaking change sin issue' > /tmp/msg.txt
\$ commitlint --edit /tmp/msg.txt
exit=$EX"
R=0; [ "$EX" -eq 0 ] && R=1
check "CA_09" "feat!: x → válido (breaking sin issue)" "exit=0" "exit=$EX" "$R" \
  "commitlint CLI (breaking change sin issue)" \
  "$DEBUG_09"

# CA_10: Merge pull request → válido (ignore)
test_commitlint_msg "Merge pull request #773 from feature/test"; EX=$?
DEBUG_10="\$ echo 'Merge pull request #773 from feature/test' > /tmp/msg.txt
\$ commitlint --edit /tmp/msg.txt
exit=$EX (defaultIgnores)"
R=0; [ "$EX" -eq 0 ] && R=1
check "CA_10" "Merge pull request → válido (defaultIgnores)" "exit=0" "exit=$EX" "$R" \
  "commitlint CLI (merge commit ignorado)" \
  "$DEBUG_10"

# CA_11: update stuff → rechazado
test_commitlint_msg "update stuff"; EX=$?
DEBUG_11="\$ echo 'update stuff' > /tmp/msg.txt
\$ commitlint --edit /tmp/msg.txt
exit=$EX (rechazado = correcto)"
R=0; [ "$EX" -ne 0 ] && R=1
check "CA_11" "update stuff → rechazado (sin tipo)" "exit!=0" "exit=$EX" "$R" \
  "commitlint CLI (mensaje inválido)" \
  "$DEBUG_11"

# CA_12: feature(#1): algo → rechazado
test_commitlint_msg "feature(#1): agregar"; EX=$?
DEBUG_12="\$ echo 'feature(#1): agregar' > /tmp/msg.txt
\$ commitlint --edit /tmp/msg.txt
exit=$EX (rechazado = correcto)"
R=0; [ "$EX" -ne 0 ] && R=1
check "CA_12" "feature(#1): algo → rechazado (tipo no permitido)" "exit!=0" "exit=$EX" "$R" \
  "commitlint CLI (type no en type-enum)" \
  "$DEBUG_12"

# CA_13: feat(): algo → rechazado
test_commitlint_msg "feat(): agregar"; EX=$?
DEBUG_13="\$ echo 'feat(): agregar' > /tmp/msg.txt
\$ commitlint --edit /tmp/msg.txt
exit=$EX (rechazado = correcto)"
R=0; [ "$EX" -ne 0 ] && R=1
check "CA_13" "feat(): algo → rechazado (paréntesis vacío)" "exit!=0" "exit=$EX" "$R" \
  "commitlint CLI (header inválido)" \
  "$DEBUG_13"

# ── CA_14 — commitlint.test.ts existe ──────────────────────────────────────
E=0; HP=0; TE=0
[ -f "$FRONTEND/tests/unit/configs/commitlint.test.ts" ] && E=1
HP=$(cnt "headerPattern.test" "$FRONTEND/tests/unit/configs/commitlint.test.ts")
TE=$(cnt "type-enum" "$FRONTEND/tests/unit/configs/commitlint.test.ts")
DEBUG_14="\$ ls -la frontend/tests/unit/configs/commitlint.test.ts
$(ls -la "$FRONTEND/tests/unit/configs/commitlint.test.ts" 2>/dev/null)
\$ grep -c 'headerPattern.test\|type-enum' frontend/tests/unit/configs/commitlint.test.ts
headerPattern.test: $HP | type-enum: $TE"
R=0; [ "$E" -eq 1 ] && [ "$HP" -ge 1 ] && [ "$TE" -ge 1 ] && R=1
check "CA_14" "commitlint.test.ts con headerPattern + type-enum" "1/>=1/>=1" "$E/$HP/$TE" "$R" \
  "frontend/tests/unit/configs/commitlint.test.ts" \
  "$DEBUG_14"

# ── CA_15 — tests pasan ────────────────────────────────────────────────────
TEST_OUT=$(cd "$FRONTEND" && npx vitest run tests/unit/configs/commitlint.test.ts 2>&1 | sed -E 's/\x1b\[[0-9;]*m//g')
PASSED=$(echo "$TEST_OUT" | grep -oE "Tests +[0-9]+ passed" | tail -1 | grep -oE "[0-9]+" | head -1)
PASSED="${PASSED:-0}"
DEBUG_15="\$ vitest run tests/unit/configs/commitlint.test.ts
$(echo "$TEST_OUT" | grep -E "Test Files|Tests " | head -2)"
R=0; [ "$PASSED" -ge 26 ] && R=1
check "CA_15" "tests unitarios commitlint pasan (>=26)" ">=26 passed" "$PASSED passed" "$R" \
  "vitest — tests/unit/configs/commitlint.test.ts" \
  "$DEBUG_15"

# ── CA_16 — RUN_HOOKS 2/2 ──────────────────────────────────────────────────
LATEST_LOG=$(ls -t "$REPO/logs/Frontend/Dev/Frontend-test-Dev_"*.log 2>/dev/null | head -1)
if [ -n "$LATEST_LOG" ]; then
  HOOKS_LINE=$(sed -E 's/\x1b\[[0-9;]*m//g' "$LATEST_LOG" 2>/dev/null | grep -E "Git hooks.*válidos" | head -1)
else
  HOOKS_LINE=""
fi
DEBUG_16="\$ grep 'Git hooks.*válidos' $LATEST_LOG
${HOOKS_LINE:-no encontrado}"
R=0; echo "$HOOKS_LINE" | grep -q "2/2 válidos" && R=1
check "CA_16" "RUN_HOOKS reporta 2/2 válidos" "2/2 válidos" "${HOOKS_LINE:-no encontrado}" "$R" \
  "$LATEST_LOG (grupo Git hooks)" \
  "$DEBUG_16"

# ── CA_17 — runner verde ───────────────────────────────────────────────────
if [ -n "$LATEST_LOG" ]; then
  GREEN=$(sed -E 's/\x1b\[[0-9;]*m//g' "$LATEST_LOG" 2>/dev/null | grep -c "TODO VERDE" | head -1)
  GREEN="${GREEN:-0}"
  DEBUG_17="\$ grep 'TODO VERDE' $(basename "$LATEST_LOG")
$(sed -E 's/\x1b\[[0-9;]*m//g' "$LATEST_LOG" 2>/dev/null | grep "TODO VERDE" | head -1)"
  R=0; [ "$GREEN" -ge 1 ] && R=1
  check "CA_17" "runner sigue verde" "verde" "$( [ "$GREEN" -ge 1 ] && echo 'verde' || echo 'rojo' )" "$R" \
    "$LATEST_LOG" \
    "$DEBUG_17"
else
  check "CA_17" "runner sigue verde" "verde" "(sin log)" 0 "logs/Frontend/Dev/Frontend-test-Dev_*.log" "(no hay log)"
fi

# ── CA_18..CA_22 — documentación ───────────────────────────────────────────

# CA_18: README headerPattern
V=$(cnt "HeaderPattern (validado por" "$REPO/README.md")
DEBUG_18="\$ grep -n 'HeaderPattern (validado por' README.md
$(grep -n "HeaderPattern (validado por" "$REPO/README.md" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_18" "README documenta headerPattern" ">=1" "$V" "$R" \
  "README.md §Reglas de commits" \
  "$DEBUG_18"

# CA_19: prompt_inicial regla 35
V=$(cnt "^35\. \*\*Formato de commit" "$REPO/docs/prompts/prompt_inicial.md")
DEBUG_19="\$ grep -n '35. Formato de commit' docs/prompts/prompt_inicial.md
$(grep -n "^35\. \*\*Formato de commit" "$REPO/docs/prompts/prompt_inicial.md" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_19" "prompt_inicial regla 35 (formato commit)" ">=1" "$V" "$R" \
  "docs/prompts/prompt_inicial.md (regla 35)" \
  "$DEBUG_19"

# CA_20: agente-frontend §14.9
V=$(cnt "^### 14\.9 commitlint" "$REPO/docs/prompts/agente-frontend.md")
DEBUG_20="\$ grep -n '### 14.9 commitlint' docs/prompts/agente-frontend.md
$(grep -n "^### 14\.9 commitlint" "$REPO/docs/prompts/agente-frontend.md" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_20" "agente-frontend §14.9 commitlint" ">=1" "$V" "$R" \
  "docs/prompts/agente-frontend.md §14.9" \
  "$DEBUG_20"

# CA_21: convenciones bullet commitlint
V=$(cnt "^- \*\*Commitlint\*\*" "$REPO/docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md")
DEBUG_21="\$ grep -n 'Commitlint' docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md
$(grep -n "^- \*\*Commitlint\*\*" "$REPO/docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md" 2>/dev/null | head -2)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_21" "convenciones bullet commitlint" ">=1" "$V" "$R" \
  "docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md §6" \
  "$DEBUG_21"

# CA_22: pruebas.md Runner vs Validador + tests config
V=$(cnt "^## Runner vs Validador" "$REPO/docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md")
DEBUG_22="\$ grep -n 'Runner vs Validador\|commitlint.test.ts' docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md
$(grep -nE "Runner vs Validador|commitlint.test.ts" "$REPO/docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md" 2>/dev/null | head -3)"
R=0; [ "$V" -ge 1 ] 2>/dev/null && R=1
check "CA_22" "pruebas.md documenta Runner vs Validador + tests config" ">=1" "$V" "$R" \
  "docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md" \
  "$DEBUG_22"

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
