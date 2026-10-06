# ADR-0005 — Decorador `withTheme` pendiente de ThemeProvider

- **Estado**: 🟡 Pendiente
- **Fecha**: 2026-10-03
- **Capa**: Frontend (Storybook)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: TS-009 (#614), TS-024 (#629), US-003 (#567), US-007
- **Resuelto por**: TS-024 (#629)
- **Documentación final**: `docs/tecnica/04-frontend-react-css-moderno/convenciones/storybook.md`

## Contexto

En TS-009 (#614) se configuraron los decoradores globales de Storybook. El
alcance original pedía 3 decoradores, uno de los cuales debía envolver todas
las stories con `ThemeProvider`.

**Problema**: el `ThemeProvider` no existe todavía en el código. Se construye
en **TS-024 (#629)** — US-007 (Design tokens y theming).

Forzar la creación de un `ThemeProvider` prematuro en TS-009 duplicaría trabajo
o crearía una versión descartable.

## Decisión

**Diferir el decorador `withTheme` a TS-024 (#629)**.

TS-009 entregará:
- Los decoradores implementables hoy (`withPadding`, `withBackground`, `withViewport`).
- La estructura de `preview.ts` preparada con TODOs explícitos.
- La documentación del estado parcial en `storybook.md`.

TS-024 agregará al cerrar:
- El decorador `withTheme` conectado al `ThemeProvider` real.
- El toolbar de tema en Storybook (`globalTypes.theme`).
- La documentación del decorador resuelto.

## Consecuencias

### Positivas

- No se duplica trabajo: el `ThemeProvider` se crea una sola vez, bien.
- TS-009 queda con un alcance honesto y ejecutable.

### Negativas

- Las stories de TS-009 no tendrán toggle de tema interactivo en Storybook.
- Mitigación parcial: `withBackground` permite ver el componente sobre fondo claro/oscuro sin cambiar el tema global.

### Neutrales

- `DarkMode` en las stories del Button se implementa vía `withBackground` con fondo oscuro (no via ThemeProvider).

## Gatillo de resolución

Cuando **TS-024 (#629)** esté completado:

1. Verificar que `ThemeProvider` funcione con `data-theme` + persistencia + `prefers-color-scheme`.
2. Agregar el decorador `withTheme` a `preview.ts`.
3. Registrar el toolbar de tema (`globalTypes.theme`).
4. Verificar que las stories heredan el tema activo.
5. **Eliminar este ADR** y mover la documentación a `storybook.md`.
6. Tachar la deuda en el índice de ADRs del `README.md`.

## Referencias

- `docs/tecnica/04-frontend-react-css-moderno/convenciones/storybook.md` — guía operativa.
- `docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/vulnerabilidades-policy.md` — patrón de ADRs de deuda.
- TS-024 (#629) — ThemeProvider con persistencia.
