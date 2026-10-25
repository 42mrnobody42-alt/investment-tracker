# Convenciones del Frontend

> Documento de convenciones de código del frontend.
> Fuente principal de reglas: [`docs/prompts/agente-frontend.md`](../../../prompts/agente-frontend.md).
> Este documento profundiza con ejemplos y estructura esperada.

## 1. Nombres

| Elemento               | Convención                  | Ejemplo              |
| ---------------------- | --------------------------- | -------------------- |
| Componentes            | PascalCase `.tsx`           | `Button.tsx`         |
| Hooks                  | camelCase con prefijo `use` | `useDebounce.ts`     |
| Utilidades             | camelCase                   | `classNames.ts`      |
| Servicios              | camelCase + `.service`      | `auth.service.ts`    |
| Tipos                  | PascalCase + `.types`       | `Button.types.ts`    |
| Tests                  | PascalCase + `.test`        | `Button.test.tsx`    |
| Stories                | PascalCase + `.stories`     | `Button.stories.tsx` |
| CSS Modules            | PascalCase + `.module.css`  | `Button.module.css`  |
| Carpetas de componente | PascalCase                  | `Button/`            |
| Carpetas de dominio    | kebab-case                  | `init-page/`         |
| Clases CSS             | camelCase                   | `.buttonPrimary`     |
| Constantes             | UPPER_SNAKE_CASE            | `ASSETS`             |
| Alias de import        | `@` + minúscula             | `@app`, `@shared`    |

## 2. Exports

- **Named exports** para todo (componentes, hooks, utilidades, tipos).
- **Default export solo** en vistas de ruta (`LoginView.tsx`, `HomeView.tsx`).
- **Barrel exports** (`index.ts`) en carpetas de componente para agrupar.

Ejemplo:

```ts
// Button/index.ts
export { Button } from "./Button";
export type { ButtonProps, ButtonSize, ButtonVariant } from "./Button.types";
```

## 3. Estructura interna de un componente

Orden obligatorio dentro del archivo:

1. Imports (ordenados por `simple-import-sort`).
2. Tipos e interfaces locales.
3. Constantes del módulo.
4. Componente principal.
5. Sub-componentes (si aplica).
6. Export.

Tamaño máximo por archivo: **~200 líneas**. Si excede, dividir.

## 4. Ejemplos por tipo

### 4.1 Componente (`components/atoms/Button/Button.tsx`)

```tsx
import type { ButtonProps } from "./Button.types";

import styles from "./Button.module.css";

export function Button({
  variant = "primary",
  size = "md",
  ...rest
}: ButtonProps) {
  const classes = [styles.button, styles[variant], styles[size]]
    .filter(Boolean)
    .join(" ");
  return <button className={classes} {...rest} />;
}
```

Ver también: [`componentes/atoms/button.md`](../componentes/atoms/button.md).

### 4.2 Hook (`shared/hooks/useDebounce.ts`)

```ts
import { useEffect, useState } from "react";

export function useDebounce<T>(value: T, delayMs: number): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), delayMs);
    return () => clearTimeout(id);
  }, [value, delayMs]);

  return debounced;
}
```

### 4.3 Servicio (`shared/services/auth.service.ts`)

```ts
import type { LoginRequest, LoginResponse } from "@shared/types/api.types";
import { http } from "@shared/utils/http";

export async function login(payload: LoginRequest): Promise<LoginResponse> {
  const { data } = await http.post<LoginResponse>("/api/auth/login", payload);
  return data;
}
```

### 4.4 Vista (`views/horizontal/login/LoginView.tsx`)

```tsx
export default function LoginView() {
  return <h1>Login</h1>;
}
```

### 4.5 Constantes (`shared/constants/assets.ts`)

```ts
export const ASSETS = {
  HERO: "/assets/images/starter/hero.png",
} as const;
```

## 5. Reglas adicionales

- **Sin `any`**. Usar `unknown` + narrowing.
- **Sin colores hardcodeados** fuera de `styles/tokens.css` (ver [ADR-0002](../deuda-tecnica/stylelint-scope-y-colores.md)).
- **Sin `!important`** (Stylelint lo bloquea).
- **Sin textos hardcodeados**: usar i18n (`t('namespace.key')`).
- **CSS Modules** para todo estilo de componente. Sin estilos inline salvo valores dinámicos calculados en runtime.
- **Alias obligatorios** para imports internos: `@app`, `@components`, `@views`, `@shared`, `@i18n`, `@styles`.
- **Commits** con formato `tipo(#N): descripción`. Referenciar el issue con `Closes #N` o `Refs #N`.

## 6. Pruebas

- **Runner unificado**: `frontend/tests/shellTest/Frontend-test-Dev.sh` centraliza ESLint, Stylelint, Prettier, TypeScript, Vitest, Playwright (smoke + a11y), Vite build y Storybook build. Resumen clasificado en `[W-DOC]`/`[W-NEW]`/`[E-DOC]`/`[E-NEW]`/`[S-NNN]`. Warnings/errores nuevos bloquean push/merge (no commit WIP). Detalle en [`pruebas.md`](./pruebas.md).

- **Unitarias + integración**: **Vitest 5.0.5** + **Testing Library** (`@testing-library/react` 16.3.3, `jest-dom` 7.0.1, `user-event` 14.6.8, `dom` 10.4.2) + `jsdom` 30.1.3. Cobertura mínima **80% en Stmts, Branch, Funcs y Lines**, global y por archivo (modo `error`). **55 tests** en 3 archivos. Configuración: `frontend/vitest.config.ts`. Setup: `frontend/tests/unit/setup.ts`.
- **E2E**: **Playwright 1.64.1** con **7 proyectos** (`mobile-chrome`, `mobile-android`, `mobile-safari`, `tablet`, `desktop`, `tv-fhd`, `tv-4k`). Configuración: `frontend/playwright.config.ts`. Traces `on-first-retry`, screenshots `only-on-failure`, video `retain-on-failure`. **2 tests × 7 proyectos = 14 ejecuciones** (`tests/e2e/smoke.spec.ts`).
- **a11y**: **`@axe-core/playwright` 4.14.0** + helper `runA11y()` en `frontend/tests/e2e/helpers/a11y.ts`. Tags WCAG 2.2 AA (`wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`, `wcag22aa`). Test base sobre `frontend/tests/e2e/fixtures/mock-view.html` en los 7 proyectos (`tests/e2e/a11y.spec.ts`). Aplicación a todas las vistas reales: **TS-138 (#743)**.
- **Stack de build**: Vite 8.3.4 (`npm run build`), TypeScript 6.0.2 (`npm run type-check`).
- **Comandos**:
  - `npm test` — Vitest en modo watch.
  - `npm run test:run` — Vitest modo CI.
  - `npm run test:coverage` — Vitest + reporte de cobertura en `frontend/coverage/`.
  - `npm run test:e2e` — Playwright (7 proyectos).
  - `npm run test:e2e:ui` — Playwright modo UI interactivo.
  - `npm run test:e2e:report` — Abre el último reporte HTML de Playwright.
- **Exclusión temporal de cobertura**: `src/app/App.tsx` (starter demo de Vite). Ver [ADR-0009](../deuda-tecnica/exclusiones-cobertura-tests.md). Se resuelve en **TS-146 (#769)** (sub-issue de US-024).

## 7. ADRs activos (deudas técnicas)

Los ADRs del frontend viven en [`../deuda-tecnica/`](../deuda-tecnica/). Registran **deudas técnicas pendientes** (no decisiones arquitectónicas permanentes). Al resolverse, el ADR se elimina y la documentación migra al archivo correspondiente.

| ADR                                                             | Título                                                            | Estado       | Se resuelve en |
| --------------------------------------------------------------- | ----------------------------------------------------------------- | ------------ | -------------- |
| [ADR-0001](../deuda-tecnica/eslint-9-eol.md)                    | Fijar ESLint 9.39.5 por incompatibilidad de plugins con ESLint 10 | 🟡 Pendiente | TS-142 (#760)  |
| [ADR-0002](../deuda-tecnica/stylelint-scope-y-colores.md)       | Alcance de Stylelint: colores y separación de scripts             | 🟡 Pendiente | TS-022 (#627)  |
| [ADR-0003](../deuda-tecnica/assets-hibrido-public-src.md)       | Modelo híbrido de assets: public/ + src/assets/                   | 🟡 Pendiente | TS-031 (#636)  |
| [ADR-0004](../deuda-tecnica/vulnerabilidades-policy.md)         | Política de vulnerabilidades aceptadas                            | 🟡 Pendiente | TS-143 (#761)  |
| [ADR-0005](../deuda-tecnica/decorador-with-theme-pendiente.md)  | Decorador `withTheme` pendiente de ThemeProvider                  | 🟡 Pendiente | TS-024 (#629)  |
| [ADR-0006](../deuda-tecnica/decorador-with-i18n-pendiente.md)   | Decorador `withI18n` pendiente de i18next                         | 🟡 Pendiente | TS-026 (#631)  |
| [ADR-0007](../deuda-tecnica/decorador-with-router-pendiente.md) | Decorador `withRouter` pendiente de React Router                  | 🟡 Pendiente | TS-070 (#675)  |
| [ADR-0008](../deuda-tecnica/mixins-base-pendientes.md)          | Mixins base de estilos (focus-ring, container, truncate)          | 🟡 Pendiente | TS-145 (#766)  |
| [ADR-0009](../deuda-tecnica/exclusiones-cobertura-tests.md)     | Exclusión temporal de `App.tsx` en cobertura de tests y a11y      | 🟡 Pendiente | TS-146 (#769)  |

**Regla de lectura obligatoria**: antes de modificar cualquier artefacto que dependa de un ADR, leer el archivo completo del ADR (no solo la fila de la tabla resumen).

## 8. Referencias

- Reglas completas: [`agente-frontend.md`](../../../prompts/agente-frontend.md).
- Estructura de directorios: `agente-frontend.md` §2.
- Convenciones de código: `agente-frontend.md` §15.
- Alias: [`frontend/tsconfig.paths.json`](../../../../frontend/tsconfig.paths.json).
- ADRs: `docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/`.
- Convenciones de testing: [`pruebas.md`](./pruebas.md).
