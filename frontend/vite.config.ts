import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    tsconfigPaths: true,
  },
  server: {
    port: 3000,
    strictPort: true,
    // Proxy /api → backend en dev (server.proxy es ignorado por `vite build` por diseño).
    // El puerto debe coincidir con backend/src/main/resources/application.yml → server.port (7700).
    // Sin rewrite: /api/foo → http://localhost:7700/api/foo (contrato fijo con el backend).
    proxy: {
      '/api': {
        target: 'http://localhost:7700',
        changeOrigin: true,
      },
    },
  },
});
