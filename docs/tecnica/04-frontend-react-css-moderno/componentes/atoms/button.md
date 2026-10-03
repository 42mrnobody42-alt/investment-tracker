# Button (ejemplo provisional)

> **Estado**: Ejemplo provisional creado en **TS-007** para ilustrar las convenciones.
> Se reemplazará por la versión definitiva en **FT-003 (Design System: átomos)**.

## Ubicación

- Componente: `frontend/src/components/atoms/Button/`
- CSS Module: `Button.module.css`
- Tipos: `Button.types.ts`
- Barrel: `index.ts`

## Props

| Prop       | Tipo                                              | Default     | Descripción                  |
| ---------- | ------------------------------------------------- | ----------- | ---------------------------- |
| `variant`  | `'primary' \| 'secondary' \| 'ghost' \| 'danger'` | `'primary'` | Variante visual              |
| `size`     | `'sm' \| 'md' \| 'lg'`                            | `'md'`      | Tamaño                       |
| `loading`  | `boolean`                                         | `false`     | Estado de carga              |
| `children` | `ReactNode`                                       | —           | Contenido del botón          |
| `...rest`  | `ButtonHTMLAttributes<HTMLButtonElement>`         | —           | Props nativas del `<button>` |

## Uso

```tsx
import { Button } from '@components/atoms/Button';

<Button onClick={handleClick}>Enviar</Button>
<Button variant="secondary" size="sm">Cancelar</Button>
<Button variant="danger" loading>Eliminando...</Button>
```

## Convenciones aplicadas

- **Named export** (`export function Button`), no default.
- **CSS Module** con clases en **camelCase** (`.button`, `.primary`, `.sm`).
- **Props tipadas** en archivo separado (`Button.types.ts`).
- **JSDoc** en campos públicos de props.
- **Barrel export** en `index.ts`.
- Alias `@components` para importar desde otros módulos.

## Pendiente en FT-003

- Tests unitarios (`Button.test.tsx`).
- Stories de Storybook (`Button.stories.tsx`).
- Variantes adicionales y estados revisados contra el design system.
- Reemplazar colores hardcodeados por tokens cuando llegue **TS-017** (`styles/tokens.css`).
