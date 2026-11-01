# Proxy de desarrollo `/api` (`vite.config.ts`)

> **Creado en**: TS-020 (#625) — `vite.config.ts` con proxy `/api`.
> **US padre**: US-006 (#570) — Variables de entorno y proxy `/api`.
> **Diagramas**: [`../diagramas/secuencia/proxy-api-dev.md`](../diagramas/secuencia/proxy-api-dev.md) — gerencial + técnico.
> **Archivo**: `frontend/vite.config.ts`.

En `npm run dev`, Vite enruta `/api/*` al backend (`http://localhost:7700`) usando
`server.proxy`. Sin rewrite: `/api/foo` → `http://localhost:7700/api/foo` (contrato fijo).
`vite build` **ignora** la clave `server`, por lo que el proxy **no viaja a producción**.

## Configuración exacta

```ts
// frontend/vite.config.ts
export default defineConfig({
  // ...
  server: {
    port: 3000,
    strictPort: true,
    // Proxy /api → backend en dev (server.proxy es ignorado por `vite build` por diseño).
    // El puerto debe coincidir con backend/src/main/resources/application.yml → server.port (7700).
    // Sin rewrite: /api/foo → http://localhost:7700/api/foo (contrato fijo con el backend).
    proxy: {
      "/api": {
        target: "http://localhost:7700",
        changeOrigin: true,
      },
    },
  },
});
```

## Reglas

1. **Sin `rewrite`**: el contrato `/api/*` es fijo entre dev, backend y nginx.
   `/api/foo` → `http://localhost:7700/api/foo`.
2. **`changeOrigin: true`**: reescribe el header `Host` al del target (`:7700`).
3. **Solo dev**: `vite build` ignora `server` → el proxy **no viaja a producción**
   (producción usa nginx reverse proxy).
4. **Sincronización de puerto**: el `target` (`http://localhost:7700`) **debe** coincidir
   con `backend/src/main/resources/application.yml → server.port`. Si el backend cambia de
   puerto, actualizar `vite.config.ts`, este doc y el comentario del bloque `proxy` en el
   mismo PR.
5. **Storybook (`:3010`)** no hereda este proxy (no lee `vite.config.ts`). Los requests
   `/api/*` desde stories se mockean en el story o se hacen contra el backend
   explícitamente.
6. **Código React**: usar `fetch('/api/...')` o `import.meta.env.VITE_API_URL`
   (contrato `/api` en `frontend/.env`). Nunca `http://localhost:7700/...`.

## Cómo verificar

Con `npm run dev` corriendo y el backend arriba, desde la consola del navegador:

```js
const r = await fetch("/api/test/health");
console.log(r.status, await r.json());
// → 200 { status: 'UP', ... }
```

## Diagramas

- [`../diagramas/secuencia/proxy-api-dev.md`](../diagramas/secuencia/proxy-api-dev.md) —
  diagrama gerencial (cajas negras: Frontend / Vite / Backend / DB) y técnico
  (sequenceDiagram con `fetch` → proxy → backend).

## Referencias

- `README.md` §Frontend — resumen y link a este doc.
- `docs/prompts/prompt_inicial.md` regla 37 — regla obligatoria del proxy.
- `docs/prompts/agente-frontend.md` §14.12 — patrón obligatorio `server.proxy`.
- `docs/tecnica/04-frontend-react-css-moderno/convenciones/convenciones.md` — índice
  de convenciones del frontend.
