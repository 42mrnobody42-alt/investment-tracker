# Convenciones de Testing — Investment Tracker Pro

> **Fuente de verdad** de las reglas de testing del frontend.
> Versión inicial: 2026-10-17 (TS-012).
> Stack: **Vitest 5.0.5 + Testing Library + jsdom 30.1.3**.
> Referencias: `docs/prompts/agente-frontend.md` §14 (Testing) y §18 (DoD).

## Propósito

Definir las reglas **permanentes** con las que se escriben y ejecutan los tests
del frontend: framework, comandos, estructura de directorios, umbral de
cobertura, exclusiones permanentes y convenciones de escritura.

Las **deudas temporales** de cobertura (archivos excluidos que dejarán de estarlo)
viven en ADRs individuales, no aquí.

## Runner unificado (`Frontend-test-Dev.sh`)

### Qué es

`frontend/tests/shellTest/Frontend-test-Dev.sh` — runner en bash que ejecuta la totalidad de los tests y gates de calidad del frontend en un solo comando. **Gate obligatorio** antes de push, PR o merge (ver §Gate obligatorio).

### Por qué existe

Antes de centralizar, los tests vivían dispersos en scripts npm individuales y cada gate requería recordar su comando y umbral. El runner resuelve:

1. **Comando único** antes de push/PR/merge.
2. **Auto-fix pre-run** (Prettier → Stylelint → ESLint) que elimina falsos positivos de formato antes de evaluar.
3. **Clasificación 1:1** de warnings/errores contra `approved-warnings.txt`.
4. **Resumen clasificado** con códigos `[W-DOC]/[W-NEW]/[E-DOC]/[E-NEW]/[S-NNN]`.
5. **Toggles granular** por grupo o familia vía variables de entorno.
6. **Cleanup defensivo** con `setsid` (no cierra la terminal del usuario).

### Grupos ejecutados (12)

| #   | Grupo                 | Comando                                                       | Threshold `MIN_SUCCESSES` |
| --- | --------------------- | ------------------------------------------------------------- | ------------------------- |
| 1   | Auto-fi x pre-run     | Prettier → Stylelint → ESLint                                 | exit codes 0/0/0          |
| 2   | ESLint                | `npm run lint`                                                | 1                         |
| 3   | Stylelint             | `npm run lint:css`                                            | 1                         |
| 4   | Prettier              | `npm run format:check`                                        | 1                         |
| 5   | TypeScript            | `npm run type-check`                                          | 1                         |
| 6   | Vitest (unit)         | `npm run test:run`                                            | **55** (tests)            |
| 7   | Vite build            | `npm run build`                                               | 1                         |
| 8   | Storybook build       | `npm run build-storybook`                                     | 1                         |
| 9   | Servicios             | `npm run storybook` (setsid)                                  | setup + health check      |
| 10  | Playwright smoke      | `npx playwright test tests/e2e/smoke.spec.ts`                 | **14** (2×7 proyectos)    |
| 11  | Playwright a11y       | `npx playwright test tests/e2e/a11y.spec.ts`                  | **7** (1×7 proyectos)     |
| 12  | Storybook manager E2E | `npx playwright test --config playwright.storybook.config.ts` | **2** (solo desktop)      |

> Los thresholds son **exactos**: si un día se añade o quita un test, el runner falla intencionalmente hasta que se actualice `MIN_SUCCESSES`. Esto detecta cambios silenciosos en la suite.

### Árbol de control (`RUN_*`)

**Padres** (saltan el grupo completo + sus hijos):

| Variable       | Salta                                       |
| -------------- | ------------------------------------------- |
| `RUN_AUTOFIX`  | Auto-fix pre-run                            |
| `RUN_HOOKS`    | Git hooks (.husky/ estructura)              |
| `RUN_LINT`     | ESLint + Stylelint + Prettier               |
| `RUN_TYPES`    | TypeScript                                  |
| `RUN_UNIT`     | Vitest                                      |
| `RUN_BUILD`    | Vite build + Storybook build                |
| `RUN_E2E`      | Playwright smoke + a11y + Storybook manager |
| `RUN_SERVICES` | Setup manual de Storybook dev               |
| `RUN_CLEANUP`  | Cleanup al final (¡dejar en 1 salvo debug!) |

**Hijos** (saltan solo ese grupo dentro del padre):

| Variable                | Salta                      |
| ----------------------- | -------------------------- |
| `RUN_ESLINT`            | Solo ESLint                |
| `RUN_STYLELINT`         | Solo Stylelint             |
| `RUN_PRETTIER`          | Solo Prettier              |
| `RUN_TYPECHECK`         | Solo TypeScript            |
| `RUN_VITEST`            | Solo Vitest                |
| `RUN_VITE_BUILD`        | Solo Vite build            |
| `RUN_STORYBOOK_BUILD`   | Solo Storybook build       |
| `RUN_SMOKE`             | Solo Playwright smoke      |
| `RUN_A11Y`              | Solo Playwright a11y       |
| `RUN_STORYBOOK_MANAGER` | Solo Storybook manager E2E |

### Modos especiales

| Variable / flag     | Valor  | Efecto                                                                                                           |
| ------------------- | ------ | ---------------------------------------------------------------------------------------------------------------- |
| `DEBUG` / `--debug` | `1`    | Imprime output completo de cada grupo + logs `[DEBUG]`.                                                          |
| `ALLOW_NEW`         | `1`    | **Modo WIP**: exit 0 aunque haya `[W-NEW]/[E-NEW]`. NO autoriza push/merge.                                      |
| `STORYBOOK_PORT`    | número | Override puerto Storybook (default: leído de `package.json → scripts.storybook → -p <puerto>`). Fallback `3010`. |
| `FRONTEND_PORT`     | número | Override puerto Vite (default: leído de `vite.config.ts → server.port`). Fallback `3000`.                        |

### Recipes comunes

```bash
# Ejecutar todo (default)
bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Solo lint (sin autofix)
RUN_AUTOFIX=0 RUN_TYPES=0 RUN_UNIT=0 RUN_BUILD=0 RUN_E2E=0 RUN_SERVICES=0 \
  bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Solo tests unitarios
RUN_AUTOFIX=0 RUN_LINT=0 RUN_TYPES=0 RUN_BUILD=0 RUN_E2E=0 RUN_SERVICES=0 \
  bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Solo E2E (Playwright gestiona Storybook vía webServer)
RUN_AUTOFIX=0 RUN_LINT=0 RUN_TYPES=0 RUN_UNIT=0 RUN_BUILD=0 RUN_SERVICES=0 \
  bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Solo a11y
RUN_AUTOFIX=0 RUN_LINT=0 RUN_TYPES=0 RUN_UNIT=0 RUN_BUILD=0 RUN_SERVICES=0 \
  RUN_SMOKE=0 RUN_STORYBOOK_MANAGER=0 \
  bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Solo builds
RUN_AUTOFIX=0 RUN_LINT=0 RUN_TYPES=0 RUN_UNIT=0 RUN_E2E=0 RUN_SERVICES=0 \
  bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Solo Storybook manager E2E
RUN_AUTOFIX=0 RUN_LINT=0 RUN_TYPES=0 RUN_UNIT=0 RUN_BUILD=0 RUN_SERVICES=0 \
  RUN_SMOKE=0 RUN_A11Y=0 \
  bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Commit WIP (warnings nuevos permitidos, NO autoriza push/merge)
ALLOW_NEW=1 bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Debug completo (output de cada grupo)
DEBUG=1 bash frontend/tests/shellTest/Frontend-test-Dev.sh

# Setup manual de Storybook (en lugar de Playwright webServer)
RUN_SERVICES=1 bash frontend/tests/shellTest/Frontend-test-Dev.sh
```

### Estructura del resumen final (5 bloques)

```
── WARNINGS DOCUMENTADOS (N) ──
  [W-DOC-001] <grupo>
    ↳ Mensaje: "<texto>"
    ↳ Ref: <ruta doc> → <ID interno>

── WARNINGS NUEVOS (N) ──          (bloquea push/merge)
  [W-NEW-001] <grupo>
    ↳ Mensaje: <línea del output>

── ERRORES DOCUMENTADOS (N) ──
  [E-DOC-001] <grupo> ...

── ERRORES NUEVOS (N) ──           (bloquea push/merge)
  [E-NEW-001] <grupo> ...

── ÉXITOS (N) ──
  [S-001] <grupo> (exit=0 success=<N>) ...

── TOTALES ──
  ✅ PASS: N
  ⚠️  WARN: N documentados, N nuevos
  ❌ ERR:  N documentados, N nuevos
  ⏭️  SKIP: N
  📄 Log: <ruta>
```

### Exit codes

| Código | Situación                                                           |
| ------ | ------------------------------------------------------------------- |
| `0`    | Todo verde (0 `[W-NEW]` y 0 `[E-NEW]`), o `ALLOW_NEW=1` con nuevos. |
| `1`    | Al menos 1 `[W-NEW]` o `[E-NEW]` sin `ALLOW_NEW=1`.                 |
| `130`  | Interrumpido por Ctrl+C / SIGTERM.                                  |

### Logs

Un único log por ejecución: `logs/Frontend/Dev/Frontend-test-Dev_<timestamp>.log`. Incluye output completo de cada grupo, thresholds aplicados y resumen final. Cubierto por `.gitignore → logs/`, nunca se commitea.

### Gate obligatorio

El runner es el gate **obligatorio antes de push, PR o merge**. Sin exit 0:

- No se hace `git push origin`.
- No se abre PR a `developer`.
- No se hace merge a `developer`, `lastest` o `qa`.

**Commit WIP como checkpoint local**: se permite commit en la rama local con `ALLOW_NEW=1`. El mensaje de commit DEBE empezar con `[WIP]`. Este modo **NO autoriza push ni merge** — solo guarda un punto de retorno para no perder trabajo al resolver warnings.

**Flujo completo al detectar un warning/error nuevo**:

1. Ejecutar el runner y ver el nuevo.
2. Commit WIP con `ALLOW_NEW=1` (checkpoint).
3. Intentar resolver.
4. **Si se resuelve** → commit final + check verde sin `[WIP]`.
5. **Si no se puede resolver** → documentarlo en `approved-warnings.txt` con motivo (por qué se da, por qué no se pudo resolver, por qué se acepta) y commit final con `Closes #N`.

### Clasificación de warnings y errores

- `[W-DOC-NNN]` — documentado en `approved-warnings.txt` → no bloquea.
- `[W-NEW-NNN]` — no documentado → bloquea push/merge.
- `[E-DOC-NNN]` — error documentado → no bloquea.
- `[E-NEW-NNN]` — error nuevo → bloquea push/merge.

Cada item del output se evalúa 1:1 contra las entradas del registro por `group` + `pattern`.

### `approved-warnings.txt` — cómo añadir una entrada

Ubicación: `frontend/tests/shellTest/approved-warnings.txt`. Formato bloque:

```
[W-DOC-NNN]
category = warning
group    = <nombre exacto del grupo: eslint, stylelint, prettier, typescript, vitest, vite-build, storybook-build, storybook-manager, playwright-smoke, playwright-a11y>
ref      = <ruta del doc donde se justifica> → <ID interno del doc>
message  = "<texto legible para el resumen>"
pattern  = <regex ERE compatible con grep -E>
```

Reglas:

- **`pattern` debe ser específico** — si matchea cualquier línea genérica (`warning`, `error`) podrías ocultar problemas nuevos.
- **`ref` debe apuntar a un doc versionado** que explique por qué se acepta.
- **`group` debe coincidir exactamente** con el nombre del grupo en `run_check`. Si cambia, la entrada deja de matchear.
- Un warning/error solo se considera **DOCUMENTADO** si al menos una entrada del mismo `group` matchea su `pattern`.

### Cleanup defensivo

El setup manual de servicios (`RUN_SERVICES=1`) lanza procesos con `setsid` para desacoplarlos del TTY. El cleanup:

- **Solo** mata PIDs en `PIDS_LAUNCHED` verificados como líderes de process group.
- **Nunca** `pkill -P`, nunca `xargs kill`, nunca kill por puerto, nunca `kill -9` a procesos ajenos.
- **`check_ports_occupied()`** solo informa (nunca mata por coincidencia de puerto).
- Si el proceso lanzado no muere con `SIGTERM`, `SIGKILL` **solo** si sigue siendo líder de su propio group.

**Por qué `setsid`**: sin él, el proceso hijo queda en el process group del shell del usuario. Un `kill` mal dirigido (por puerto o por `pkill -P`) puede matar el árbol completo incluyendo la terminal del usuario. Con `setsid`, `kill -TERM -- "-<PGID>"` actúa solo sobre el subárbol del servicio.

### Grupo "Servicios locales"

`setup_services` levanta **ambos** servicios con `setsid` (desacoplado del TTY):

| Servicio        | Puerto                       | Health check            | Necesario para                              |
| --------------- | ---------------------------- | ----------------------- | ------------------------------------------- |
| `frontend-dev`  | `:3000` (o `FRONTEND_PORT`)  | `http://localhost:3000` | Playwright smoke + a11y + Storybook manager |
| `storybook-dev` | `:3010` (o `STORYBOOK_PORT`) | `http://localhost:3010` | Storybook manager E2E                       |

**Verificación de puertos**:

- **Antes** de levantar: `check_ports_occupied` — solo informa (no mata procesos ajenos).
- **Después** del cleanup: `verify_ports_released_after_cleanup` — confirma que `:3000` y `:3010` quedaron libres. Si un puerto sigue ocupado, se informa pero **NO se mata** (podría ser un proceso del usuario).

**Seguridad del cleanup**: solo se mata lo que el runner lanzó (`PIDS_LAUNCHED` con `setsid` verificado por process group). Nunca `pkill`, nunca `xargs kill`, nunca kill por puerto. `lsof -ti:port` no incluye la propia búsqueda (solo devuelve PIDs con el puerto abierto).

### Grupo "Servicios locales"

`setup_services` levanta **ambos** servicios con `setsid` (desacoplado del TTY):

| Servicio        | Puerto                       | Health check            | Necesario para                              |
| --------------- | ---------------------------- | ----------------------- | ------------------------------------------- |
| `frontend-dev`  | `:3000` (o `FRONTEND_PORT`)  | `http://localhost:3000` | Playwright smoke + a11y + Storybook manager |
| `storybook-dev` | `:3010` (o `STORYBOOK_PORT`) | `http://localhost:3010` | Storybook manager E2E                       |

**Verificación de puertos**:

- **Antes** de levantar: `check_ports_occupied` — solo informa (no mata procesos ajenos).
- **Después** del cleanup: `verify_ports_released_after_cleanup` — confirma que `:3000` y `:3010` quedaron libres. Si un puerto sigue ocupado, se informa pero **NO se mata** (podría ser un proceso del usuario).

**Seguridad del cleanup**: solo se mata lo que el runner lanzó (`PIDS_LAUNCHED` con `setsid` verificado por process group). Nunca `pkill`, nunca `xargs kill`, nunca kill por puerto. `lsof -ti:port` no incluye la propia búsqueda (solo devuelve PIDs con el puerto abierto).

### Grupo `RUN_HOOKS` — validación de estructura de hooks

Valida la **estructura** de `.husky/` (no el comportamiento) de los 3 hooks:

- `pre-commit`, `commit-msg`, `pre-push`: existencia + ejecutable (`chmod +x`) + `bash -n` sin errores.
- Rápido (<1 s): no ejecuta los hooks, solo verifica su estructura.
- Desactivable con `RUN_HOOKS=0` (solo debug). Por defecto activo.
- El **comportamiento real** del hook lo valida el propio `git commit` / `git push`, no el runner.

### Complemento: pre-commit vs runner manual

| Aspecto           | pre-commit                                    | runner manual                   |
| ----------------- | --------------------------------------------- | ------------------------------- |
| Cuándo se ejecuta | En cada `git commit`                          | Antes de push / PR / merge      |
| Velocidad         | <15 s                                         | 2-3 min                         |
| Scope             | `lint-staged` (solo staged) + `tsc -b` (todo) | 13 grupos completos             |
| Bloquea           | Lint no autofixeable + tipos rotos            | Cualquier `[W-NEW]` / `[E-NEW]` |
| Instancia         | Hook de git                                   | Comando manual / CI             |

Ambos son **obligatorios**. Pre-commit previene commits rotos; runner previene push/merge rotos. Ver `agente-frontend.md` §14.8 y `prompt_inicial.md` regla 33.

## Stack de testing

## Stack de testing

| Paquete                       | Versión | Rol                                                 |
| ----------------------------- | ------- | --------------------------------------------------- |
| `vitest`                      | 5.0.5   | Runner y framework de tests                         |
| `@vitest/coverage-v8`         | 5.0.5   | Provider de cobertura (v8)                          |
| `jsdom`                       | 30.1.3  | Entorno DOM simulado                                |
| `@testing-library/react`      | 16.3.3  | Render + queries de React                           |
| `@testing-library/dom`        | 10.4.2  | Utilidades DOM compartidas (peer de react)          |
| `@testing-library/jest-dom`   | 7.0.1   | Matchers (`toBeInTheDocument`, `toHaveClass`, etc.) |
| `@testing-library/user-event` | 14.6.8  | Simulación de interacción del usuario               |
| `@playwright/test`            | 1.64.1  | E2E: runner de Playwright con 7 proyectos           |

**Pineo exacto** (sin `^` ni `~`), coherente con `frontend/.npmrc` (`save-exact=true`).

## Comandos

| Comando                   | Uso                                               |
| ------------------------- | ------------------------------------------------- |
| `npm test`                | Modo watch (desarrollo).                          |
| `npm run test:run`        | Modo CI (una ejecución, sale con código).         |
| `npm run test:coverage`   | Ejecuta + genera reporte en `frontend/coverage/`. |
| `npm run test:e2e`        | Ejecuta Playwright E2E (7 proyectos).             |
| `npm run test:e2e:ui`     | Modo UI interactivo de Playwright.                |
| `npm run test:e2e:report` | Abre el último reporte HTML.                      |

`frontend/coverage/` está en `.gitignore`. **Nunca se commitea.**

## Estructura de directorios

- `frontend/vitest.config.ts` — configuración de Vitest (jsdom, coverage v8, thresholds).
- `frontend/tests/unit/setup.ts` — setup global: carga `@testing-library/jest-dom`, limpia el DOM entre tests, mockea APIs de jsdom (`matchMedia`, `ResizeObserver`, `IntersectionObserver`, `scrollTo`).
- `frontend/tests/unit/components/{atoms,molecules,organisms}/` — tests unitarios de componentes.
- `frontend/tests/unit/shared/` — tests unitarios de código transversal (hooks, utils, constants).
- `frontend/tests/integration/` — flujos de vista (login → home → consulta) cuando existan (TS-014+).
- `frontend/playwright.config.ts` — configuración de Playwright (7 proyectos, webServer, traces).
- `frontend/tests/e2e/helpers/` — fixtures y helpers E2E (`navigation.ts`, `fixtures.ts`).
- `frontend/tests/e2e/` — tests E2E (`*.spec.ts`).

## Configuración del tsconfig

`tests/` está incluido en `tsconfig.app.json` (`"include": ["src", "tests"]`).
`vitest.config.ts` está incluido en `tsconfig.node.json`.
Los alias `@app/*`, `@components/*`, `@views/*`, `@shared/*`, `@i18n/*`, `@styles/*`
se resuelven con `resolve.alias` explícito en `vitest.config.ts` (los tests viven
fuera de `src/`, por lo que `resolve.tsconfigPaths` no basta).

## Cobertura — regla global y por archivo

Se aplican **dos umbrales simultáneos** en las 4 métricas (Stmts, Branch, Funcs,
Lines):

1. **Global** (promedio del proyecto): **≥ 80%** en cada métrica.
2. **Por archivo**: **≥ 80%** en cada métrica.

Ambos umbrales están configurados en modo **`error`** en `vitest.config.ts`
(thresholds). Si no se cumple cualquiera de los dos, `npm run test:coverage` sale
con código distinto de 0 y **bloquea el CI**.

**Motivo de exigir el 80% por archivo además del global:** un archivo con 100% de
cobertura puede enmascarar otro con 0%. El 80% por archivo garantiza que **todo
código de negocio tiene tests razonables**, no solo el promedio.

## Exclusiones permanentes

Los siguientes archivos **nunca** se incluyen en el cómputo de cobertura
(`coverage.exclude` en `vitest.config.ts`). Su justificación es estructural, no
deuda.

| Archivo                | Motivo                                                                                                                                        |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/main.tsx`         | Entry point: ejecuta `createRoot().render()` como side effect de módulo. Testeable solo con hacks no estándar. Si falla, falla la app entera. |
| `src/**/*.stories.tsx` | Archivos de Storybook: renderizan las stories, no contienen lógica de negocio. Validación visual (Chromatic o equivalente en TS posterior).   |
| `src/**/*.types.ts`    | Solo tipos TypeScript. Sin código ejecutable.                                                                                                 |
| `src/**/index.ts`      | Barrel exports: re-exportan símbolos ya definidos. Testear el barrel es testear el módulo real.                                               |
| `src/vite-env.d.ts`    | Declaración de tipos de Vite. Solo tipos.                                                                                                     |

## Líneas con exclusión justificada

Algunas líneas concretas quedan por debajo del 100% branch y **NO** se tapan con
`/* v8 ignore */` ni con tests artificiales. Se documentan aquí:

| Archivo            | Línea | Código                         | Tipo      | Motivo                                                                                                       |
| ------------------ | ----- | ------------------------------ | --------- | ------------------------------------------------------------------------------------------------------------ |
| `DesignTokens.tsx` | 128   | `if (ref.current) {`           | Defensiva | `useRef` sobre `<span ref>` garantiza no-null en el primer `useEffect`.                                      |
| `DesignTokens.tsx` | 450   | `d={EASING_PATHS[name] ?? ''}` | Fallback  | Todos los tokens de `TOKENS.easings` están mapeados. El fallback solo se ejecuta con datos nuevos sin curva. |

**Regla:** estas entradas se actualizan si el código cambia. Si la línea
desaparece, se elimina del listado. Si aparece una línea nueva con la misma
justificación, se añade.

## E2E (Playwright)

E2E de la app en 7 configuraciones de dispositivo, cubriendo desktop, 3 móviles (Android e iOS), tablet y TV (FHD y 4K).

**Stack:** `@playwright/test@1.64.1` (pineado con `--save-exact`).

### Proyectos configurados

| Proyecto         | Engine   | Viewport    | dpr  | Touch | Dispositivo objetivo   |
| ---------------- | -------- | ----------- | ---- | ----- | ---------------------- |
| `mobile-chrome`  | Chromium | 393 × 873   | 2.75 | Sí    | Infinix GT 30 Pro      |
| `mobile-android` | Chromium | 393 × 873   | 2.75 | Sí    | Xiaomi Redmi Note 14   |
| `mobile-safari`  | WebKit   | 393 × 852   | 3    | Sí    | iPhone 14 Pro (preset) |
| `tablet`         | Chromium | 768 × 1024  | 2    | Sí    | iPad portrait          |
| `desktop`        | Chromium | 1920 × 1080 | 1    | No    | Desktop                |
| `tv-fhd`         | Chromium | 1920 × 1080 | 1    | No    | Smart TV FHD           |
| `tv-4k`          | Chromium | 3840 × 2160 | 2    | No    | Smart TV 4K            |

### Traces y screenshots

- `trace: 'on-first-retry'` — trace solo en el primer reintento del test fallido.
- `screenshot: 'only-on-failure'` — screenshot solo si el test falla.
- `video: 'retain-on-failure'` — video solo si falla.

Artefactos en `test-results/` y `playwright-report/` (ambos en `.gitignore`).

### Estructura

- `playwright.config.ts` — 7 proyectos, webServer, traces, screenshots.
- `tests/e2e/helpers/navigation.ts` — `gotoHome(page)`: navega + espera SPA + valida 200.
- `tests/e2e/helpers/fixtures.ts` — `test` extendido con `homeReady`.
- `tests/e2e/*.spec.ts` — tests por dominio.

### WebServer

Playwright levanta Vite automáticamente (`npm run dev` en `localhost:3000`). Fuera de CI, reusa servidor existente.

### Requisitos del sistema

- Navegadores: `npx playwright install chromium webkit`.
- En Linux (Pop!_OS / Ubuntu 22.04): `sudo apt-get install -y libevent-2.1-7 libavif13` para WebKit.

### Smoke tests y evolución

En `tests/e2e/smoke.spec.ts`:

- Frontend: `GET /` → 200 + título visible.
- Health endpoint: mock vía `page.route('**/api/test/health')`. Marcado con TODO.

A medida que se publiquen endpoints (README §"Tabla de Endpoints publicados"), se añadirán más smoke tests. **TS-122 (#727)** reemplazará el mock del health por una llamada real.

---

### E2E a11y (Playwright + axe)

Auditoría automatizada WCAG 2.2 AA en tests E2E, vía `@axe-core/playwright@4.14.0`.

- Helper: `frontend/tests/e2e/helpers/a11y.ts` → `runA11y(page, options?, testInfo?)`.
- Tags por defecto: `['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa']`.
- Sin exclusiones por defecto. Si un elemento del mockup falla, **se corrige el mockup**, no se relaja el test. Toda exclusión debe justificarse en un comentario del propio test.
- Falla con lista de reglas violadas + adjunta `axe-report.html` y `axe-raw.json` al reporte de Playwright (`testInfo.attach`).
- Test base: `frontend/tests/e2e/a11y.spec.ts` escanea `tests/e2e/fixtures/mock-view.html` (mockup accesible de una vista) en los **7 proyectos**.

**`prefers-reduced-motion: reduce` (beneficio + riesgo).**

Todo test a11y emula `prefers-reduced-motion: reduce` vía `page.emulateMedia({ reducedMotion: 'reduce' })`.

- **Beneficio**: valida WCAG 2.3.3 (Animation from Interactions) — la UI debe ser usable con animaciones desactivadas. Previene regresiones silenciosas cuando se añaden animaciones que dependen del motion para transmitir estado (opacidad en 0 sin la animación → contraste/visibilidad rotos).
- **Riesgo**: puede detectar violaciones "falsas" si el CSS está mal escrito (ej. `transition: opacity` que deja el elemento en `0` sin el effect). En ese caso se corrige el CSS, no se relaja el test ni se excluye la regla.

**Evolución.** TS-138 (#743) reemplaza el mockup por navegación real a las vistas de US-024/025 y añade un test a11y por vista construida. El helper `runA11y()` se reutiliza sin cambios.

## Convenciones de escritura

- **Un archivo `*.test.{ts,tsx}` por unidad bajo prueba.** Mismo nombre que el
  archivo fuente.
- **`describe`** por componente/módulo, **`it`** por comportamiento observable.
- **Nombres de tests en español**, describiendo el comportamiento
  (`it('renderiza los children', ...)`), no la implementación.
- **Queries por rol** (`getByRole`, `getAllByRole`) por defecto. Solo usar
  `getByTestId` si no hay rol semántico.
- **`getAllByText`** cuando el texto aparece más de una vez en el DOM. `getByText`
  solo para ocurrencias únicas.
- **`userEvent`** en lugar de `fireEvent` para interacciones de usuario.
- **`it.each`** para casos parametrizados (variantes, tamaños, estados) — evita
  duplicación de `it`s.
- **Mocks de APIs de navegador** van en `tests/unit/setup.ts`, no en cada test.

## Mocks de navegador (setup.ts)

`tests/unit/setup.ts` mockea las APIs que jsdom no implementa por defecto:

- `window.matchMedia` (usado por responsive y motion).
- `globalThis.ResizeObserver`.
- `globalThis.IntersectionObserver`.
- `window.scrollTo`.

Añadir nuevos mocks **solo** cuando un test lo requiera, no de forma preventiva.

## Alineación con el backend

Los mocks de respuestas HTTP se alinean con los **DTO reales** documentados en
`README.md` (sección "Tabla de Endpoints publicados") y en el código del backend.
Nunca se inventan campos ni códigos de error.

## Reglas adicionales

- **Cobertura nunca se baja** sin justificación en ADR.
- **`coverage/` no se commitea**. Está en `.gitignore`.
- **`npm audit fix --force`** y **`--legacy-peer-deps`** siguen prohibidos
  (ver ADR-0004). Las vulnerabilidades aceptadas se documentan en
  `seguridad/cvss-deuda-seguridad.md`.

## Referencias

- `docs/prompts/agente-frontend.md` §14 (Testing) y §18 (DoD).
- `frontend/vitest.config.ts` — configuración.
- `frontend/tests/unit/setup.ts` — setup global.
- ADR-0009 — exclusión temporal de `App.tsx` (se resuelve en US-024/025).
- ADR-0004 — política de vulnerabilidades aceptadas.
