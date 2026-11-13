/**
 * style-dictionary.config.js — TS-024 (#629) — DTCG 2025.10
 *
 * Estrategia: 3 builds separados (uno por tema) para evitar colisiones
 * entre light/dark/high-contrast. Cada build incluye:
 *   - themes/{theme}.tokens.json
 *   - brand-overrides/**
 *   - atoms/**
 *   - layout/**
 *
 * Output:
 *   - branding/colors.css, typography.css, layout.css, components.css, motion.css
 *   - branding/themes/{light,dark,high-contrast}.css
 *   - imported/generated/{light,dark,high-contrast}.ts
 */

import StyleDictionary from 'style-dictionary';

const toKebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
const tokenName = (t) => t.path.map(toKebab).join('-');

const BUILD_DIR = '.tokens-sd-build/';
const BRANDING_PATH = 'src/styles/branding/';
const GENERATED_PATH = 'src/components/imported/generated/';
const THEMES = ['light', 'dark', 'high-contrast'];

const BASE_SOURCES = [
  `${BUILD_DIR}brand-overrides/**/*.json`,
  `${BUILD_DIR}atoms/**/*.json`,
  `${BUILD_DIR}layout/**/*.json`,
];

// ── Formato CSS themed ───────────────────────────────────────────
StyleDictionary.registerFormat({
  name: 'css/themed',
  format: ({ dictionary, options }) => {
    const theme = options.theme || 'light';
    const selector = theme === 'light' ? ":root, [data-theme='light']" : `[data-theme='${theme}']`;
    const vars = dictionary.allTokens.map((t) => `  --${tokenName(t)}: ${t.value};`).join('\n');
    return `/* Generado por Style Dictionary (${theme}). NO editar. */\n${selector} {\n${vars}\n}\n`;
  },
});

// ── Formato CSS por categoría ───────────────────────────────────
StyleDictionary.registerFormat({
  name: 'css/category',
  format: ({ dictionary, options }) => {
    const cats = options.categories || [];
    const filtered = dictionary.allTokens.filter((t) => {
      const p = t.path.join('.');
      return cats.some((c) => p === c || p.startsWith(c + '.'));
    });
    const vars = filtered.map((t) => `  --${tokenName(t)}: ${t.value};`).join('\n');
    return `/* Generado por Style Dictionary. NO editar. */\n:root, [data-theme='light'] {\n${vars}\n}\n`;
  },
});

// ── Formato TS ───────────────────────────────────────────────────
StyleDictionary.registerFormat({
  name: 'ts/themed',
  format: ({ dictionary, options }) => {
    const theme = options.theme || 'light';
    const suffix = theme
      .split('-')
      .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
      .join('');
    const entries = dictionary.allTokens
      .map((t) => `  '--${tokenName(t)}': '${t.value}',`)
      .join('\n');
    return `// Generado por Style Dictionary (${theme}). NO editar.\nexport const tokens${suffix} = {\n${entries}\n} as const;\n`;
  },
});

// ── 3 builds CSS (uno por tema) ─────────────────────────────────
for (const theme of THEMES) {
  const sd = new StyleDictionary({
    source: [`${BUILD_DIR}themes/${theme}.tokens.json`, ...BASE_SOURCES],
    platforms: {
      css: {
        transformGroup: 'css',
        buildPath: BRANDING_PATH + 'themes/',
        files: [{ destination: `${theme}.css`, format: 'css/themed', options: { theme } }],
      },
    },
  });
  await sd.buildAllPlatforms();
}

// ── 5 CSS de branding (base light, sin colisiones) ──────────────
const brandingSD = new StyleDictionary({
  source: [`${BUILD_DIR}themes/light.tokens.json`, ...BASE_SOURCES],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: BRANDING_PATH,
      files: [
        {
          destination: 'colors.css',
          format: 'css/category',
          options: { categories: ['color', 'button'] },
        },
        {
          destination: 'typography.css',
          format: 'css/category',
          options: {
            categories: ['font', 'fontSize', 'fontWeight', 'lineHeight', 'letterSpacing'],
          },
        },
        {
          destination: 'layout.css',
          format: 'css/category',
          options: { categories: ['grid', 'space', 'breakpoint', 'zIndex'] },
        },
        {
          destination: 'components.css',
          format: 'css/category',
          options: { categories: ['radius', 'shadow', 'card', 'table', 'alert'] },
        },
        { destination: 'motion.css', format: 'css/category', options: { categories: ['motion'] } },
      ],
    },
  },
});
await brandingSD.buildAllPlatforms();

// ── 3 TS (uno por tema) ─────────────────────────────────────────
for (const theme of THEMES) {
  const sd = new StyleDictionary({
    source: [`${BUILD_DIR}themes/${theme}.tokens.json`, ...BASE_SOURCES],
    platforms: {
      ts: {
        transformGroup: 'js',
        buildPath: GENERATED_PATH,
        files: [{ destination: `${theme}.ts`, format: 'ts/themed', options: { theme } }],
      },
    },
  });
  await sd.buildAllPlatforms();
}

console.log('[style-dictionary] build completado');
