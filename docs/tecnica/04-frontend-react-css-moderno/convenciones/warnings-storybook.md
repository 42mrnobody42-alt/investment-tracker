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

## Referencias

- `storybook.md` — guía operativa de Storybook.
- `agente-frontend.md` sección 5 — configuración de Storybook.
- TS-009 (#614) — task donde se detectaron y decidieron.
