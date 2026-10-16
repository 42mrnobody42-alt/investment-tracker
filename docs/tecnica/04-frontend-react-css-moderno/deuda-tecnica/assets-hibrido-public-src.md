# ADR-0003 — Modelo híbrido de assets: `public/` (branding) + `src/assets/` (técnicos)

- **Estado**: 🟡 Pendiente
- **Fecha**: 2026-10-02
- **Capa**: Frontend (React + TypeScript + Vite)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: TS-005 (#610), US-002 (#566), FT-001 (#556), CAP-01 (#554), TS-011 (#616), ADR-0002
- **Reemplaza a**: Interpretación estricta de `agente-frontend.md` §8 ("todo a `public/`")
- **Reemplazado por**: (pendiente cuando TS-009 implemente `useAsset()`). Actualizado en TS-011 (#616) con el caso de migración de tipografía.

## Contexto

`agente-frontend.md` §8 establece:

> _"Todo logo, imagen o icono corporativo vive en `frontend/public/assets/`. Nunca se importan desde `src/` mediante bundler para assets que puedan cambiar post-deploy."_

Durante **TS-005** (Estructura de carpetas), al reorganizar los 3 assets del starter
(`hero.png`, `react.svg`, `vite.svg`), se detectó que la regla estricta "todo a
`public/`" sacrifica dos propiedades valiosas para assets técnicos:

1. **Cache-busting automático** de Vite (nombres hashed → cache inmutable de 1 año).
2. **Tree-shaking** de assets no usados.
3. **Type-safety** en imports (el bundler falla en build si el archivo no existe).

Estas pérdidas no tienen justificación para assets que **no** necesitan reemplazo
en runtime (iconos técnicos, sprites de UI, ilustraciones acopladas al código).

## Decisión

Adoptar un **modelo híbrido** con criterios claros de clasificación:

| Tipo de asset                                    | Ubicación                         | Modelo                              | Ejemplo                                     |
| ------------------------------------------------ | --------------------------------- | ----------------------------------- | ------------------------------------------- |
| **Branding / contenido configurable**            | `public/assets/{categoría}/`      | URL estable + `useAsset()` (TS-009) | hero, logo, banner, imagen de marketing     |
| **Iconos técnicos / assets acoplados al código** | `src/assets/{categoría}/`         | Import de bundler                   | SVG de UI, sprites, ilustraciones de página |
| **Fuentes self-hosted**                          | `src/styles/fuentes/`             | Import de bundler + relative URL    | Inter, JetBrains Mono                       |
| **Iconos de app (favicon, PWA)**                 | `public/` (raíz)                  | URL estable                         | `favicon.ico`, `icon-192.png`               |

### Criterio de decisión (árbol)

```
¿El asset necesita reemplazarse sin recompilar el bundle?
├── Sí → public/assets/
│   Ejemplos: logos de marca, imágenes editables por marketing/admin
└── No → src/assets/
    ¿Es un SVG pequeño consumido por componentes?
    ├── Sí → src/assets/icons/
    └── No → src/assets/images/
```

## Justificación

1. **Velocidad / cache**: los assets técnicos hashed quedan cacheables de forma
   inmutable por 1 año en el navegador. Los de branding quedan con URL estable
   para permitir swap post-deploy.
2. **Ergonomía**: los iconos técnicos mantienen type-safety de TypeScript. El build
   falla si un icono se borra o renombra.
3. **Flexibilidad**: el branding puede editarse sin CI/CD. El equipo de marketing
   o el propio usuario premium podría cambiar logos sin recompilar.
4. **Escalabilidad**: con ~50 iconos técnicos, el hash + tree-shaking reduce el
   bundle inicial vs. cargar todo desde `public/`.
5. **Coherencia con TS-009**: `useAsset()` seguirá leyendo de `public/assets/manifest.json`.
   Los assets técnicos quedan fuera de ese sistema porque no necesitan runtime swap.

## Ejemplo — Migración de tipografía (TS-011)

**Caso real** que motivó refinar el criterio del árbol:

Durante TS-011 se detectó que la tipografía de la plataforma (Inter + JetBrains
Mono) estaba mal ubicada en `public/assets/tipografia/`, siguiendo la regla
estricta de "todo asset self-hosted va a `public/`".

**Análisis**: la tipografía de la plataforma **no es branding reemplazable por
el cliente**. Es parte del código: si cambia, requiere rebuild, versionado y
revisión. Tampoco es un asset runtime-swappable (no se edita post-deploy).

**Decisión**: mover a `src/styles/fuentes/`. Los `.woff2` conviven con
`fuentes.css` (que declara los `@font-face`) y son referenciados con rutas
relativas (`./Inter-Regular.woff2`). Vite los hashea al build
(`Inter-Regular-<hash>.woff2`), beneficiando el cache inmutable.

**Criterio refinado** para assets self-hosted:

| Tipo del asset                    | Ubicación              | Motivo                          |
| --------------------------------- | ---------------------- | ------------------------------- |
| Tipografía de la plataforma       | `src/styles/fuentes/`  | Código, requiere rebuild        |
| Tipografía configurable por admin | `public/assets/...`    | Runtime, editable post-deploy   |
| Logos de marca                    | `public/assets/logos/` | Branding reemplazable           |
| Iconos técnicos                   | `src/assets/icons/`    | Acoplados al código             |

**Resultado**: la regla "fuentes self-hosted → `public/assets/fonts/`" del
`agente-frontend.md` §8 se matiza. Solo van a `public/` si son branding
editable post-deploy. La tipografía de la plataforma vive en `src/styles/`.

---

## Consecuencias

### Positivas

- Cache óptima para assets estáticos.
- Type-safety en imports técnicos.
- Branding sigue siendo editable post-deploy.
- Bundle más pequeño (tree-shaking de iconos no usados).

### Negativas

- **Dos fuentes de verdad** para assets. Requiere criterio al clasificar nuevos.
- Curva de aprendizaje para devs nuevos (¿dónde va este SVG?).
- La regla "todo a `public/`" del agente queda **matizada**.

### Neutrales

- Ningún asset existente pierde funcionalidad.
- El output de `dist/` se mantiene coherente.

## Referencias

- `docs/prompts/agente-frontend.md` §8 (Assets) — actualizado con este híbrido.
- `docs/prompts/agente-frontend.md` §13 (Performance) — cache y presupuesto.
- ADR-0002: patrón de documentación de deuda.
- TS-009 (#613) — Assets runtime + `useAsset()`.

## Gatillos de revisión

- Cuando TS-009 implemente `useAsset()` y se sepa cuántos assets van a `public/`.
- Si el proyecto pasa de 100 assets técnicos y el bundle se vuelve difícil de analizar.
- Si el criterio se vuelve ambiguo en la práctica (más de 2 preguntas en reviews sobre dónde va un asset).
