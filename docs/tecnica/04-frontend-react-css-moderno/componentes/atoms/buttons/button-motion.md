# ButtonMotion* — API de los 3 componentes de motion (TS-147)

Documentación de los 3 componentes de motion del Button. Viven en
`frontend/src/components/atoms/buttons/` y siguen la estructura obligatoria de
`agente-frontend.md` §4.

Cada uno es **independiente** y **no extiende `Button`** (`agente-frontend.md`
§24.3.1). Si en el futuro se necesita compartir estilos base, se extrae un
`useButtonStyles` compartido.

## Props comunes

| Prop | Tipo | Default | Descripción |
| --- | --- | --- | --- |
| `variant` | `primary \| secondary \| ghost \| danger` | `primary` | Variante visual |
| `size` | `xxs \| xs \| s \| m \| l \| xl \| xxl` | `m` | Tamaño |
| `radius` | `none \| sm \| md \| lg \| xl \| full` | `md` | Radio de borde (`--radius-*`) |
| `shadow` | `none \| xs \| sm \| md \| lg \| xl \| 2xl` | `sm` | Sombra (`--shadow-*`) |
| `fontFamily` | `sans \| mono` | `sans` | Familia tipográfica |
| `fontSize` | `xs \| sm \| base \| lg \| xl \| 2xl` | (size) | Tamaño de fuente (`--font-size-*`) |
| `fontWeight` | `regular \| medium \| semibold \| bold` | `medium` | Peso (`--font-weight-*`) |
| `lineHeight` | `tight \| normal \| relaxed` | `tight` | Altura de línea (`--line-height-*`) |
| `letterSpacing` | `tight \| normal \| wide` | `normal` | Espaciado (`--letter-spacing-*`) |
| `theme` | `light \| dark \| high-contrast` | (hereda) | Aplica `data-theme` en el `<button>` |
| `loading` | `boolean` | `false` | aria-busy, bloquea interacción |
| `disabled` | `boolean` | `false` | opacity 0.6, cursor not-allowed |
| `children` | `ReactNode` | — | Texto o contenido |

## ButtonMotionShine

- **Ruta**: `frontend/src/components/atoms/buttons/ButtonMotionShine/`
- **Story**: `Atoms/ButtonMotionShine`
- **Efecto**: barrido diagonal de brillo + `translateY(-1px)` en hover y
  `:focus-visible`.
- **Re-disparo**: cada click añade un `.shineWave` independiente (se superponen).
- **Duración**: `--motion-duration-shine` (2s).
- **Trade-offs**: el `skewX` puede verse "barato" si la duración es muy corta.

## ButtonMotionWave

- **Ruta**: `frontend/src/components/atoms/buttons/ButtonMotionWave/`
- **Story**: `Atoms/ButtonMotionWave`
- **Efecto**: onda expansiva desde la posición del click. Dos anillos
  superpuestos: grueso (18px) que se desvanece al final + fino (6px) que dura
  todo el recorrido.
- **Re-disparo**: cada click añade un par de anillos independiente.
- **Duración**: `--motion-duration-wave` (4s).
- **Trade-offs**: sin JS la onda nace centrada (fallback `--wave-x: 50%`).

## ButtonMotionVibrate

- **Ruta**: `frontend/src/components/atoms/buttons/ButtonMotionVibrate/`
- **Story**: `Atoms/ButtonMotionVibrate`
- **Efecto**: vibración lateral (±4px, ~25 ciclos) al click.
- **Re-disparo**: cada click reinicia la vibración (doble `requestAnimationFrame`
  para forzar reflow).
- **Duración**: `--motion-duration-vibrate` (2s).
- **Trade-offs**: el vibrate puede sentirse agresivo; se recomienda como opción
  secundaria, no como CTA principal.

## Reglas comunes

- Solo `transform` y `opacity` (`agente-frontend.md` §24.5).
- `prefers-reduced-motion: reduce` desactiva las 3 animaciones y mantiene el
  foco visible.
- Cero `box-shadow` animado, cero `filter` animado.
