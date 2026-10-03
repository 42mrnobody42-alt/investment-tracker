import js from '@eslint/js';
import prettierConfig from 'eslint-config-prettier';
import importPlugin from 'eslint-plugin-import';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import simpleImportSort from 'eslint-plugin-simple-import-sort';
import { defineConfig, globalIgnores } from 'eslint/config';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default defineConfig([
  globalIgnores(['dist', 'node_modules', 'coverage', 'storybook-static']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      js.configs.recommended,
      tseslint.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
      jsxA11y.flatConfigs.recommended,
    ],
    languageOptions: {
      globals: globals.browser,
    },
    plugins: {
      import: importPlugin,
      'simple-import-sort': simpleImportSort,
    },
    settings: {
      'import/resolver': {
        typescript: {
          alwaysTryTypes: true,
          project: './tsconfig.app.json',
        },
        node: true,
      },
    },
    rules: {
      // ===== Orden de imports =====
      'simple-import-sort/imports': [
        'error',
        {
          groups: [
            // 1. Estilos (CSS Modules, hojas globales)
            ['\\.css$'],
            // 2. React core
            ['^react$', '^react-dom'],
            // 3. Paquetes externos
            ['^@?\\w'],
            // 4. Alias internos del proyecto
            ['^@app', '^@components', '^@views', '^@shared', '^@i18n', '^@styles'],
            // 5. Imports relativos
            ['^\\.'],
          ],
        },
      ],
      'simple-import-sort/exports': 'error',

      // ===== Salud de imports =====
      'import/first': 'error',
      'import/newline-after-import': 'error',
      'import/no-duplicates': 'error',
      // Deshabilitado: TypeScript ya verifica la existencia de módulos.
      // El resolver de ESLint no soporta paths sin baseUrl (TS 6+).
      'import/no-unresolved': 'off',
      'import/no-cycle': 'error',

      // ===== Prettier SIEMPRE al final =====
      // Deshabilita las reglas de ESLint que chocan con Prettier.
      ...prettierConfig.rules,
    },
  },
]);
