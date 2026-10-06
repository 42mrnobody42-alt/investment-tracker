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

### Pendiente

- Story `DesignTokens/Overview` (TS-010)
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
