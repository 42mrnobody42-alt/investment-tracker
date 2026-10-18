# ADR-0009 — Exclusión temporal de `App.tsx` en cobertura de tests

- **Estado**: 🟡 Pendiente
- **Fecha**: 2026-10-17
- **Capa**: Frontend (React + TypeScript + Vite + Vitest)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: US-004 (#568), TS-012 (#617), US-024 (#588), US-025 (#589), TS-146 (#769), ADR-0002
- **Reemplaza a**: (ninguno)
- **Reemplazado por**: (pendiente)
- **Se resuelve en**: TS-146 (#769) — sub-issue de US-024
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
3. Añadir test para el nuevo `App.tsx` (código real).
4. Verificar cobertura ≥80% global y por archivo.
5. **Eliminar este archivo** (ADR-0009).
6. Tachar la fila de ADR-0009 en la tabla de ADRs del `README.md`.
7. Marcar `- [x] Resuelve ADR-0009` en el body de US-024 y US-025.
