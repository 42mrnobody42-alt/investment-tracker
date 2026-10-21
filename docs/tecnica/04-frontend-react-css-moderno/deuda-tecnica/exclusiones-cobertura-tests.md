# ADR-0009 — Exclusión temporal de `App.tsx` en cobertura de tests

- **Estado**: 🟡 Pendiente
- **Fecha**: 2026-10-17
- **Capa**: Frontend (React + TypeScript + Vite + Vitest + Playwright)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: US-004 (#568), TS-012 (#617), TS-014 (#619), TS-138 (#743), US-024 (#588), US-025 (#589), US-041 (#605), TS-146 (#769), ADR-0002
- **Reemplaza a**: (ninguno)
- **Reemplazado por**: (pendiente)
- **Se resuelve en**: TS-146 (#769) — sub-issue de US-024. Incluye: reemplazar `App.tsx`, eliminar exclusiones de cobertura (Vitest y a11y), añadir test unitario y test a11y del nuevo código.
- **Documentación final**: `docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md`

## Contexto

En **TS-012** se configuró Vitest con umbral estricto de cobertura **80% en las 4
métricas** (Stmts, Branch, Funcs, Lines), tanto global como por archivo. Ver
convenciones completas en
[`convenciones/pruebas.md`](../../convenciones/pruebas.md).

El archivo `src/app/App.tsx` es **starter demo de Vite** (hero, logos, counter).
Contiene código que se va a **eliminar por completo** cuando se implementen las
vistas reales en **US-024** (InitPage horizontal) y **US-025** (InitPage vertical).

Testear `App.tsx` hoy implica escribir tests que se borran cuando el archivo
desaparezca. Coste sin retorno.

## Decisión

**Excluir `src/app/App.tsx` del cómputo de cobertura** mientras siga siendo
starter demo, con estas condiciones:

1. Solo se excluye del `coverage.exclude` de `vitest.config.ts`.
2. La exclusión está **documentada aquí** y **referenciada en las US-024/025**.
3. Al reemplazarse `App.tsx` por la composición real, se **elimina esta
   exclusión** y se **añade test** para el nuevo `App.tsx`.

**Aplicación a tests a11y (TS-014 #619)**: la exclusión de `src/app/App.tsx`
también aplica a los tests de accesibilidad automatizados (Playwright + axe).
TS-014 valida el helper `runA11y()` contra un **mockup HTML**
(`tests/e2e/fixtures/mock-view.html`), no contra `App.tsx`. Al resolverse este
ADR (TS-146 #769), el mockup se reemplaza por la vista real y se añade el test
a11y correspondiente. Ver TS-138 (#743) para la aplicación del helper a las
vistas reales de US-024/025 y posteriores.

## Consecuencias

### Positivas

- El equipo no pierde tiempo testeando código que se va a borrar.
- La exclusión tiene **trazabilidad explícita** (este ADR + criterios de aceptación
  agregados a US-024/025).

### Negativas

- `App.tsx` no está cubierto durante US-024/025. Mitigación: las vistas reales
  que lo reemplacen tendrán test obligatorio por DoD.

### Neutrales

- Ninguna otra exclusión de cobertura queda cubierta por este ADR. Las
  exclusiones **permanentes** (entry point, stories, types, index, vite-env) y las
  **líneas justificadas de `DesignTokens.tsx`** se documentan en
  `convenciones/pruebas.md` porque son reglas permanentes, no deuda.

## Referencias

- `docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md` — convenciones completas de testing.
- `docs/prompts/agente-frontend.md` §14 (Testing) y §18 (DoD).
- `frontend/vitest.config.ts` — configuración real.
- TS-012 (#617) — Task que introdujo la cobertura.

---

## Gatillo de resolución

Cuando **TS-146 (#769)** se cierre:

1. Reemplazar `src/app/App.tsx` starter por la composición real.
2. Eliminar `src/app/App.tsx` de `coverage.exclude` en `vitest.config.ts`.
3. Añadir test unitario para el nuevo `App.tsx` (código real).
4. **Añadir test a11y** para el nuevo `App.tsx` en `tests/e2e/a11y.spec.ts`
   con `runA11y()` y `prefers-reduced-motion: reduce` emulado (convención de TS-014).
5. Verificar cobertura ≥80% global y por archivo.
6. Verificar `npx playwright test --project=desktop -g a11y` en verde.
7. **Eliminar este archivo** (ADR-0009).
8. Tachar la fila de ADR-0009 en la tabla de ADRs del `README.md`.
9. Marcar `- [x] Resuelve ADR-0009` en el body de US-024 y US-025.
