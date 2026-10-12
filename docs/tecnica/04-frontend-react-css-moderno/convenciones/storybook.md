# Storybook — Guia operativa

> **Version instalada**: Storybook 10.6.1
> **Puerto dev**: `3010`
> **Configuracion**: `frontend/.storybook/`
> **Framework**: `@storybook/react-vite` (integrado con Vite 8)

## Comandos

| Comando                   | Accion                                                   |
| ------------------------- | -------------------------------------------------------- |
| `npm run storybook`       | Levanta el dev server en `http://localhost:3010/`        |
| `npm run build-storybook` | Genera el sitio estatico en `frontend/storybook-static/` |

## Estructura

- `frontend/.storybook/main.ts` — Configuracion principal (addons, framework, stories glob)
- `frontend/.storybook/preview.tsx` — Decoradores globales y parametros aplicados a todas las stories
- `frontend/.storybook/preview-head.html` — Contenido extra en el head del iframe de preview
- `frontend/.storybook/manager.ts` — Personalizacion de la UI del Storybook

## Addons configurados

| Addon                     | Proposito                                         |
| ------------------------- | ------------------------------------------------- |
| `@storybook/addon-docs`   | Generacion automatica de documentacion (autodocs) |
| `@storybook/addon-a11y`   | Auditoria de accesibilidad WCAG 2.2 AA            |
| `@storybook/addon-themes` | Cambio de tema claro/oscuro                       |

## Autodocs — Configuracion global

### Como esta configurado

En este proyecto **autodocs esta activado globalmente** para todas las stories,
sin necesidad de declarar `tags: ['autodocs']` en cada archivo `.stories.tsx`.

La configuracion vive en `frontend/.storybook/preview.tsx`:

    const preview: Preview = {
      tags: ['autodocs'],
      parameters: { ... },
    };

**Efecto**: cualquier story creada bajo `src/**/*.stories.tsx` obtiene
automaticamente una pagina **Docs** generada con `react-docgen-typescript`.

### Historia — Por que no esta en `main.ts`

En Storybook 8, la opcion `docs.autodocs: 'tag'` vivia en `main.ts`. En
**Storybook 10 fue deprecada y eliminada del tipo `DocsOptions`**, por lo que
declararla genera un error de TypeScript:

    TS2353: Object literal may only specify known properties, and 'autodocs'
    does not exist in type 'DocsOptions'.

La forma correcta en Storybook 10+ es declarar `tags: ['autodocs']` en
`preview.tsx`, que aplica el tag a nivel global. **No usar `docs.autodocs`**.

### Optimizacion: solo autodocs global, sin tags por story

Como autodocs es global, **no hace falta** declarar `tags: ['autodocs']` en cada
`.stories.tsx`. El patron recomendado es:

**Correcto (recomendado)**:

    // preview.tsx
    const preview: Preview = {
      tags: ['autodocs'],
      // ...
    };

    // Button.stories.tsx
    const meta: Meta<typeof Button> = {
      title: 'Atoms/Button',
      component: Button,
    };
    // sin tags: ['autodocs']

**Redundante (evitar)**:

    // Button.stories.tsx
    const meta: Meta<typeof Button> = {
      title: 'Atoms/Button',
      component: Button,
      tags: ['autodocs'], // redundante, ya esta en preview.tsx
    };

### Casos de uso que sobreescriben el default global

Si una story **NO** debe tener autodocs (por ejemplo, un sandbox interno), se
puede sobreescribir localmente:

    export const Sandbox: Story = {
      tags: ['!autodocs'], // desactiva autodocs para esta story
    };

Si un archivo entero debe quedar sin autodocs, se declara en el `meta`:

    const meta: Meta<typeof Component> = {
      title: 'Internal/Sandbox',
      component: Component,
      tags: ['!autodocs'],
    };

### Configuracion adicional de la pagina Docs

Se puede ajustar el comportamiento del autodocs con parametros en `preview.tsx`
o por story:

    parameters: {
      docs: {
        toc: true,           // muestra tabla de contenidos
        inlineStories: true, // renderiza stories inline en la pagina Docs
      },
    };

### Verificacion

Para confirmar que autodocs esta funcionando en una story nueva:

1. Correr `npm run storybook`.
2. Abrir `http://localhost:3010/`.
3. Verificar que la story aparece con 2 pestanas: **Docs** y **[nombre de la story]**.
4. La pestana **Docs** debe mostrar:
   - La descripcion del componente (desde JSDoc).
   - La tabla de props con tipos y defaults.
   - Las stories renderizadas inline.

Si la pestana Docs no aparece, revisar:

- Que el archivo este bajo `src/**/*.stories.tsx` (el glob de `main.ts`).
- Que `preview.tsx` tenga `tags: ['autodocs']`.
- Que el addon `@storybook/addon-docs` este en `main.ts`.
- Que la story no tenga `tags: ['!autodocs']`.

## Decoradores

### Activos (TS-009)

Configurados en `frontend/.storybook/preview.tsx`:

| Decorador        | Proposito                                      | Parametro                        |
| ---------------- | ---------------------------------------------- | -------------------------------- |
| `withPadding`    | Padding uniforme de 24px alrededor de la story | (ninguno)                        |
| `withBackground` | Fondo claro u oscuro segun el parametro        | `parameters.backgrounds.default` |
| `withViewport`   | Ancho fijo segun el parametro                  | `parameters.viewportWidth` (px)  |

**Ejemplo de uso** en una story:

    export const Mobile: Story = {
      parameters: { viewportWidth: 375 },
      render: () => <Button>En movil</Button>,
    };

### Pendientes — registrados como ADRs

Los siguientes decoradores requieren providers que **aun no existen** en el
codigo. Estan registrados como deudas tecnicas en `deuda-tecnica/` y se
conectaran cuando sus providers se construyan:

| Decorador    | Provider requerido | Se resuelve en | ADR                                                             |
| ------------ | ------------------ | -------------- | --------------------------------------------------------------- |
| `withTheme`  | `ThemeProvider`    | TS-024 (#629)  | [ADR-0005](../deuda-tecnica/decorador-with-theme-pendiente.md)  |
| `withI18n`   | `I18nextProvider`  | TS-026 (#631)  | [ADR-0006](../deuda-tecnica/decorador-with-i18n-pendiente.md)   |
| `withRouter` | React Router       | TS-070 (#675)  | [ADR-0007](../deuda-tecnica/decorador-with-router-pendiente.md) |

**Al cerrar cada ADR**: agregar el decorador a `preview.tsx`, verificarlo en las
stories, actualizar esta tabla, eliminar el ADR y tachar la fila en la tabla del
`README.md`.

## Estado actual

### TS-008 (completado)

- `main.ts` con los 3 addons
- `preview.tsx` con `tags: ['autodocs']` global
- `preview-head.html` + `manager.ts` como stubs
- Primera story: `Button.stories.tsx` con `Default`

### TS-009 (completado)

- 5 stories del Button: `Default`, `Variants`, `Sizes`, `States`, `DarkMode`
- 3 decoradores activos: `withPadding`, `withBackground`, `withViewport`
- TODOs documentados para los 3 decoradores pendientes
- 3 ADRs creados (ADR-0005, ADR-0006, ADR-0007)

### TS-010 (completado)

Story `DesignTokens/Overview` (9 sub-stories). Componente `DesignTokens`
(`frontend/src/components/atoms/DesignTokens/`) tratado como átomo del Design
System. Consume **todos** los tokens de `frontend/src/styles/branding/` y los lee
con `getComputedStyle` para reflejar el tema activo (`data-theme`).

#### Sub-stories y sus subgrupos

**`Colors`** — 3 bloques por tema (`light`, `dark`, `high-contrast`), cada uno con
3 subgrupos:

- `Brand` — 5 tokens (`--color-primary`, `--color-primary-hover`,
  `--color-primary-light`, `--color-accent`, `--color-accent-hover`).
- `Semantic` — 8 tokens (success, danger, warning, info + variantes `-hover`).
- `Neutral` — 6 tokens (bg, surface, border, text, text-muted, text-inverse).

**`Typography`** — 6 subgrupos:

- `Font families` — `--font-sans`, `--font-mono`.
- `Font sizes` — 8 escalas (`xs` → `4xl`).
- `Font weights` — 4 pesos (regular, medium, semibold, bold).
- `Line heights` — 3 valores (tight, normal, relaxed).
- `Letter spacing` — 3 valores (tight, normal, wide).
- `Demo` — muestra `h1`, `h2`, `h3`, párrafo y `code` reales.

**`Spacing`** — 8 tokens (`--space-1` → `--space-10`) con barra proporcional y valor.

**`Radius`** — 5 tokens (`--radius-sm` → `--radius-full`) con caja cuadrada demostrativa.

**`Shadows`** — 6 tokens (`--shadow-xs/sm/md/lg/xl/2xl`) sobre fondo tintado para
hacer visible el salto entre intensidades.

**`Layout`** — 3 subgrupos:

- `Grid` — `--grid-columns`, `--grid-gutter` (ejemplo visual de espaciado entre
  celdas), `--container-max-width`.
- `Breakpoints` — 5 tokens (`sm` → `2xl`) con barra escalada.
- `Z-index` — 8 tokens (`base` → `toast`) con pila visual + tabla lateral
  (Token / Profundidad / Valor).

**`Motion`** — 4 subgrupos:

- `Durations` — 5 tokens (`instant` → `slower`) con replay animado.
- `Easings` — 5 curvas (`linear`, `in`, `out`, `in-out`, `spring`) con SVG + bola
  animada, más 2 easings compuestos: `--ease-pendulum` y `--ease-pendulum-damped`
  (amplitud parametrizable vía `--pendulum-amplitude`).
- `Stagger` — 3 tokens (`fast`, `normal`, `slow`) con 5 puntos que aparecen
  escalonados.
- `Barrido de página (4 direcciones)` — basado en `--pasar-pagina`, con grid 8×4 y
  4 variantes diagonales: `sweepCellTlBr`, `sweepCellTrBl`, `sweepCellBlTr`,
  `sweepCellBrTl`. Cada bloque muestra la dirección + el nombre de la clase CSS
  aplicable.

**`Dark`** — todo el catálogo (7 secciones) con `data-theme="dark"`.

**`HighContrast`** — todo el catálogo con `data-theme="high-contrast"`.

### Pendiente

- Build estatico versionado (TS-011)

## Convenciones de stories

Segun agente-frontend.md seccion 5, cada componente atomico/molecular/organismo
debe tener su archivo .stories.tsx con las siguientes stories minimas:

| Story      | Cuando                                          |
| ---------- | ----------------------------------------------- |
| Default    | Estado base del componente                      |
| Variants   | Todas las variantes visuales (colores, tamanos) |
| States     | loading, disabled, error, empty                 |
| Responsive | Viewports: mobile-vertical, tablet, desktop, tv |
| DarkMode   | Variante en tema oscuro                         |

En TS-008 se creo solo `Default` del Button como ejemplo. En TS-009 se
completaron las 5 stories: `Default`, `Variants`, `Sizes`, `States`, `DarkMode`.

## Ubicacion de las stories

Junto al componente, en su carpeta:

- `frontend/src/components/atoms/Button/Button.tsx`
- `frontend/src/components/atoms/Button/Button.module.css`
- `frontend/src/components/atoms/Button/Button.types.ts`
- `frontend/src/components/atoms/Button/Button.stories.tsx`
- `frontend/src/components/atoms/Button/index.ts`

Y para el átomo DesignTokens (TS-010):

- `frontend/src/components/atoms/DesignTokens/DesignTokens.tsx`
- `frontend/src/components/atoms/DesignTokens/DesignTokens.module.css`
- `frontend/src/components/atoms/DesignTokens/DesignTokens.types.ts`
- `frontend/src/components/atoms/DesignTokens/DesignTokens.stories.tsx`
- `frontend/src/components/atoms/DesignTokens/index.ts`

## Configuracion del glob

main.ts busca stories en:

    stories: ['../src/**/*.stories.@(ts|tsx)']

Cualquier archivo .stories.tsx bajo src/ es detectado automaticamente.

## Warnings conocidos

### `Skipping docgen` para `.storybook/preview.tsx`

Storybook muestra en cada build:

    - Vite [plugin vite:react-docgen-typescript] Skipping docgen for
      ".../.storybook/preview.tsx" because it is not included in the
      active TypeScript project.

**Es informativo, no bloqueante.** Documentación completa en:

[`warnings-storybook.md`](./warnings-storybook.md)

## Referencias

- agente-frontend.md seccion 5 (Storybook)
- agente-frontend.md seccion 2 (estructura .storybook/)
- Storybook docs: https://storybook.js.org/docs
- Autodocs: https://storybook.js.org/docs/writing-docs/autodocs
- Warning aceptado: [`warnings-storybook.md`](./warnings-storybook.md)
