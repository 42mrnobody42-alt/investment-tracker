/**
 * Rutas de assets servidos desde `public/`.
 *
 * Los assets de branding/contenido viven en `public/assets/` (ver
 * `agente-frontend.md` §8 y ADR-0003) para poder reemplazarse sin recompilar
 * el bundle.
 *
 * Los iconos tecnicos y assets consumidos por codigo viven en `src/assets/`
 * y se importan directamente con el bundler de Vite (cache-busting + tree-shaking).
 *
 * Cuando llegue `useAsset()` (TS-009), este archivo se reemplazara por
 * llamadas a `useAsset('hero')` con el manifest.json.
 */
export const ASSETS = {
  HERO: '/assets/images/starter/hero.png',
} as const;
