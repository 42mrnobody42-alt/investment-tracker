# Proxy de desarrollo `/api` — `vite.config.ts`

> **Tarea**: TS-020 (#625) — `vite.config.ts` con proxy `/api`.
> **Feature**: US-006 (#570) — Variables de entorno y proxy `/api`.
> **Archivo**: `frontend/vite.config.ts`.
> **Guía completa**: [`convenciones/proxy-developer.md`](../convenciones/proxy-developer.md).

El proxy de Vite permite que el frontend en dev (`:3000`) consuma `/api/*`
contra el backend (`:7700`) sin CORS y sin hardcodear el puerto del backend
en el código React. Solo aplica a `npm run dev` (por diseño de Vite: `vite build`
ignora la clave `server`).

## A. Diagrama gerencial — capas como cajas negras

```mermaid
flowchart LR
  subgraph Browser["Navegador del desarrollador"]
    FE["Frontend React (Vite dev :3000)"]
  end
  subgraph Local["Máquina local — entorno dev"]
    VITE["Vite dev server :3000<br/>server.proxy /api"]
    BE["Backend Spring Boot :7700"]
    DB[("PostgreSQL :5432")]
  end
  FE -- "fetch('/api/test/health')" --> VITE
  VITE -- "proxy a http://localhost:7700/api/*<br/>changeOrigin true, sin rewrite" --> BE
  BE -- "JDBC" --> DB
```

### Componentes y qué hace cada uno

| Componente                    | Qué hace                                                                                                                                                      |
| :---------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Frontend React (`:3000`)      | Consume `/api/*` con `fetch`/axios relativo, sin hardcodear `:7700` ni el host.                                                                               |
| Vite dev server (`:3000`)     | Intercepta `/api/*` vía `server.proxy` y lo reenvía al backend. `changeOrigin: true` reescribe el header `Host`. Sin `rewrite`: el path `/api/*` se preserva. |
| Backend Spring Boot (`:7700`) | Expone `/api/*` (auth, encryption, test). Puerto `application.yml → server.port`.                                                                             |
| PostgreSQL (`:5432`)          | Persistencia (caja negra para el frontend).                                                                                                                   |

## B. Diagrama técnico frontend — secuencia

```mermaid
sequenceDiagram
  autonumber
  participant U as Dev (navegador)
  participant FE as React app :3000
  participant V as Vite dev server :3000 (server.proxy /api)
  participant B as Backend :7700 (caja negra)

  U->>FE: fetch('/api/test/health')
  FE->>V: GET /api/test/health
  V->>V: match '/api' en server.proxy
  V->>B: GET http://localhost:7700/api/test/health<br/>(Host reescrito por changeOrigin)
  B-->>V: 200 { status: 'UP', ... }
  V-->>FE: 200 { status: 'UP', ... }
  FE-->>U: Render / log

  Note over V,B: Sin rewrite: /api/foo -> :7700/api/foo (contrato fijo).<br/>vite build ignora server: el proxy NO viaja a produccion.<br/>Storybook :3010 no hereda este proxy.
```

### Funciones / configuración

| Pieza                          | Parámetros                                              | Respuesta              | Qué hace                                                             |
| :----------------------------- | :------------------------------------------------------ | :--------------------- | :------------------------------------------------------------------- |
| `server.proxy['/api']`         | `target: 'http://localhost:7700'`, `changeOrigin: true` | Proxy HTTP al backend  | Reenvía toda petición bajo `/api/*` al backend.                      |
| Sin `rewrite`                  | —                                                       | Path preservado        | `/api/foo` → `http://localhost:7700/api/foo`.                        |
| Sin `preview.proxy`            | —                                                       | `vite preview` intacto | Solo dev. `vite build` no incluye proxy.                             |
| Comentario en `vite.config.ts` | —                                                       | —                      | Apunta a `backend/src/main/resources/application.yml → server.port`. |

## Sincronización de puerto

El puerto `7700` en `vite.config.ts` **debe** coincidir con
`backend/src/main/resources/application.yml → server.port`. El comentario
del bloque `proxy` guía al siguiente dev a mantenerlos sincronizados.

Si el backend cambia de puerto:

1. Actualizar `application.yml → server.port`.
2. Actualizar `frontend/vite.config.ts → server.proxy['/api'].target`.
3. Actualizar este doc.

Sin `rewrite` el contrato `/api/*` se mantiene estable entre dev, backend y
(donde aplique) nginx.
