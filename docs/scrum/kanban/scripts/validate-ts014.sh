#!/usr/bin/env bash
# validate-ts014.sh v2 — Validación TS-014 (#619) con captura corregida
set -uo pipefail

FRONTEND=/prog/datos/investment-tracker/frontend
DOCS=/prog/datos/investment-tracker/docs
README=/prog/datos/investment-tracker/README.md
ADR=$DOCS/tecnica/04-frontend-react-css-moderno/deuda-tecnica/exclusiones-cobertura-tests.md
PRUEBAS=$DOCS/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md
AGENTE=$DOCS/prompts/agente-frontend.md

PASS=0; FAIL=0; CONTRA=0

check() {
  local num="$1" title="$2" esperado="$3" obtenido="$4" verdict="$5"
  echo ""
  echo "══════════════════════════════════════════════════════════════════"
  echo "  CRITERIO $num — $title"
  echo "══════════════════════════════════════════════════════════════════"
  echo "  Esperado : $esperado"
  echo "  Obtenido : $obtenido"
  case "$verdict" in
    1) echo "  Resultado: ✅ APROBÓ";               PASS=$((PASS+1)) ;;
    2) echo "  Resultado: ⚠️  CONTRADICCIÓN";       CONTRA=$((CONTRA+1)) ;;
    *) echo "  Resultado: ❌ NO APROBÓ";           FAIL=$((FAIL+1)) ;;
  esac
}

cd "$FRONTEND"

# 1
V=$(jq -r '."devDependencies"."@axe-core/playwright" // "no instalado"' package.json)
[ "$V" = "4.14.0" ] && R=1 || R=0
check 1 "@axe-core/playwright pineado (--save-exact)" "4.14.0" "$V" "$R"

# 2
V=$(grep -c "export async function runA11y" tests/e2e/helpers/a11y.ts 2>/dev/null)
V=${V:-0}
[ "$V" -eq 1 ] && R=1 || R=0
check 2 "helper runA11y() en tests/e2e/helpers/a11y.ts" "1" "$V" "$R"

# 3
if [ -f tests/e2e/fixtures/mock-view.html ]; then V="existe"; else V="no existe"; fi
[ "$V" = "existe" ] && R=1 || R=0
check 3 "mockup accesible mock-view.html" "existe" "$V" "$R"

# 4
V=$(npx playwright test tests/e2e/a11y.spec.ts 2>&1 | grep -E "^\s+[0-9]+ passed" | grep -oE "[0-9]+ passed" | head -1)
[ "$V" = "7 passed" ] && R=1 || R=0
check 4 "test a11y.spec.ts verde en los 7 proyectos" "7 passed" "${V:-no detectado}" "$R"

# 5
V=$(grep -c "reducedMotion: 'reduce'" tests/e2e/a11y.spec.ts 2>/dev/null)
V=${V:-0}
[ "$V" -eq 1 ] && R=1 || R=0
check 5 "prefers-reduced-motion: reduce emulado en a11y.spec.ts" "1" "$V" "$R"

# 6
V=$(grep -c "wcag22aa" tests/e2e/helpers/a11y.ts 2>/dev/null)
V=${V:-0}
[ "$V" -eq 1 ] && R=1 || R=0
check 6 "tags WCAG 2.2 AA incluyen 'wcag22aa'" "1" "$V" "$R"

# 7 — CORREGIDO: sin `|| echo 0`, captura segura
V=$(grep -c "exclude:" tests/e2e/a11y.spec.ts 2>/dev/null)
V=${V:-0}
[ "$V" -eq 0 ] && R=1 || R=0
check 7 "sin exclusiones iniciales ('exclude:' no aparece en spec)" "0" "$V" "$R"

# 8
V=$(grep -c "testInfo.attach" tests/e2e/helpers/a11y.ts 2>/dev/null)
V=${V:-0}
[ "$V" -eq 2 ] && R=1 || R=0
check 8 "adjunta 2 reportes (HTML + JSON) vía testInfo.attach" "2" "$V" "$R"

# 9 — CORREGIDO: buscar "Beneficio" y "Riesgo" por separado (no en la misma línea)
B=$(grep -cE '\*\*Beneficio\*\*' "$PRUEBAS" 2>/dev/null)
B=${B:-0}
RI=$(grep -cE '\*\*Riesgo\*\*' "$PRUEBAS" 2>/dev/null)
RI=${RI:-0}
[ "$B" -ge 1 ] && [ "$RI" -ge 1 ] && R=1 || R=0
check 9 "pruebas.md documenta beneficio + riesgo de reduced-motion" "beneficio>=1, riesgo>=1" "beneficio=$B, riesgo=$RI" "$R"

# 10
V1=$(grep -c "### E2E a11y (Playwright + axe)" "$PRUEBAS" 2>/dev/null); V1=${V1:-0}
V2=$(grep -c "runA11y()" "$AGENTE" 2>/dev/null); V2=${V2:-0}
V3=$(grep -c "TS-138 (#743)" "$README" 2>/dev/null); V3=${V3:-0}
[ "$V1" -ge 1 ] && [ "$V2" -ge 1 ] && [ "$V3" -ge 1 ] && R=1 || R=0
check 10 "pruebas.md + agente-frontend.md + README con TS-138" "todos >=1" "pruebas=$V1, agente=$V2, README=$V3" "$R"

# 11
V1=$(grep -c "+ Playwright" "$ADR" 2>/dev/null); V1=${V1:-0}
V2=$(grep -c "TS-014 (#619)" "$ADR" 2>/dev/null); V2=${V2:-0}
V3=$(grep -c "TS-138 (#743)" "$ADR" 2>/dev/null); V3=${V3:-0}
V4=$(grep -c "US-041 (#605)" "$ADR" 2>/dev/null); V4=${V4:-0}
V5=$(grep -c "Añadir test a11y" "$ADR" 2>/dev/null); V5=${V5:-0}
[ "$V1" -ge 1 ] && [ "$V2" -ge 1 ] && [ "$V3" -ge 1 ] && [ "$V4" -ge 1 ] && [ "$V5" -ge 1 ] && R=1 || R=0
check 11 "ADR-0009 actualizado (PW, TS-014, TS-138, US-041, gatillo)" "todos >=1" "PW=$V1, TS014=$V2, TS138=$V3, US041=$V4, gatillo=$V5" "$R"

# 12 — CORREGIDO: capturar la línea "Tests  N passed" específicamente
V=$(npx vitest run 2>&1 | sed -E 's/\x1b\[[0-9;]*m//g' | grep -E "^ *Tests +[0-9]+ passed" | grep -oE "[0-9]+ passed" | head -1)
[ "$V" = "55 passed" ] && R=1 || R=0
check 12 "regresión Vitest (55 tests)" "55 passed" "${V:-no detectado}" "$R"

# 13
npx eslint tests/e2e/ >/dev/null 2>&1; L=$?
npx prettier --check "tests/e2e/**/*.ts" "tests/e2e/fixtures/mock-view.html" >/dev/null 2>&1; P=$?
npm run type-check >/dev/null 2>&1; T=$?
[ "$L" -eq 0 ] && [ "$P" -eq 0 ] && [ "$T" -eq 0 ] && R=1 || R=0
check 13 "regresión ESLint + Prettier + TypeScript" "todos exit 0" "eslint=$L, prettier=$P, ts=$T" "$R"

echo ""
echo "══════════════════════════════════════════════════════════════════"
echo "  RESUMEN GLOBAL — TS-014 (#619)"
echo "══════════════════════════════════════════════════════════════════"
echo "  Criterios aprobados      : $PASS"
echo "  Criterios NO aprobados   : $FAIL"
echo "  Criterios contradictorios: $CONTRA"
echo ""
if [ "$FAIL" -eq 0 ] && [ "$CONTRA" -eq 0 ]; then
  echo "  🟢 VEREDICTO GLOBAL: APROBÓ — todos los criterios verdes."
  echo "     Commit autorizado."
  exit 0
else
  echo "  🔴 VEREDICTO GLOBAL: NO APROBÓ — $FAIL fallido(s), $CONTRA contradictorio(s)."
  echo "     Commit bloqueado hasta corregir."
  exit 1
fi
