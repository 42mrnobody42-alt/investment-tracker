## Contexto

<Por qué esta tarea. 1-2 líneas.>

## Entregable

- <Archivo(s) / componente(s) / configuración>

## Criterios de aceptación

Cada criterio DEBE tener un código único `**CA_##:**` al inicio. El MISMO
código se usa como primer argumento de `check()` en el validador
(`docs/scrum/kanban/scripts/validators/validate-tsNNN.sh`). Sin coincidencia
código↔criterio, la validación no cubre el criterio.

Los CAs técnicos van en lista plana (sin sub-secciones). Los CAs de
documentación van en la sección siguiente (`## Documentación obligatoria`),
con numeración continua (`CA_NN`, `CA_NN+1`, ...).

- [ ] **CA_01:** <criterio técnico 1>
- [ ] **CA_02:** <criterio técnico 2>

## Documentación obligatoria (al final de la tarea)

Una vez verificados los CAs técnicos y el runner en verde, actualizar los
documentos correspondientes. Cada CA debe indicar:

1. **Archivo** y **sección específica** (ej. `README.md §Frontend`, no solo
   `README.md`).
2. **Qué información añadir** (contenido concreto, no "mencionar el archivo").
3. **Qué NO duplicar** (si la info ya vive en otro doc, actualizar solo el
   dueño; el resto van punteros).

Documentos estándar por capa:

- `README.md` — estado general, referencia, tablas por dominio.
- `prompt_inicial.md` — reglas core del proyecto (reglas numeradas).
- `agente-frontend.md` / `agente-backend.md` / `agente-database.md` — reglas
  de la capa correspondiente.
- `convenciones.md` — convenciones de código/tests del frontend.
- `pruebas.md` — runner unificado + tests + política.
- ADRs (`docs/tecnica/**/deuda-tecnica/*.md`) — si aplica.

- [ ] **CA_NN:** `README.md` §<sección concreta>: <qué añadir>
- [ ] **CA_NN+1:** `prompt_inicial.md`: <qué regla + número>
- [ ] **CA_NN+2:** `agente-frontend.md` §<sección>: <qué añadir>

**Regla**: si la tarea NO requiere actualizar algún doc, no se incluye ese CA.
Un CA de doc es válido solo si su ausencia rompe la coherencia del proyecto.

### Si la tarea crea funcionalidad nueva

Aplica **solo** cuando la tarea introduce funcionalidad nueva:

- Componentes (atoms, molecules, organisms).
- Vistas (horizontal / vertical).
- Servicios (HTTP, storage, etc.).
- Hooks personalizados.
- Features (login, registro, perfil, calculadora, dashboard).
- Integraciones (consumo de endpoints, i18n, auth).

**No** aplica a: bug fixes, refactors, cambios de configuración (`.env`,
`vite.config.ts`, tsconfig), tests que validan funcionalidad existente, cambios
de documentación.

Debe crear **1 archivo nuevo** con **2 diagramas** (gerencial + técnico):

**`docs/tecnica/04-frontend-react-css-moderno/diagramas/secuencia/<nombre-funcion>.md`**

---

#### A. Diagrama gerencial

- **Qué hace**: 1 párrafo de valor para el usuario (sin tecnicismos).
- **Quién lo usa y para qué**: casos de uso reales, roles involucrados.
- **Precondiciones**: estado previo (sesión, rol, datos existentes).
- **Componentes del frontend involucrados y qué hace cada uno** (en lenguaje
  del usuario):

  | Componente     | Qué hace (en lenguaje del usuario)                       |
  | -------------- | -------------------------------------------------------- |
  | `LoginView`    | Pantalla donde el usuario ingresa sus credenciales.      |
  | `useAuth`      | Mantiene la sesión activa y ejecuta el login/logout.     |
  | `auth.service` | Traduce las acciones del usuario en llamadas al API.     |
  | `http.ts`      | Envía las peticiones y adjunta el token automáticamente. |

- **Capas del sistema involucradas** (todas son **cajas negras**; el detalle
  técnico de backend/DB/externos vive en sus documentos propios):

  | Capa               | Qué hace (en lenguaje gerencial)                                        |
  | ------------------ | ----------------------------------------------------------------------- |
  | Frontend           | Muestra la interfaz y ejecuta las acciones del usuario.                 |
  | Backend            | Valida las reglas de negocio, emite respuestas y registra la operación. |
  | Base de Datos      | Almacena los datos de negocio y la auditoría.                           |
  | Servicios externos | SMTP, pasarelas de pago u otros (solo si la funcionalidad los usa).     |

- **Diagrama Mermaid** `flowchart LR` — **flujo del valor por capas**, cada
  capa es UNA caja. La descomposición del frontend está en §B y en los
  documentos técnicos propios de backend/DB/externos.

  ```mermaid
  flowchart LR
    U[Usuario] --> F[Frontend<br/>LoginView]
    F --> B[Backend<br/>API Auth]
    B --> DB[(Base de Datos<br/>Usuarios + Auditoría)]
  ```

  Nota: si la funcionalidad usa servicios externos (ej. SMTP en recuperación),
  se añade como capa adicional en el diagrama.

---

#### B. Diagrama técnico frontend

Descompone **solo el frontend**. Backend/DB/externos siguen como **caja negra**
(su técnico vive en sus docs propios). Se documenta el recorrido interno:
función → parámetros → respuesta → qué hace → endpoint invocado en backend.

- **Recorrido del frontend paso a paso**:

  | #   | Función ejecutada                           | Parámetros de entrada                         | Respuesta                                                                           | Qué hace                                                   |
  | --- | ------------------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------- | ---------------------------------------------------------- |
  | 1   | `LoginView.submit()`                        | `event: FormEvent`                            | `void`                                                                              | Previene default, extrae `username` y `password` del form. |
  | 2   | `useAuth().login(username, password)`       | `username: string, password: string`          | `Promise<void>`                                                                     | Llama al servicio y actualiza el contexto de sesión.       |
  | 3   | `auth.service.login(username, password)`    | `username: string, password: string`          | `Promise<LoginResponse>`                                                            | Construye la petición y valida la forma de la respuesta.   |
  | 4   | `http.post('/api/auth/login', body)`        | `url: string, body: LoginRequest`             | `Promise<LoginResponse>`                                                            | Adjunta `Content-Type`, envía, gestiona errores de red.    |
  | 5   | `Backend` (caja negra)                      | `POST /api/auth/login { username, password }` | `200 { token, refreshToken }` \| `401 AUTH-001` \| `423 AUTH-002` \| `429 RATE-001` | Contrato completo en `README.md` §3.                       |
  | 6   | `useAuth().setSession(token, refreshToken)` | `token: string, refreshToken: string`         | `void`                                                                              | Guarda tokens en `tokenStorage` y actualiza el estado.     |
  | 7   | `navigate('/home')`                         | `path: string`                                | `void`                                                                              | Redirige al dashboard autenticado.                         |

- **Diagrama Mermaid** `sequenceDiagram` — solo actores del frontend +
  Backend como caja negra:

  ```mermaid
  sequenceDiagram
    actor U as Usuario
    participant V as LoginView
    participant H as useAuth (hook)
    participant S as auth.service
    participant C as http.ts
    participant B as Backend (caja negra)

    U->>V: submit(form)
    V->>H: login(username, password)
    H->>S: login(username, password)
    S->>C: post('/api/auth/login', { username, password })
    C->>B: POST /api/auth/login
    B-->>C: 200 { token, refreshToken } | 4xx { code }
    C-->>S: LoginResponse
    S-->>H: LoginResponse
    H->>H: setSession(token, refreshToken)
    H-->>V: success
    V->>U: navigate('/home')
  ```

---

**Edge cases** (aplican a ambos diagramas):

- ¿Qué pasa si X falla? (red, timeout, 401, 423, rate limit).
- Mensaje mostrado al usuario (i18n key) y acción esperada.
- Recuperación: reintento, bloqueo de botón, redirect.

**Códigos de error** relevantes (`AUTH-*`, `REG-*`, `REC-*`, `PWD-*`,
`VAL-*`, `BIZ-*`, `SYS-*`) con la **acción del frontend** para cada uno.
Contrato completo: `README.md` §3.

**Referencias cruzadas**: link a `README.md` §3 (contrato backend) y
`pruebas.md` (tests relacionados).

---

**2. Entrada en el índice del `README.md`** §4 Frontend → subsección "Diagramas
de secuencia" con link al nuevo doc.

**3. Cross-reference** en el archivo implementado: JSDoc o `// Ver <link>`.

**CAs correspondientes:**

- [ ] **CA_NN:** `docs/tecnica/04-frontend-react-css-moderno/diagramas/secuencia/<nombre>.md` con: (a) **diagrama gerencial** — tabla de componentes frontend + tabla de capas (todas cajas negras) + `flowchart LR` por capas; (b) **diagrama técnico frontend** — tabla función/parámetros/respuesta/qué hace + `sequenceDiagram` con backend como caja negra; (c) edge cases; (d) códigos de error con acción del frontend; (e) links a `README.md` §3 y `pruebas.md`.
- [ ] **CA_NN+1:** `README.md` §4 Frontend → "Diagramas de secuencia": entrada con link.
- [ ] **CA_NN+2:** archivo implementado → JSDoc o `// Ver <link>`.

## Estimación

<N>h

## Dependencias

- **US padre**: (referencia, la sección del final ya la incluye)
- **TS previas**: <TS-XXX, TS-YYY o "Ninguna">
- **Hitos**: <si depende de infraestructura externa>

## US padre

US-XXX (#N)
