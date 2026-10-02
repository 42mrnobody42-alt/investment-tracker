# ADR-0003 — Modelo híbrido de assets: `public/` (branding) + `src/assets/` (técnicos)

- **Estado**: Aceptada
- **Fecha**: 2026-10-02
- **Capa**: Frontend (React + TypeScript + Vite)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: TS-005 (#610), US-002 (#566), FT-001 (#556), CAP-01 (#554), ADR-0002
- **Reemplaza a**: Interpretación estricta de `agente-frontend.md` §8 ("todo a `public/`")
- **Reemplazado por**: (pendiente cuando TS-009 implemente `useAsset()`)

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
| **Fuentes self-hosted**                          | `public/assets/fonts/` (regla §8) | URL estable                         | Inter, Roboto                               |
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
