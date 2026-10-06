# ADR-0006 — Decorador `withI18n` pendiente de i18next

- **Estado**: 🟡 Pendiente
- **Fecha**: 2026-10-03
- **Capa**: Frontend (Storybook)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: TS-009 (#614), TS-026 (#631), US-003 (#567), US-008
- **Resuelto por**: TS-026 (#631)
- **Documentación final**: `docs/tecnica/04-frontend-react-css-moderno/convenciones/storybook.md`

## Contexto

En TS-009 (#614) se configuraron los decoradores globales de Storybook. El
alcance original pedía un decorador `withI18n` que envolviera todas las stories
con `I18nextProvider`.

**Problema**: el `I18nextProvider` no existe todavía en el código. Se construye
en **TS-026 (#631)** — US-008 (i18n con namespaces por componente).

Forzar la creación de un `i18n` prematuro duplicaría trabajo.

## Decisión

**Diferir el decorador `withI18n` a TS-026 (#631)**.

TS-026 agregará al cerrar:
- El decorador `withI18n` conectado al `I18nextProvider` real.
- El toolbar de locale en Storybook (`globalTypes.locale` con `es`, `en`).
- La documentación del decorador resuelto.

## Consecuencias

### Positivas

- No se duplica trabajo: `i18n` se configura una sola vez.
- TS-009 queda con un alcance honesto.

### Negativas

- Las stories de TS-009 solo usan strings literales (sin traducción en Storybook).
- Mitigación parcial: los textos de las stories son en inglés por convención del DS (ver `agente-frontend.md` §5).

### Neutrales

- Los componentes reales seguirán usando `t('...')` cuando exista `i18n`.

## Gatillo de resolución

Cuando **TS-026 (#631)** esté completado:

1. Verificar que `i18n/index.ts` funcione con fallback `es` + LanguageDetector + persistencia.
2. Agregar el decorador `withI18n` a `preview.ts`.
3. Registrar el toolbar de locale (`globalTypes.locale`).
4. Verificar que las stories heredan el idioma activo.
5. **Eliminar este ADR** y mover la documentación a `storybook.md`.
6. Tachar la deuda en el índice de ADRs del `README.md`.

## Referencias

- `docs/tecnica/04-frontend-react-css-moderno/convenciones/storybook.md`
- TS-026 (#631) — i18next + LanguageDetector.
