export type ThemeName = 'light' | 'dark' | 'high-contrast';

export interface DesignTokensCompareProps {
  /** Tema a comparar. Default: 'light'. */
  theme?: ThemeName;
  /** Si true, solo muestra secciones con diferencias. */
  onlyDiff?: boolean;
}
