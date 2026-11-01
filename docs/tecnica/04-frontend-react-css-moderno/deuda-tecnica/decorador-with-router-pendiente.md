# ADR-0007 — Decorador `withRouter` pendiente de React Router

- **Estado**: 🟡 Pendiente
- **Fecha**: 2026-10-03
- **Capa**: Frontend (Storybook)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: TS-009 (#614), TS-070 (#675), US-003 (#567), US-020
- **Resuelto por**: TS-070 (#675)
- **Documentación final**: `docs/tecnica/04-frontend-react-css-moderno/convenciones/storybook.md`

## Contexto

En TS-009 (#614) se configuraron los decoradores globales de Storybook. El
alcance original pedía un decorador `withRouter` que envolviera todas las
stories con `MemoryRouter` (no `BrowserRouter`, para no ensuciar el historial).

**Problema**: React Router no está instalado ni configurado todavía. Se
construye en **TS-070 (#675)** — US-020 (React Router v6 + lazy + paths).

## Decisión

**Diferir el decorador `withRouter` a TS-070 (#675)**.

TS-070 agregará al cerrar:
- El decorador `withRouter` conectado a `MemoryRouter`.
- El parámetro `parameters.router.initialEntries` por story.
- La documentación del decorador resuelto.

## Consecuencias

### Positivas

- No se duplica trabajo: React Router se configura una sola vez.
- TS-009 queda con un alcance honesto.
- Se evita instalar una dependencia pesada por adelantado sin usarla.

### Negativas

- Las stories de TS-009 no podrán renderizar componentes con `Link`/`NavLink`/`useNavigate`.
- Aceptable: el único componente actual (`Button`) no depende de routing.

### Neutrales

- Cuando aparezca el primer componente con routing (probablemente en FT-003+), TS-070 estará listo o próximo.

## Gatillo de resolución

Cuando **TS-070 (#675)** esté completado:

1. Verificar que `app/router/index.tsx` funcione con `createBrowserRouter` + lazy.
2. Agregar el decorador `withRouter` a `preview.ts` (usando `MemoryRouter`).
3. Configurar `parameters.router.initialEntries` por story.
4. Verificar que componentes con `Link`/`NavLink`/`useNavigate` no tiren warnings.
5. **Eliminar este ADR** y mover la documentación a `storybook.md`.
6. Tachar la deuda en el índice de ADRs del `README.md`.

## Referencias

- `docs/tecnica/04-frontend-react-css-moderno/convenciones/storybook.md`
- TS-070 (#675) — createBrowserRouter + lazyViews.
