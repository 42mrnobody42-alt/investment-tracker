# Warnings aceptados en Storybook

> **Estado**: Todos aceptados como informativos (no bloqueantes).
> **Aplica a**: Storybook 10.6.1 con `@storybook/react-vite`.
> **Fecha de decisión**: 2026-10-03 (TS-009, #614).

Este documento registra los warnings conocidos que Storybook emite y que
fueron evaluados y aceptados como informativos.

---

## W-001 — `Skipping docgen` para `.storybook/preview.tsx`

### El warning

Al correr `npm run storybook` o `npm run build-storybook`, aparece:

    ▲ Vite [plugin vite:react-docgen-typescript] Skipping docgen for
      ".../.storybook/preview.tsx" because it is not included in the
      active TypeScript project.

### Por qué ocurre

El plugin `vite-plugin-react-docgen-typescript` (que usa Storybook para generar
autodocs) intenta procesar **todos** los archivos `.ts`/`.tsx` que encuentra,
incluidos los de configuración de Storybook.

`preview.tsx` **no es un componente React**: es un archivo de configuración que
define decoradores globales y parámetros para Storybook. El plugin no tiene nada
que documentar en él, así que lo salta.

El aviso aparece porque el plugin comprueba primero si el archivo pertenece al
proyecto TypeScript activo (definido por `tsconfig.app.json`, que solo incluye
`src/`). Como `preview.tsx` vive en `.storybook/`, no está en ese proyecto y
emite el warning.

### Por qué se acepta

1. **No es un error**: el build completa exitosamente.
2. **No afecta al producto**: no llega al bundle de producción (`dist/`).
3. **No afecta a los autodocs de componentes reales**: `Button.stories.tsx` se
   documenta correctamente.
4. **No hay fix limpio**: el plugin salta `.storybook/` por diseño.
5. **Silenciarlo agrega complejidad innecesaria**.

### Cómo leerlo

Es **ruido del terminal**. Al verlo:

- Se puede ignorar con seguridad.
- El build terminó bien si el mensaje final dice `Storybook build completed successfully`.
- No indica un bug en el código del proyecto.

---

## W-002 — `ariaLabel` en `PopoverProvider` (anticipo Storybook 11)

### El warning

En la consola del navegador al abrir Storybook:

    globals-runtime.js:123 The 'ariaLabel' prop on 'PopoverProvider' will
    become mandatory in Storybook 11. Provide a concise, accessible label
    describing the popover's purpose.

### Por qué ocurre

Storybook 10.6.1 emite este aviso para anticipar un cambio que vendrá en
**Storybook 11**: el prop `ariaLabel` del componente interno `PopoverProvider`
pasará de ser opcional a obligatorio.

**No es un problema de nuestro código**: el warning viene de la propia
implementación interna de Storybook (probablemente del addon `themes` o
`a11y`). Nuestro proyecto no usa `PopoverProvider` directamente.

### Por qué se acepta

1. **Es interno de Storybook**: no aparece en nuestro código.
2. **No afecta funcionalidad**: es un aviso anticipado, no un error.
3. **No hay fix posible sin parchear Storybook**.
4. **Se resolverá solo**: cuando actualicemos a Storybook 11, el prop será
   obligatorio y Storybook lo manejará internamente.

### Cómo leerlo

Es **un aviso de migración futura**. Al verlo:

- Se puede ignorar con seguridad en Storybook 10.
- No aparece en producción.
- No requiere acción por parte del proyecto.

### Cuándo revisar esta decisión

- Cuando actualicemos a **Storybook 11** y verifiquemos que el aviso desaparece.
- Si el warning muta a error en una versión futura de Storybook 10.x.

---

## Referencias

- `storybook.md` — guía operativa de Storybook.
- `agente-frontend.md` sección 5 — configuración de Storybook.
- TS-009 (#614) — task donde se detectaron y decidieron.
