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
