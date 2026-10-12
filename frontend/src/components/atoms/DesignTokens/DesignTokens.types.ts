/**
 * Tipos del átomo DesignTokens.
 *
 * DesignTokens no recibe datos: solo la sección a mostrar y metadatos
 * opcionales para integración.
 */
/** Catálogo de secciones del átomo DesignTokens.
 *  - colors: paleta de colores (brand + semantic + neutral)
 *  - typography: familias, escalas, pesos, line-heights, letter-spacing
 *  - spacing, radius, shadows: primitivas de layout
 *  - layout: grid, breakpoints, z-index
 *  - motion: duraciones, easings, stagger
 */
export type DesignTokensSection =
  'colors' | 'typography' | 'spacing' | 'radius' | 'shadows' | 'layout' | 'motion';

export interface DesignTokensProps {
  /** Sección específica a mostrar. Si se omite, se renderizan todas. */
  section?: DesignTokensSection;
  /** data-testid del contenedor raíz. */
  dataTestId?: string;
  /** Clase adicional para integración. */
  className?: string;
}
