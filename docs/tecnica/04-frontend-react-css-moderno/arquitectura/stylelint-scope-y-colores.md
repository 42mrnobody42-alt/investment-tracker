# ADR-0002 — Alcance de Stylelint: colores y separación de scripts

- **Estado**: Aceptada
- **Fecha**: 2026-09-26
- **Capa**: Frontend (React + TypeScript + Vite + Stylelint)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: TS-003 (#608), FT-001 (#556), US-001 (#565), CAP-01 (#554), ADR-0001
- **Reemplaza a**: (ninguno)
- **Reemplazado por**: (pendiente para la parte de `var()`)

## Contexto

En TS-003 se introdujo **Stylelint 17.15.0** con la siguiente configuración:

- `stylelint-config-standard@40.0.0` (reglas W3C)
- `stylelint-config-css-modules@4.6.0` (soporte de `:global`, `composes:`)
- `stylelint-config-recess-order@7.8.0` (orden de propiedades)
- `declaration-no-important: true` (prohíbe `!important`)
- `selector-class-pattern: "^[a-z][a-zA-Z0-9]*$"` (camelCase para clases)

Durante el análisis previo surgieron **dos decisiones de alcance** que se documentan
aquí para no perder la trazabilidad.

---

## Decisión 1 — No forzar `var(--...)` en valores de color

**Problema**: el proyecto usa **CSS Custom Properties** (`var(--color-primary)`)
como tokens de diseño. Sería deseable que Stylelint rechazara valores de color
hardcodeados (`color: #ff0000`, `background: rgb(255 0 0)`).

**Decisión**: **NO incluir esta regla en TS-003**. Se difiere hasta que existan
los tokens reales.

**Motivo**:

1. **Stylelint no tiene regla nativa** para detectar "valores que deberían ser
   `var()`". Requiere un plugin custom o `stylelint-declaration-strict-value`,
   que tiene mantenimiento irregular.
2. **Los tokens no existen todavía.** La estructura `styles/tokens.css` +
   `styles/themes/*.css` llega en **TS-017** (Design tokens y theming). Forzar
   `var()` antes sería bloquear código legítimo.
3. **El starter de Vite** (`App.css`, `index.css`) contiene muchos valores
   hardcodeados que no vale la pena reescribir por adelantado.

**Gatillos de revisión**:

- Cuando TS-017 termine y los tokens estén definidos en `styles/tokens.css`.
- Cuando existan al menos **2 vistas reales** que puedan servir de patrón.
- Si en algún PR se cuelan colores hardcodeados evidentes.

**Solución futura** (a evaluar):

- `stylelint-declaration-strict-value` con lista de propiedades (`color`,
  `background-color`, `border-color`, etc.).
- Regla custom en `eslint-plugin-*` si Stylelint no alcanza.
- Alternativa: revisión manual + review en PRs.

---

## Decisión 2 — Scripts `lint:css` separados de `lint`

**Problema**: ¿el script general `npm run lint` debe incluir Stylelint o no?

**Decisión**: **mantenerlos separados**.

```json
{
  "lint": "eslint .",
  "lint:css": "stylelint \"src/**/*.css\"",
  "lint:css:fix": "stylelint \"src/**/*.css\" --fix"
}
```

**Motivo**:

1. **Granularidad**: durante desarrollo activo conviene correr solo el linter
   que aplica al archivo que se está editando.
2. **Velocidad**: ESLint tarda menos que Stylelint en este proyecto; mezclarlos
   ralentiza el ciclo de desarrollo.
3. **CI / Husky**: cuando llegue **TS-016** (Husky + lint-staged), el pre-commit
   correrá **solo el linter que corresponde al archivo modificado** (`.tsx` →
   ESLint, `.css` → Stylelint). Eso es lo estándar en la industria y ya está
   contemplado en `agente-frontend.md` §15.

**Gatillos de revisión**:

- Cuando TS-016 esté mergeado y `lint-staged` demuestre el flujo.
- Si el equipo pide un único comando, se puede crear un script compuesto
  (`"lint:all": "npm run lint && npm run lint:css"`) sin tocar los existentes.

**No es un problema técnico, es una convención de ergonomía.**

---

## Consecuencias

### Positivas

- No se bloquea el desarrollo por reglas prematuras.
- Trazabilidad clara de por qué estos límites existen.
- Fácil de revertir cuando lleguen los gatillos.

### Negativas

- **Colores hardcodeados** pueden colarse en PRs hasta que se active el gatillo 1.
  Mitigación: revisión de PRs + chequeo manual.
- **Comandos duplicados** en CI hasta que `lint-staged` los unifique en TS-016.
  Mitigación: documentar ambos scripts en `frontend/README.md`.

### Neutrales

- Ninguna de las dos decisiones bloquea funcionalidad.
- Ambas son reversibles sin tocar código de negocio.

---

## Referencias

- `docs/prompts/agente-frontend.md` §9 (Estilos y theming) — CSS Custom Properties como fuente única de valores.
- `docs/prompts/agente-frontend.md` §15 (Convenciones de código) — pipeline de linting.
- `docs/prompts/agente-frontend.md` §19 (Anti-patrones) — colores hardcodeados prohibidos.
- ADR-0001: `docs/tecnica/04-frontend-react-css-moderno/arquitectura/eslint-9-eol.md` — patrón de documentación de deuda.
- TS-016 (#621) — Husky + lint-staged + commitlint.
- TS-017 (#622) — Design tokens y theming.
