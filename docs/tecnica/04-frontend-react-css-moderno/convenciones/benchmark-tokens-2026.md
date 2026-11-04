# Benchmark - Design Tokens (2026)

> **Task**: TS-022 (#627) - Backup + benchmark + decision + Figma doc.
> **Feature**: FT-002 (#557) - Design tokens, i18n y assets runtime.
> **Fecha**: 2026-11-03.

## 1. Herramientas evaluadas

| Herramienta                     | Tipo                                  | Pros                                                                            | Contras                                                                | Limitaciones free                        |
| :------------------------------ | :------------------------------------ | :------------------------------------------------------------------------------ | :--------------------------------------------------------------------- | :--------------------------------------- |
| **Style Dictionary v5**         | Compilador DTCG -> CSS/TS/iOS/Android | Estandar de facto, soporta DTCG 2025.10, multi-plataforma, tipos TS automaticos | Requiere pipeline de build, no autoria visual                          | 100% free (open source)                  |
| **Tokens Studio**               | Plugin Figma + sync GitHub            | Autoria visual, export DTCG, sync a GitHub                                      | Free sin sync automatico a GitHub (solo export manual); requiere Figma | Free: sin sync auto, solo export manual  |
| **Figma Variables**             | Nativo Figma                          | Integrado en Figma, sin plugins, tipado                                         | 1 modo por coleccion en free; sin API REST en free; export manual      | Free: 1 modo por coleccion, sin API REST |
| **CSS custom properties puras** | Nativo CSS                            | Cero tooling, runtime theming, funciona en cualquier browser                    | Sin pipeline, sin tipos TS automaticos, sin DTCG formal                | 100% free                                |

### Videos de referencia (max 10 min por herramienta)

| Herramienta           | Video                                                       | Canal                     | Duracion          |
| :-------------------- | :---------------------------------------------------------- | :------------------------ | :---------------- |
| Style Dictionary v5   | "Style Dictionary: Transforming and Generating Tokens"      | CoddyKit                  | 5-10 min          |
| Tokens Studio         | "Tokens Studio for Figma Quickstart" (capitulos 0:00-5:00)  | Tokens Studio             | 5 min (relevante) |
| Figma Variables       | "Variables for brand designers"                             | Figma (oficial)           | ~8 min            |
| CSS custom properties | "CSS Variables for Theming"                                 | CoddyKit Frontend Academy | 5-10 min          |
| Pipeline completo     | "Design Tokens Workflow: Figma -> Style Dictionary -> Code" | Comunidad                 | <10 min           |

## 2. DTCG base evaluados

| Opcion                        | Pros                                                                                                | Contras                                          | Decision   |
| :---------------------------- | :-------------------------------------------------------------------------------------------------- | :----------------------------------------------- | :--------- |
| **Made Good Designs Starter** | OKLCH moderno (2025.10), tipografia + spacing + radius + shadows + motion, disenado para customizar | Menos enterprise, requiere adaptacion            | ELEGIDA    |
| **IBM Carbon DTCG**           | Oficial, enterprise, estable, bien mantenido                                                        | Colores hex (no OKLCH), mas rigido, curva mayor  | Descartada |
| **Salesforce Design System**  | Muy completo, accesible                                                                             | Demasiado opinado, dificil de adaptar            | Descartada |
| **Custom (no importar)**      | Control total                                                                                       | Rompe el objetivo de importar y ajustar; +tiempo | Descartada |

**Decision**: **Made Good Designs Starter** (OKLCH + moderno + adaptable).

## 3. Decision final

- **Compilador**: **Style Dictionary v5** (5.8.0) como devDependency.
- **DTCG base**: **Made Good Designs Starter**.
- **Figma**: Figma free + Tokens Studio free con export manual (sync auto es paid).
- **Temas multi-modo**: viven en frontend/src/components/imported/themes/*.tokens.json (light/dark/high-contrast).
- **Motion**: diferido a TS-147 (gsap se instala alli).
- **Ruta oficial de tokens**: frontend/src/components/imported/.

## 4. Pipeline

1. Figma free (primitivos + semanticos) -> export DTCG manual.
2. JSON en frontend/src/components/imported/{primitives,semantic}/.
3. Temas en frontend/src/components/imported/themes/*.tokens.json.
4. Overrides en frontend/src/components/imported/brand-overrides/.
5. style-dictionary build -> frontend/src/styles/branding/*.css + frontend/src/shared/types/tokens.ts.
