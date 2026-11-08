/**
 * style-dictionary.config.js — TS-023 (#628)
 *
 * Usa archivos convertidos a formato legacy (value/type) porque
 * Style Dictionary v5 NO soporta completamente DTCG 2025.10.
 *
 * Flujo: convert-to-sd-format.mjs → .tokens-sd-build/ → este config → generated/
 */

import StyleDictionary from 'style-dictionary';

// Convierte camelCase a kebab-case: primaryHover → primary-hover
const toKebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
const tokenName = (t) => t.path.map(toKebab).join('-');

const SOURCE = ['.tokens-sd-build/**/*.json'];
const BUILD_PATH = 'src/components/imported/generated/';
const THEMES = ['light', 'dark', 'high-contrast'];

StyleDictionary.registerFormat({
  name: 'css/themed',
  format: ({ dictionary, options }) => {
    const theme = options.theme || 'light';
    const selector = theme === 'light' ? ':root' : `[data-theme='${theme}']`;
    const filtered = dictionary.allTokens.filter((t) => {
      const fp = t.filePath || '';
      if (fp.includes('brand-overrides/') || fp.includes('atoms/') || fp.includes('layout/'))
        return true;
      return fp.includes(`themes/${theme}.json`);
    });
    const vars = filtered.map((t) => `  --${tokenName(t)}: ${t.value};`).join('\n');
    return `/* Generado por Style Dictionary (${theme}). NO editar. */\n${selector} {\n${vars}\n}\n`;
  },
});

StyleDictionary.registerFormat({
  name: 'ts/themed',
  format: ({ dictionary, options }) => {
    const theme = options.theme || 'light';
    const suffix = theme
      .split('-')
      .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
      .join('');
    const filtered = dictionary.allTokens.filter((t) => {
      const fp = t.filePath || '';
      if (fp.includes('brand-overrides/') || fp.includes('atoms/') || fp.includes('layout/'))
        return true;
      return fp.includes(`themes/${theme}.json`);
    });
    const entries = filtered.map((t) => `  '--${tokenName(t)}': '${t.value}',`).join('\n');
    return `// Generado por Style Dictionary (${theme}). NO editar.\nexport const tokens${suffix} = {\n${entries}\n} as const;\n`;
  },
});

const cssSD = new StyleDictionary({
  source: SOURCE,
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: BUILD_PATH,
      files: [
        { destination: 'tokens.css', format: 'css/themed', options: { theme: 'light' } },
        ...THEMES.map((theme) => ({
          destination: `themes/${theme}.css`,
          format: 'css/themed',
          options: { theme },
        })),
      ],
    },
  },
});
await cssSD.buildAllPlatforms();

for (const theme of THEMES) {
  const sd = new StyleDictionary({
    source: SOURCE,
    platforms: {
      ts: {
        transformGroup: 'js',
        buildPath: BUILD_PATH,
        files: [{ destination: `${theme}.ts`, format: 'ts/themed', options: { theme } }],
      },
    },
  });
  await sd.buildAllPlatforms();
}

console.log('[style-dictionary] build completado');
