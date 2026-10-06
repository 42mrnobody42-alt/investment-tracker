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

## 6. Referencias

- Reglas completas: [`agente-frontend.md`](../../../prompts/agente-frontend.md).
- Estructura de directorios: `agente-frontend.md` §2.
- Convenciones de código: `agente-frontend.md` §15.
- Alias: [`frontend/tsconfig.paths.json`](../../../../frontend/tsconfig.paths.json).
- ADRs: `docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/`.
