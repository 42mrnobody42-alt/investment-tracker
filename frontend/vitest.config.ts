import react from '@vitejs/plugin-react';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vitest/config';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/**
 * Configuración de Vitest.
 *
 * Reutiliza el plugin de React. Los alias se definen explícitamente porque
 * los tests viven fuera de `src/` y `resolve.tsconfigPaths: true` no los
 * resuelve para archivos fuera del `include` de `tsconfig.app.json`.
 *
 * Cobertura: 80% en todos los archivos del proyecto (regla de
 * `agente-frontend.md` §14). Ver ADR-0009 para exclusiones justificadas.
 */
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@app': path.resolve(__dirname, 'src/app'),
      '@components': path.resolve(__dirname, 'src/components'),
      '@views': path.resolve(__dirname, 'src/views'),
      '@shared': path.resolve(__dirname, 'src/shared'),
      '@i18n': path.resolve(__dirname, 'src/i18n'),
      '@styles': path.resolve(__dirname, 'src/styles'),
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./tests/unit/setup.ts'],
    css: {
      modules: {
        classNameStrategy: 'non-scoped',
      },
    },
    include: ['src/**/*.test.{ts,tsx}', 'tests/**/*.test.{ts,tsx}'],
    exclude: ['node_modules', 'dist', 'storybook-static'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: [
        // Entry point: side effects de React (createRoot), no testeable
        'src/main.tsx',
        // Starter demo de Vite — se reemplaza en US-024/025 (ver ADR-0009)
        'src/app/App.tsx',
        // Archivos sin lógica testeable
        'src/**/*.stories.tsx',
        'src/**/*.types.ts',
        'src/**/index.ts',
        'src/vite-env.d.ts',
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
});
