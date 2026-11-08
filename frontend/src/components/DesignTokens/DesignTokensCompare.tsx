import styles from './DesignTokensCompare.module.css';

import { useMemo } from 'react';

import type { CSSProperties } from 'react';

import { tokensDark } from '../imported/generated/dark';
import { tokensHighContrast } from '../imported/generated/high-contrast';
// Tokens generados por Style Dictionary (TS-023)
import { tokensLight } from '../imported/generated/light';
import type { DesignTokensCompareProps, ThemeName } from './DesignTokensCompare.types';

// Tokens "actuales" (branding vigente) — se leen del CSS en runtime
const TOKENS_BY_THEME: Record<ThemeName, Record<string, string>> = {
  light: tokensLight as Record<string, string>,
  dark: tokensDark as Record<string, string>,
  'high-contrast': tokensHighContrast as Record<string, string>,
};

// Secciones de tokens (todas las que existen)
const SECTIONS: Record<string, string[]> = {
  'Color · Brand': [
    '--color-brand-primary',
    '--color-brand-primary-hover',
    '--color-brand-primary-light',
    '--color-brand-accent',
    '--color-brand-accent-hover',
  ],
  'Color · Semantic': [
    '--color-semantic-success',
    '--color-semantic-success-hover',
    '--color-semantic-danger',
    '--color-semantic-danger-hover',
    '--color-semantic-warning',
    '--color-semantic-warning-hover',
    '--color-semantic-info',
    '--color-semantic-info-hover',
  ],
  'Color · Neutral': [
    '--color-bg',
    '--color-surface',
    '--color-border',
    '--color-text',
    '--color-text-muted',
    '--color-text-inverse',
  ],
  Button: [
    '--button-primary-bg',
    '--button-primary-bg-hover',
    '--button-primary-fg',
    '--button-secondary-fg',
    '--button-secondary-border',
    '--button-ghost-fg',
    '--button-success-bg',
    '--button-danger-bg',
    '--button-warning-bg',
    '--button-info-bg',
  ],
  Card: ['--card-color-bg', '--card-color-border', '--card-radius', '--card-shadow'],
  Searchbar: [
    '--searchbar-color-bg',
    '--searchbar-color-border',
    '--searchbar-color-text',
    '--searchbar-color-placeholder',
    '--searchbar-spacing-padding',
    '--searchbar-spacing-gap',
    '--searchbar-spacing-icon-size',
  ],
  Spacing: [
    '--space-1',
    '--space-2',
    '--space-3',
    '--space-4',
    '--space-5',
    '--space-6',
    '--space-8',
    '--space-10',
  ],
  Typography: [
    '--font-sans',
    '--font-mono',
    '--font-size-xs',
    '--font-size-sm',
    '--font-size-base',
    '--font-size-lg',
    '--font-size-xl',
    '--font-size-2xl',
    '--font-size-3xl',
    '--font-size-4xl',
    '--font-weight-regular',
    '--font-weight-medium',
    '--font-weight-semibold',
    '--font-weight-bold',
    '--line-height-tight',
    '--line-height-normal',
    '--line-height-relaxed',
    '--letter-spacing-tight',
    '--letter-spacing-normal',
    '--letter-spacing-wide',
  ],
  Radius: ['--radius-sm', '--radius-md', '--radius-lg', '--radius-xl', '--radius-full'],
  Shadow: [
    '--shadow-xs',
    '--shadow-sm',
    '--shadow-md',
    '--shadow-lg',
    '--shadow-xl',
    '--shadow-2xl',
  ],
  Breakpoint: [
    '--breakpoint-sm',
    '--breakpoint-md',
    '--breakpoint-lg',
    '--breakpoint-xl',
    '--breakpoint-2xl',
  ],
  'Z-index': [
    '--z-index-base',
    '--z-index-dropdown',
    '--z-index-sticky',
    '--z-index-overlay',
    '--z-index-modal',
    '--z-index-popover',
    '--z-index-tooltip',
    '--z-index-toast',
  ],
  Motion: [
    '--motion-duration-instant',
    '--motion-duration-fast',
    '--motion-duration-normal',
    '--motion-duration-slow',
    '--motion-duration-slower',
    '--motion-easing-spring-soft',
    '--motion-easing-spring-medium',
    '--motion-easing-expo-out',
  ],
  Border: [
    '--border-width-thin',
    '--border-width-medium',
    '--border-width-thick',
    '--border-style-solid',
    '--border-style-dashed',
    '--border-style-none',
  ],
  Opacity: ['--opacity-disabled', '--opacity-hover', '--opacity-overlay', '--opacity-ghost'],
  Grid: ['--grid-columns', '--grid-gutter', '--grid-container-max-width'],
};

function readCurrentValue(tokenName: string): string {
  if (typeof window === 'undefined') return '(SSR)';
  return getComputedStyle(document.documentElement).getPropertyValue(tokenName).trim() || '(vacío)';
}

function readGeneratedValue(theme: ThemeName, tokenName: string): string {
  const map = TOKENS_BY_THEME[theme];
  return map[tokenName] || '(no generado)';
}

const swatchStyle = (value: string): CSSProperties | undefined => {
  if (value.startsWith('#') || value.startsWith('rgb')) {
    return { background: value };
  }
  return undefined;
};

export function DesignTokensCompare({
  theme = 'light',
  onlyDiff = false,
}: DesignTokensCompareProps) {
  const sections = useMemo(() => {
    return Object.entries(SECTIONS).map(([name, tokens]) => {
      const rows = tokens.map((tokenName) => {
        const current = readCurrentValue(tokenName);
        const generated = readGeneratedValue(theme, tokenName);
        const equal = current === generated;
        return { tokenName, current, generated, equal };
      });
      const diffCount = rows.filter((r) => !r.equal).length;
      return { name, rows, diffCount };
    });
  }, [theme]);

  return (
    <div className={styles.container} data-theme={theme}>
      <h2 className={styles.title}>
        DesignTokens / Compare — tema: <code>{theme}</code>
      </h2>
      <p className={styles.subtitle}>
        Columna izquierda: branding actual (<code>frontend/src/styles/branding/</code>). Columna
        derecha: tokens generados por Style Dictionary (
        <code>frontend/src/components/imported/generated/</code>).
      </p>

      {sections.map(({ name, rows, diffCount }) => {
        if (onlyDiff && diffCount === 0) return null;
        return (
          <section key={name} className={styles.section}>
            <h3 className={styles.sectionTitle}>
              {name}{' '}
              <span className={styles.diffCount}>
                {diffCount === 0 ? '✓ idéntico' : `${diffCount} dif.`}
              </span>
            </h3>
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>Token</th>
                  <th>Actual</th>
                  <th>Generado</th>
                </tr>
              </thead>
              <tbody>
                {rows.map(({ tokenName, current, generated, equal }) => (
                  <tr key={tokenName} className={equal ? styles.rowEqual : styles.rowDiff}>
                    <td>
                      <code>{tokenName}</code>
                    </td>
                    <td>
                      <span className={styles.swatch} style={swatchStyle(current)} />
                      <code>{current}</code>
                    </td>
                    <td>
                      <span className={styles.swatch} style={swatchStyle(generated)} />
                      <code>{generated}</code>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>
        );
      })}
    </div>
  );
}
