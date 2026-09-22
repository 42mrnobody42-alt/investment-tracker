# Quiero crear una aplicación web que tenga los siguientes componentes:

Usar contenedores docker para los servicios postgresql para la DB, tomcat para el servicio web.
Los lenguajes de programación que vamos a usar es pl/sql, java para la logica ultima version LTS.
Para el frontend quiero usar react css para que se vea lo mas moderno y potente.
Tengo un servidor en pop os 22.04 y tengo instalado visual estudio code, necesito una guia para programar y probar en local desde mi servidor.
El versionamiento de todos los archivos seran llevados en un nuevo proyecto de git github separados por carpetas para Docker, DB, back y front.
Quiero que crees un paso a paso del procedimiento de toda la programación con diagramas, modelo MER y documentos.
Quiero que guardes este promp en un directorio de promps para el proyecto en formato MD

## 📚 Documentos de referencia obligatoria

Antes de generar cualquier propuesta, código, script o decisión arquitectónica, la IA DEBE consultar y respetar los siguientes documentos. Son las fuentes de verdad del proyecto:

1. `README.md` (raíz de `investment-tracker/`)
   - Estado general del proyecto, versión vigente (Version/Release/Hotfix), arquitectura, endpoints publicados, stack, modelo de datos, seguridad, ofuscación, auditoría y Scrum.
   - Fuente principal para endpoints, DTOs, códigos de error, roles y reglas de seguridad.

2. `docs/prompts/prompt_inicial.md` (este archivo)
   - Idea general del proyecto, requisitos funcionales, reglas para la IA y directrices por capa.

3. `docs/prompts/agente-frontend.md`
   - Reglas obligatorias para construir el frontend: estructura de directorios, vistas por orientación, componentes, i18n, assets, testing, a11y, performance, seguridad, solicitud de archivos y DoD por PR.

4. `docs/prompts/agente-backend.md` y `docs/prompts/agente-database.md`
   - Reglas hermanas para el backend y la base de datos. Mismo patrón (secciones 0-22), mismos principios de fuentes de verdad y solicitud de archivos.

**Jerarquía en caso de conflicto**: `README.md` → `prompt_inicial.md` → `agente-frontend.md` → documentos satélite.

Si la IA detecta una contradicción, debe señalarla, proponer la corrección y actualizar el documento correspondiente en el mismo PR.

**Regla de solicitud de archivos**: si para avanzar la IA necesita contexto que no está en estos documentos, DEBE solicitar explícitamente los archivos concretos (ruta + motivo) antes de continuar. Nunca inventar endpoints, DTOs, campos, códigos de error ni estructuras.

---

# 🧠 CONDICIONES DE DESARROLLO PARA LA IA (actualizadas al 2026-09-20)

## 📁 Estructura de ramas en Git

- **`lastest`** (principal): rama protegida en GitHub. Solo acepta merges mediante Pull Requests. **No se permite push directo** (aunque el administrador puede ver un aviso, se recomienda no hacerlo). Esta rama contiene la versión estable del proyecto.
- **`developer`**: rama de desarrollo activo. Aquí se integran las features y se hacen pruebas. **No está protegida** y permite push directo.
- **Ramas `feature/*`**: se crean desde `developer` para cada funcionalidad. Se fusionan a `developer` mediante PRs, y luego `developer` se fusiona a `lastest` mediante PR.

> **Nota:** Los cambios a `lastest` siempre deben venir desde `developer` a través de un Pull Request con revisión.

## 💻 Entorno de desarrollo local

- **Ruta absoluta del proyecto**: `/prog/datos/investment-tracker` (no usar variables de entorno en comandos).
- **Sistema operativo**: Pop!\_OS 22.04.
- **IDE**: Visual Studio Code.
- **Comandos**: siempre usar rutas completas (ejemplo: `cd /prog/datos/investment-tracker/backend`).

## 🧩 Stack tecnológico (versiones actuales)

- **Backend**: Java LTS 21 (Spring Boot 3.3.0)
- **Base de datos**: PostgreSQL 16
- **Frontend**: React 18+ con CSS moderno
- **Servidor Web**: Tomcat 10 (embebido en Spring Boot)
- **Seguridad**: HTTPS + JWT + Refresh Token (sesión deslizante de 1 hora)
- **Contenedores**: Docker + Docker Compose
- **Gestión de DB**: pgAdmin 4 (latest)
- **Control de versiones**: Git / GitHub
- **Pruebas**: JUnit 5 + Spring Boot Test (89 pruebas automatizadas)
- **Auditoría**: PostgreSQL trigger + wrapper `DataSource` (`AuditUserAwareDataSource`)
- **Ofuscación de datos**: `@Masked` + `MaskedSerializer` (Jackson) + `MaskingFilter`, controlado por `MaskingContext` (ThreadLocal)
- **Filtro de logs sensibles**: `LogSanitizer` + `SensitiveFieldsProperties` (lista editable vía `application.yml`)
- **Validación**: Jakarta Bean Validation (`@Valid`) + validaciones de servicio. Los errores de `@Valid` se reportan como `SYS-03` (500) sin detalle.
- **Perfil de usuario**: `/api/auth/get-my-profile` (GET) y `/api/auth/update-my-profile` (POST).

---

## 🗄️ Usuarios de base de datos

El sistema separa las responsabilidades en **dos roles de PostgreSQL**:

| Rol                  | Uso                                                        | Privilegios                                                                                                        | Contraseña                                                   |
| -------------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| **`investor`**       | Administrador / operación manual (pgAdmin, scripts, DBA)   | Superusuario funcional sobre `investment_tracker`. Acceso total incluyendo `auditoria_usuarios`.                   | Configurada en `docker-compose.yml` (no versionada en claro) |
| **`investment_app`** | Usuario exclusivo del backend (JDBC vía `application.yml`) | `SELECT, INSERT, UPDATE, DELETE` sobre tablas de negocio. **Sin acceso** a `auditoria_usuarios` ni a su secuencia. | Encriptada AES-256-GCM en `application.yml`                  |

**Reglas**:

1. El backend **nunca** usa `investor` como usuario JDBC. Siempre `investment_app`.
2. `investment_app` **no puede** leer, modificar ni borrar la auditoría. Ni siquiera `TRUNCATE`. Se lo revoca explícitamente en `150_permisos/00_001_000_01_cr_app_db_user.sql`.
3. `investor` se usa solo para tareas administrativas (aplicar migraciones, backups, consultas de auditoría, pgAdmin).
4. El trigger de auditoría corre con `SECURITY DEFINER` (owner `postgres`), de modo que la escritura en `auditoria_usuarios` no requiere privilegios de `investment_app`.

---

## 🎭 Ofuscación de datos sensibles

Capa transversal del backend que enmascara campos sensibles **a la salida** (serialización JSON), evitando que viajen en claro por la red o aparezcan en logs. Los servicios y validaciones internas siguen operando con datos **reales**.

### Principios

1. La ofuscación ocurre **solo en serialización** (Jackson), nunca en el dominio.
2. Las validaciones internas (login, recovery, change-password) operan con datos **reales**.
3. Los endpoints en `MaskingFilter.OWN_DATA_PATHS` devuelven datos propios sin enmascarar.
4. El resto de endpoints enmascara por defecto.
5. Es **extensible**: agregar un tipo nuevo al enum `MaskType` + su `case` en `DataMasking`.

### Tipos soportados

| Tipo      | Input               | Output           |
| --------- | ------------------- | ---------------- |
| `EMAIL`   | `user@test.com`     | `u***@***.com`   |
| `CELULAR` | `3001234567`        | `***4567`        |
| `NOMBRE`  | `Juan Pérez García` | `J*** P*** G***` |

### Cómo agregar un campo sensible nuevo

1. Agregar la anotación `@Masked(MaskType.XXX)` al campo del DTO.
2. (Opcional) Agregar el nombre del campo a `security.sensitive-fields` en `application.yml` para evitar que aparezca en logs.
3. (Opcional) Si es un tipo nuevo: agregar al enum `MaskType` y su `case` en `DataMasking.mask`.

### Cómo marcar un endpoint como "propio" (sin ofuscar)

1. Agregar la ruta al `Set<String> OWN_DATA_PATHS` en `MaskingFilter`.
2. Documentar en el commit por qué el endpoint devuelve datos sin enmascarar.

### Estado actual

- `/api/auth/login` **enmascara** los campos `email`, `nombreCompleto`, `celular` (decisión temporal).
- `/api/auth/refresh-token` está configurado para devolver datos reales (en `OWN_DATA_PATHS`).
- Cuando se implemente `/api/auth/update-my-profile`, se decidirá si login vuelve a mostrar datos reales al dueño.

### Reglas de logs

- **Nunca** loggear los campos de `security.sensitive-fields` (configurable en `application.yml`).
- Usar `LogSanitizer.sanitize(fieldName, value)` antes de loggear cualquier dato potencialmente sensible.
- Campos configurados actualmente: `email`, `celular`, `nombre_completo`, `password`, `password_hash`, `passwordHash`, `token`, `refreshToken`, `actualPassword`, `nuevoPassword`, `repetirNuevoPassword`.

---

## 🕵️ Auditorías

Sección dedicada a la **bitácora de cambios** del sistema. Por ahora solo se implementa la auditoría de usuarios; la sección queda abierta para futuras auditorías (ej: transacciones, comisiones, plataformas).

### Auditoría de usuarios

- **Tabla**: `investment_tracker.auditoria_usuarios` (BIGSERIAL PK).
- **Trigger**: `trg_audit_usuarios` → función `fn_audit_usuarios` (`SECURITY DEFINER`, owner `postgres`).
- **Disparo**: `AFTER INSERT OR UPDATE OR DELETE FOR EACH ROW` sobre `usuarios`.
- **Mapeo de operación**:
  - `I` → INSERT en `usuarios`
  - `U` → UPDATE con cualquier campo de negocio (excepto `ultimo_login` aislado)
  - `L` → UPDATE donde el **único** campo de negocio modificado es `ultimo_login` (login)
  - `D` → DELETE en `usuarios`
- **Exclusión de columnas de sistema**: `updated_at` se ignora al calcular `campos_modificados` para que el login se registre como `L` (el `@PreUpdate` de JPA también toca `updated_at`).
- **Snapshots**: `datos_anteriores` y `datos_nuevos` en JSONB.
- **Campos de trazabilidad**:
  - `campos_modificados TEXT[]` — columnas de negocio que cambiaron en un UPDATE.
  - `usuario_bd VARCHAR(100)` — `SESSION_USER` de PostgreSQL (ej: `investment_app`).
  - `usuario_aplicacion VARCHAR(100)` — usuario autenticado vía JWT; `'desconocido'` si no hay auth.
  - `ip_cliente INET` — `inet_client_addr()`.
  - `fecha TIMESTAMPTZ DEFAULT NOW()`.
- **Propagación del usuario autenticado**:
  - `AuditUserAwareDataSource` envuelve el `DataSource` y ejecuta `set_config('app.audit_user', <username>, false)` en cada `getConnection()`, leyendo el username desde `SecurityContextHolder` (poblado por `JwtAuthFilter`).
  - `AuditContextService.setCurrentUser(username)` (con `@Transactional(propagation = MANDATORY)`) fuerza el username durante el login, antes de que exista JWT.
- **Retención**: por definir en una versión futura. Solo `investor`/`postgres` pueden limpiar la tabla.
- **Índices**: `usuario_id`, `fecha DESC`, `operacion`.

### Auditorías planificadas (roadmap)

- Auditoría de accesos fallidos (a nivel aplicación, tabla separada).
- Gerenciales, para deteccion de hacking.

---

## 🔐 Seguridad y autenticación

- **JWT** con firma HMAC-SHA384 (expiración 24h).
- **Refresh Token**: token aleatorio de 64 bytes, almacenado en memoria (`ConcurrentHashMap`) con TTL de 1 hora y sesión deslizante (se renueva con cada uso). Configurado en `application.yml` bajo `refresh-token`.
- **AES-256-GCM** para encriptación bidireccional de datos sensibles.
- **BCrypt** para hash de contraseñas.
- **Roles**: `ROLE_ADMIN`, `ROLE_USER`, `ROLE_PREMIUM`.
- **Control de intentos fallidos**: 3 intentos, bloqueo progresivo.
- **2FA SMTP** para recuperación de contraseña (token de 6 dígitos por correo, TTL 5 min).
- **Registro en dos pasos**: solicitud + confirmación por email (token de 6 dígitos, TTL 5 min).
- **Borrado de cuenta**: lógico (`activo=false`) para el propio usuario autenticado; borrado definitivo en cascada solo por ADMIN para pruebas (`/api/test/delete-user/{username}`).
- **Auditoría**: ver sección [🕵️ Auditorías](#-auditorías).
- **Ofuscación de datos sensibles**: capa transversal `MaskingFilter` + `@Masked` + `MaskedSerializer`. Los campos anotados (`email`, `nombreCompleto`, `celular`) se enmascaran a la salida. Extensible vía `MaskType`.
- **Filtro de logs**: `LogSanitizer` + `SensitiveFieldsProperties` (lista configurable en `application.yml → security.sensitive-fields`).

## 👤 Perfil de Usuario

Servicios para que el usuario autenticado consulte y modifique **su propio** perfil.

### Reglas de negocio

1. **Solo el propio usuario**: el `username` del request debe coincidir con el del JWT. También el `id` del request debe coincidir con el del usuario autenticado.
2. **Campos editables**: `email`, `nombreCompleto`, `paisId`, `celular`.
3. **Campos NO editables**: `username`, `password_hash`, `activo`, `roles`, `id`, `ultimo_login`.
4. **Todos los campos son obligatorios** (`@NotNull`/`@NotBlank` en `UpdateMyProfileRequest`).
5. **Unicidad case-insensitive**: se valida que `email` y `(pais_id, celular)` no estén en uso por OTRO usuario. La comparación es case-insensitive pero el valor **se guarda tal cual** lo envía el usuario (solo `trim`).
6. **País debe existir y estar activo**.
7. **Auditoría automática**: el trigger `trg_audit_usuarios` registra el UPDATE con `operacion='U'` y `usuario_aplicacion=<username del JWT>`.

### Respuesta de éxito (update)

```json
{
  "code": "UPT-0001",
  "message": "Actualización del usuario con éxito!!",
  "timestamp": "2026-09-19T16:24:32.252"
}
```

---

## Tabla de Endpoints publicados

| Endpoint                           | Método | Auth                   | Descripción                                                              |
| ---------------------------------- | ------ | ---------------------- | ------------------------------------------------------------------------ |
| `/api/auth/login`                  | POST   | No                     | Login - Retorna **solo** `token` y `refreshToken`                        |
| `/api/auth/refresh-token`          | POST   | No (usa refresh token) | Renueva el access token - Retorna `token` y `refreshToken`               |
| `/api/auth/logout`                 | POST   | JWT                    | Cerrar sesión - invalida el token y el refresh token                     |
| `/api/auth/restart-password`       | POST   | ADMIN                  | Restablecer contraseña de cualquier usuario                              |
| `/api/auth/change-my-pass`         | POST   | JWT                    | Cambiar contraseña propia con validación actual                          |
| `/api/auth/delete-account`         | POST   | JWT (propietario)      | Borrado lógico de la cuenta                                              |
| `/api/auth/get-my-profile`         | GET    | JWT                    | Obtener perfil del usuario autenticado                                   |
| `/api/auth/update-my-profile`      | POST   | JWT (propietario)      | Actualizar perfil propio: `email`, `nombreCompleto`, `paisId`, `celular` |
| `/api/auth/register/request`       | POST   | No                     | Solicitar registro - envía token 6 dígitos por email                     |
| `/api/auth/register/confirm`       | POST   | No                     | Confirmar registro con token                                             |
| `/api/auth/recovery/request`       | POST   | No                     | Solicitar recuperación - envía token 6 dígitos por email                 |
| `/api/auth/recovery/verify`        | POST   | No                     | Verificar token y cambiar contraseña                                     |
| `/api/encryption/encrypt`          | POST   | ADMIN                  | Encriptar texto con AES-GCM                                              |
| `/api/encryption/decrypt`          | POST   | ADMIN                  | Desencriptar texto con AES-GCM                                           |
| `/api/test/delete-user/{username}` | DELETE | ADMIN (solo pruebas)   | Borrado definitivo en cascada                                            |
| `/api/test/health`                 | GET    | No                     | Health check del servicio                                                |

## 🧪 Pruebas automatizadas

- **Total**: 89 pruebas (integración + unitarias).
- **Orden de ejecución**:
  1. `ChangeMyPasswordIntegrationTest` (11 pruebas)
  2. `AuthIntegrationTest` (31 pruebas)
  3. `EncryptionIntegrationTest` (7 pruebas)
  4. `RefreshTokenIntegrationTest` (7 pruebas)
  5. `RateLimitIntegrationTest` (4 pruebas)
  6. `PasswordRecoveryIntegrationTest` (4 pruebas)
  7. `RegisterIntegrationTest` (8 pruebas)
  8. `LoginServiceTest` (6 pruebas) — incluye verificación de `AuditContextService`
  9. `RegisterServiceTest` (11 pruebas)

- **Clase base**: `BaseIntegrationTest` proporciona helpers (`loginAndGetToken`, `toJson`, `printBanner`, `clearBlacklist`).
  - **Nota importante:** En `clearBlacklist()` (ejecutado en `@BeforeEach`) se limpian la blacklist de JWT y el rate limiter, pero **no** se limpian los refresh tokens. Esto es intencional para permitir que `RefreshTokenIntegrationTest` genere y reutilice tokens entre pruebas.

- **`ChangeMyPasswordIntegrationTest`**:
  - **No usa `@BeforeEach`** para obtener tokens (evita bloqueos al cambiar la contraseña).
  - Usa `@BeforeAll` para obtener tokens de `demo_user` y `admin` una sola vez.
  - **No usa `@AfterEach`**; la restauración de la contraseña se hace explícitamente en la última prueba (CMP-11) con token de admin.

- **`LoginServiceTest`**:
  - Verifica que `AuditContextService.setCurrentUser(username)` se invoca exactamente una vez en logins exitosos.
  - Verifica que **no** se invoca en logins fallidos (contraseña incorrecta, usuario bloqueado, usuario inexistente).

## 📂 Estructura de archivos relevante

- **Código fuente del backend**: `/prog/datos/investment-tracker/backend/src/main/java/com/investmenttracker/`
- **Pruebas del backend**: `/prog/datos/investment-tracker/backend/src/test/java/com/investmenttracker/`
- **Configuración**: `/prog/datos/investment-tracker/backend/src/main/resources/application.yml`
- **Archivo de entorno de pruebas**: `/prog/datos/investment-tracker/backend/src/test/resources/.unitTestEnv`
- **Docker**: `/prog/datos/investment-tracker/docker/docker-compose.yml`
- **Base de datos (SQL)**: `/prog/datos/investment-tracker/database/sql/`
- **Documentación**: `/prog/datos/investment-tracker/README.md`

---

## 🧹 Reglas generales para la IA

1. **Cada comando ejecutado debe tener path absoluto** y no usar variables de entorno (`/prog/datos/investment-tracker`).

2. **El archivo `README.md` contiene la información CRÍTICA y el estado general del proyecto**. Siempre consultarlo antes de responder.

3. **El código recomendado debe ajustarse al código ya implementado**. Si no se tiene contexto de un archivo, función o script, **pedirlo explícitamente** antes de dar una respuesta. Luego, entregar una respuesta basada en el código real de la aplicación.

4. **Todas las respuestas deben incluir, cuando sea aplicable, el uso de los helpers de `BaseIntegrationTest`** (como `printBanner`, `printStep`, `printSubStep`) para mantener consistencia en los logs de pruebas.

5. **Nunca usar `investor` como usuario JDBC del backend**. Siempre `investment_app`.

6. **Nunca otorgar permisos sobre `auditoria_usuarios` a `investment_app`**. Si se requiere consultar auditoría, hacerlo con `investor`/`postgres`.

7. **Toda planeación, avance y seguimiento del proyecto se gestiona en el tablero de GitHub Projects**: https://github.com/users/42mrnobody42-alt/projects/2. Antes de proponer nuevas funcionalidades o priorizar tareas, consultar el tablero para alinear con el estado actual del proyecto.

8. **Cada nueva feature debe corresponder a un issue del tablero**. Al iniciar una rama `feature/*`, referenciar el número de issue en el nombre de la rama o en el commit (ej: `feat(#12): actualizar perfil de usuario`).

9. **Ofuscación de datos sensibles**: cualquier campo nuevo que exponga `email`, `nombre_completo`, `celular`, montos, saldos o cualquier dato personal/financiero en un DTO de respuesta **debe anotarse con `@Masked(MaskType.XXX)`**.

10. **Nunca loggear campos sensibles**: usar `LogSanitizer.sanitize(fieldName, value)` antes de escribir cualquier dato que esté en `security.sensitive-fields`. Si el campo no está en la lista y debería estarlo, agregarlo primero a `application.yml`.

11. **La ofuscación ocurre solo a la salida**: nunca en el dominio ni en las validaciones internas. Los servicios usan datos reales; el JSON los enmascara.

12. **Si un endpoint debe devolver datos propios sin enmascarar**, agregarlo a `OWN_DATA_PATHS` en `MaskingFilter`. Documentar por qué.

13. **Manejo de errores de validación Jakarta (`@Valid`)**: se reportan con el código `SYS-03` (`INVALID_ARGUMENTS`) y HTTP 500. **Nunca** exponer al cliente el detalle de los campos que fallaron. El detalle se registra en logs con `log.warn`. Los errores de validación de negocio (en el servicio) siguen usando sus códigos específicos (`PWD-*`, `VAL-005`, etc.) con HTTP 400.

14. **Login minimalista**: `/api/auth/login` y `/api/auth/refresh-token` retornan **únicamente** `token` y `refreshToken`. No exponer `username`, `email`, `nombreCompleto`, `celular`, `pais`, `tokenType`, `expiresIn` ni `refreshTokenExpiresIn`. Los datos personales se consultan por separado con `/api/auth/get-my-profile`.

15. **Perfil propio**: los endpoints `/api/auth/get-my-profile` y `/api/auth/update-my-profile` solo operan sobre el usuario autenticado. El `username` e `id` del request deben coincidir con el JWT. Agregar `/api/auth/get-my-profile` a `OWN_DATA_PATHS` del `MaskingFilter` si devuelve datos reales.

16. **Email/nombreCompleto preservados**: al registrar o actualizar, guardar el email y `nombreCompleto` tal cual los envía el usuario (solo `trim`). Las comparaciones de unicidad son **case-insensitive**, pero el valor **almacenado** conserva el case original.

17. **Nunca iniciar trabajo sin haber movido el issue correspondiente a In progress en el tablero**. Antes de tocar código, verificar el estado con gh project item-list.

18. **Nunca commitear sin referenciar el issue con Closes** #N (cierra automáticamente) o Refs #N (solo referencia). **El commit debe tener formato\*** tipo(#N): descripción.

19. **Siempre comentar el SHA en el issue al cerrar una tarea.** Usar kanban-comment.sh o directamente gh issue comment con el formato establecido.

20. **Nunca mergear a lastest directamente.** Todo pasa por PR desde feature/\* hacia developer, y luego developer hacia lastest mediante PR revisado.

21. **Consultar docs/scrum/kanban/kanban-ids.env antes de ejecutar cualquier script que requiera IDs de issues**. Este archivo se regenera al crear cada capability.

22. **Mantener sincronizado docs/scrum/kanban/ con los issues de GitHub.** Cuando se cree una capability nueva, actualizar kanban-ids.env y agregar el .md correspondiente en capabilities/.

23. **Consultar `docs/agente-frontend.md` antes de cualquier tarea de frontend**. Ese documento define estructura de directorios, componentes obligatorios, i18n, assets, testing, a11y, performance, seguridad y DoD por PR. Ante conflicto, prevalece `README.md` → este archivo → `agente-frontend.md`.

24. **Nunca inventar contexto**. Si falta un endpoint, un DTO, un campo, un código de error, un rol, un diseño o una regla de negocio, **solicitar el archivo concreto** (ruta + motivo) antes de continuar. Formato sugerido:

    Para avanzar necesito los siguientes archivos:
    1. <ruta/archivo.ext> — <motivo breve>
    2. <ruta/archivo.ext> — <motivo breve>
       Con esos archivos continúo con: <entregable esperado>.

25. **Pedir solo lo necesario** para el siguiente paso, no todo el repositorio. Priorizar: `README.md`, `docs/prompts/prompt_inicial.md`, `docs/agente-frontend.md`, luego código real (servicios, DTOs, vistas existentes, tests, configuración).

26. **No avanzar con supuestos silenciosos**. Si se hace un supuesto por continuidad, declararlo explícitamente y marcarlo como pendiente de validación antes de generar código.

27. **Mantener sincronizados los documentos**. Si cambia una convención de frontend en `docs/agente-frontend.md`, actualizar el `README.md` (sección de estructura) y, si aplica, este archivo, en el mismo PR. Si cambia un endpoint en `README.md`, actualizar los servicios y tipos del frontend que lo consumen.

28. **Cuando el usuario pida "crear la vista X" sin contrato**, el agente debe solicitar antes: (a) endpoints exactos (ver `README.md` o código real), (b) DTO de request, (c) DTO de response, (d) roles con acceso, (e) reglas de negocio y validaciones.

## 📊 Gestión del Proyecto

### Tablero

- URL: https://github.com/users/42mrnobody42-alt/projects/2/views/1
- Columnas: Backlog · Ready · In progress · In review · Done
- Owner: 42mrnobody42-alt · Project number: 2
- Project ID (GraphQL): PVT_kwHOER7McM4BjVIW

> **Regla**: ninguna funcionalidad se considera "terminada" hasta que el issue asociado esté en `Done` en el tablero y la rama esté mergeada a `developer`.

### Estructura local

Toda la planificación vive versionada en `docs/scrum/kanban/`:

docs/scrum/kanban/
├── README.md # Guía local del kanban
├── kanban-ids.env # IDs vigentes de la CAP activa
├── .kanban-config.env # IDs del Project V2 (auto-generado)
├── capabilities/ # CAP-XX.md — plan maestro
├── features/ # FT-XXX.md
├── user-stories/ # US-XXX.md
├── tasks/ # TS-XXX.md
└── scripts/
├── create-cap01.sh # Crea CAP + FT + US + TS en GitHub
├── kanban-move.sh # Mueve issue entre estados del tablero
├── kanban-comment.sh # Comenta SHA + cambios en el issue
└── retry-links.sh # Re-vincula sub-issues si falla

### Jerarquía de issues

CAP-XX Capability → 1 sola por objetivo de negocio
└── FT-XXX Feature → agrupa user stories de un módulo
└── US-XXX User Story
└── TS-XXX Task (≤4h)

Cada nivel lleva su label (`capability`, `feature`, `user-story`, `task`)
y se vincula como **sub-issue** del nivel inmediatamente superior.

### Estados del tablero (Projects V2 #2)

| Nombre exacto | Alias en `kanban-move.sh` | Significado                      |
| ------------- | ------------------------- | -------------------------------- |
| `Backlog`     | `backlog`                 | Ideas / pendientes sin priorizar |
| `Ready`       | `ready`                   | Priorizado, listo para trabajar  |
| `In progress` | `progress`                | En desarrollo activo             |
| `In review`   | `review`                  | PR abierto / pendiente revisión  |
| `Done`        | `done`                    | Mergeado a `developer`           |

> ⚠️ **Atención**: los nombres reales en GitHub son `In progress` y
> `In review` (segunda palabra en **minúscula**). El script `kanban-move.sh`
> acepta alias case-insensitive.

### Flujo obligatorio de la IA por cada unidad de trabajo

**Antes de empezar cualquier CAP / FT / US / TS:**

**1. Consultar el estado actual del issue en el tablero**

```bash
gh project item-list 2 --owner 42mrnobody42-alt --format json --limit 500 \
  --jq ".items[] | select(.content.number == <N>) | \"#\(.content.number) → \(.status)\""
```

**2. Crear la rama desde developer con nomenclatura**

```bash
cd /prog/datos/investment-tracker
git checkout developer
git pull origin developer
git checkout -b feature/<ID>-<slug>
```

Ejemplos de nombres válidos:

- feature/CAP-01-frontend-base
- feature/FT-001-setup
- feature/US-003-i18n
- feature/TS-006-i18n-files

**3. Mover el issue y sus hijos directos a In progress**

```bash
cd /prog/datos/investment-tracker/docs/scrum/kanban
source kanban-ids.env

# Padre
./scripts/kanban-move.sh <N> progress

# Hijos directos (si aplica)
for child in <N1> <N2> <N3>; do
  ./scripts/kanban-move.sh "$child" progress
done
```

> Regla: nunca dejar tareas huérfanas en Backlog mientras se trabaja activamente en ellas.

Al terminar una TS / US / FT / CAP:

**4. Commit con referencia al issue (Closes #N o Refs #N)**

```bash
git add <archivos>
git commit -m "feat(#<N>): <descripción>

<cuerpo opcional>

Closes #<N>"
git push -u origin feature/<ID>-<slug>
```

**5. Comentar en el issue con SHA y lista de cambios**

```bash
./scripts/kanban-comment.sh <N> "$(git rev-parse --short HEAD)" \
  "<título del commit>" \
  "$(git show --stat --oneline HEAD | tail -n +2)"
```

El comentario debe incluir obligatoriamente:

- SHA del commit que entrega la solución.
- Lista de archivos modificados y su propósito.
- Notas de decisiones o deuda técnica si aplica.

**6. Mover el issue a In review**

```bash
./scripts/kanban-move.sh <N> review
```

**7. Abrir PR a developer con Closes #N**

```bash
gh pr create --base developer --head feature/<ID>-<slug> \
  --title "<título>" \
  --body "Closes #<N>

## Cambios
- ...

## Checklist
- [ ] Tests pasan
- [ ] Lint OK
- [ ] Documentación actualizada"
```

Al mergear a developer:

**8. Mover el issue a Done (GitHub lo hace automáticamente si el PR**
usa Closes #N; si no, forzar manualmente):

```bash
./scripts/kanban-move.sh <N> done
```

### Scripts disponibles

### Scripts disponibles

| Script              | Función                                 | Uso                                                |
| ------------------- | --------------------------------------- | -------------------------------------------------- |
| `create-cap01.sh`   | Crea toda la jerarquía CAP-01 en GitHub | `./scripts/create-cap01.sh`                        |
| `kanban-move.sh`    | Mueve un issue entre estados            | `./scripts/kanban-move.sh <N> progress`            |
| `kanban-comment.sh` | Comenta SHA + cambios en el issue       | `./scripts/kanban-comment.sh <N> <sha> "<titulo>"` |
| `retry-links.sh`    | Re-vincula sub-issues si el link falló  | `./scripts/retry-links.sh`                         |

---

## 🏛️ Directrices de desarrollo por capa

### Backend (Java / Spring Boot)

- **Arquitectura Hexagonal (Puertos y Adaptadores)**: Separar claramente las capas:
  - **Domain**: entidades, value objects, reglas de negocio, interfaces de puertos (repositorios, servicios externos).
  - **Application**: casos de uso, servicios que orquestan la lógica de negocio usando los puertos.
  - **Infrastructure**: implementaciones concretas de adaptadores (JPA, REST controllers, clientes HTTP, etc.).
- **Funciones con un solo propósito**: cada método debe hacer una única responsabilidad y estar bien nombrado.
- **Código limpio**: sin warnings de compilación ni de análisis estático (usar SonarLint o similares). Manejar excepciones adecuadamente, evitar código duplicado y mantener baja complejidad ciclomática.
- **Cuando una solicitud requiere campos obligatorios**: debe agregar las etiquetas @NotBlank desde el \*Request.java
- **Pruebas unitarias y de integración**: cubrir todas las capas. Usar mocks para dependencias externas en pruebas unitarias, y `@SpringBootTest` para integración. Las pruebas deben ser deterministas y rápidas.
- **Uso de DTOs**: para transferencia de datos entre capas, evitar exponer entidades directamente en la API.
- **Validaciones**: tanto a nivel de controlador (validación de entrada) como a nivel de dominio (invariantes).
- **Scripts de migración de base de datos**: deben ser **idempotentes** (es decir, se pueden ejecutar múltiples veces sin causar errores). Usar `CREATE IF NOT EXISTS`, `ALTER IF EXISTS` o bloques `DO $$ ... END $$` con condiciones para evitar fallos si el objeto ya existe.
- **Auditoría**: cuando se modifiquen datos sensibles, el usuario autenticado se propaga automáticamente vía `AuditUserAwareDataSource`. Si el flujo no tiene JWT (ej: login), invocar explícitamente `AuditContextService.setCurrentUser(username)`.
- **Ofuscación**: cualquier DTO de respuesta que exponga datos sensibles debe anotar el campo con `@Masked(MaskType.XXX)`. Agregar tipos nuevos a `MaskType` y a `DataMasking.mask` cuando se necesite. No ofuscar en el dominio; solo en serialización.
- **Logs**: usar `LogSanitizer` antes de loggear datos que estén en `security.sensitive-fields`.
- **Validación de campos**: usar `@NotBlank`/`@NotNull` en `*Request.java` para validación sintáctica. Los errores de `@Valid` se manejan en `GlobalExceptionHandler.handleValidationException()` y se reportan como `SYS-03` (500) sin detalle. Las validaciones de negocio van en el servicio y devuelven códigos específicos con 400.
- **Endpoints de "mi propio X"**: cuando un endpoint solo opera sobre el usuario autenticado (ej: `get-my-profile`, `update-my-profile`, `change-my-pass`), validar siempre que el `username`/`id` del request coincida con el JWT. Si no coincide → `AUTH-007` (403).
- **Preservación de datos de usuario**: no forzar `toLowerCase()` ni transformaciones sobre `email`/`nombreCompleto` al persistir. Solo `trim()`.

### Base de Datos (PostgreSQL / PL/pgSQL)

- **Modelo relacional normalizado**: al menos hasta 3FN, con claves primarias UUID y relaciones claras.
- **PL/pgSQL para lógica compleja**: usar funciones y procedimientos almacenados solo cuando la lógica requiera acceso eficiente a los datos o cuando se necesite atomicidad transaccional. Documentar cada función con su propósito y parámetros.
- **Migraciones controladas**: todos los cambios de esquema deben reflejarse en scripts SQL versionados tal como lo indica los subtitulos "Estándar de organización y nomenclatura" y "Scripts de construcción".
- **Índices**: crear índices apropiados para las columnas más consultadas (especialmente claves foráneas y campos de búsqueda).
- **Transacciones**: usar transacciones explícitas cuando se modifiquen múltiples tablas o se ejecuten funciones con efectos secundarios.
- **Manejo de errores**: en PL/pgSQL, usar `RAISE` con códigos de error claros y manejar excepciones cuando sea necesario.
- **Roles de BD**: separar estrictamente `investor` (admin) de `investment_app` (aplicación). Aplicar `REVOKE` explícito sobre las tablas de auditoría.

#### Estándar de organización y nomenclatura

Se adoptará la siguiente estructura estandarizada para todos los scripts de base de datos, siguiendo las mejores prácticas de la industria:

- **Directorio raíz**: `database/`
  - **`install/`**: contiene la instalación completa (esquema, datos básicos, funciones, etc.) para un despliegue desde cero.
  - **`updates/`**: contiene los scripts de actualización incremental (migraciones) que se aplican sobre una instalación existente.

Dentro de **ambos directorios** (`install/` y `updates/`), se organizarán subdirectorios numerados de 10 en 10 para agrupar componentes por orden de aplicación:

- 10_esquemas/ # Creación de esquemas (CREATE SCHEMA)
- 20_extensiones/ # Extensiones de PostgreSQL (uuid-ossp, pgcrypto, etc.)
- 30_tipos/ # Tipos personalizados (ENUM, DOMAIN, COMPOSITE)
- 40_tablas/ # Definición de tablas (CREATE TABLE)
- 50_alter_tablas/ # Modificaciones a tablas (ALTER TABLE ADD/DROP COLUMN, ALTER COLUMN TYPE, etc.)
- 60_restricciones/ # Restricciones de integridad (PK, FK, UQ, CK) - ALTER TABLE ADD CONSTRAINT
- 70_indices/ # Índices (CREATE INDEX) - para rendimiento
- 80_vistas/ # Vistas y vistas materializadas (CREATE VIEW, CREATE MATERIALIZED VIEW)
- 90_funciones/ # Funciones (CREATE FUNCTION)
- 100_procedimientos/ # Procedimientos almacenados (CREATE PROCEDURE)
- 110_disparadores/ # Triggers (CREATE TRIGGER) y sus funciones asociadas
- 120_eventos/ # Eventos programados (pg_cron, etc.) o notificaciones
- 130_secuencias/ # Secuencias (CREATE SEQUENCE) si no se definieron en tablas
- 140_datos_basicos/ # Datos de catálogo, maestros, datos de prueba esenciales (INSERT)
- 150_permisos/ # Asignación de permisos (GRANT, REVOKE)
- 160_comentarios/ # Comentarios de documentación (COMMENT ON) - opcional

Cada archivo SQL dentro de estos directorios seguirá la nomenclatura:
Version_Release_Hotfix_Orden_Nombre.sql

Donde:

- **Version**: número de versión principal (2 dígitos, ej. `00`).
- **Release**: número de release (3 dígitos, ej. `001`).
- **Hotfix**: número de hotfix (3 dígitos, ej. `000`).
- **Orden**: número de orden del script dentro del directorio (2 dígitos, ej. `01`).
- **Nombre**: nombre descriptivo del script, que **debe comenzar con un prefijo de operación** para identificar claramente el propósito del script:
  - `cr_` → Crear (CREATE)
  - `upd_` → Actualizar (ALTER, UPDATE, etc.)
  - `del_` → Eliminar (DROP, DELETE, etc.)
  - `read_` → Leer/Consultar (SELECT, funciones de consulta, etc.)

Ejemplo de nombres válidos:

- `cr_usuarios`
- `upd_campo_edad`
- `del_tabla_temporal`
- `read_consultar_saldos`

> **Ejemplo completo**: `00_001_000_01_cr_usuarios.sql`

Los NUMEROS OFICIALES de **Version**, **Release** y **Hotfix** **se obtienen del archivo `README.md`** (sección "# PROMPT INICIAL - Sistema de Gestión de Inversiones"). Por ejemplo, para la versión `v0.1.0`, se traduce a:

- Version = `00`
- Release = `001`
- Hotfix = `000`

#### Scripts de construcción (build)

Para facilitar el despliegue y la migración, se generarán dos scripts agregados a partir de los archivos individuales:

1. **`CreateInstallSqlInvestmentTracker.sh`** (genera `database/sql/aplica.sql`):
   - Recorre **todos** los directorios de `database/sql/install/` en orden numérico (`10_esquemas/`, `30_tipos/`, ..., `160_comentarios/`).
   - Dentro de cada directorio, procesa los archivos en orden alfabético (que coincide con el orden numérico).
   - Genera un archivo `aplica.sql` que **NO contiene el código SQL inline**, sino **referencias `\ir`** a cada archivo individual, con rutas relativas al directorio `database/sql/`.
   - Ejemplo de contenido generado:
     ```sql
     \ir install/10_esquemas/00_001_000_01_cr_schema.sql
     \ir install/40_tablas/00_001_000_01_cr_roles.sql
     \ir install/40_tablas/00_001_000_02_cr_usuarios.sql
     ```

2. **`aplica_V_R_H.sql`** (migración por versión):
   - Contiene **solo los scripts del directorio `updates/`** que corresponden a una versión, release y hotfix específicos.
   - Ejemplo: para la versión `v0.1.0`, se generaría `aplica_00_001_000.sql` con todos los scripts de `updates/` que tengan esa misma versión, release y hotfix (`00_001_000_*`).
   - Este script se utiliza para actualizar una instalación existente a una versión específica.
   - Se genera de manera similar, filtrando por el prefijo de versión correspondiente.

**⚠️ Reglas de generación**:

- El orden dentro de cada directorio se define por el número `Version`_`Release`_`Hotfix`_`Orden` del archivo (inicia con 00_000_000_01_\*).
- Se respeta el orden de los directorios (10, 20, 30, ...).
- Cada script agregado debe incluir al inicio un comentario breve con la descripción, la fecha de generación, autor y la versión que contiene.
- Al agregar nuevos scripts en cualquier directorio (especialmente en `40_tablas/` y `140_datos_basicos/`), se debe respetar el orden numérico existente. Esto significa que se debe asignar el siguiente número de orden disponible (por ejemplo, si el último archivo en `40_tablas/` es `09_cr_calculos_hist.sql`, el nuevo archivo debería ser `10_cr_nueva_tabla.sql`). Este orden garantiza que los scripts se ejecuten en la secuencia correcta durante la instalación, respetando las dependencias entre tablas y datos.

#### Directrices de implementación

- **Scripts idempotentes**: todos los scripts deben poder ejecutarse múltiples veces sin generar errores. Usar `CREATE IF NOT EXISTS`, `ALTER IF EXISTS`, `DROP ... IF EXISTS` y bloques `DO $$ ... END $$` con condiciones para verificar existencia previa.
- **Transacciones explícitas**: envolver cada script en una transacción (`BEGIN; ... COMMIT;`) para garantizar atomicidad, especialmente en actualizaciones.
- **Manejo de errores**: en PL/pgSQL, usar `RAISE` con códigos de error claros y manejar excepciones cuando sea necesario.
- **Índices y rendimiento**: crear índices apropiados para las columnas más consultadas (especialmente claves foráneas y campos de búsqueda). Documentarlos en el script correspondiente.
- **Migraciones controladas**: todos los cambios de esquema deben reflejarse en scripts SQL versionados. No modificar scripts ya desplegados; en su lugar, crear un nuevo script incremental en `updates/`.
- **Pruebas**: cada script debe probarse en un entorno de pruebas antes de aplicarse a producción.
- **Permisos**: cualquier tabla nueva debe evaluar si `investment_app` requiere acceso. Las tablas de auditoría se **revocan** explícitamente.

### Frontend (React + CSS)

> Este proyecto sigue las reglas de `docs/prompts/agente-frontend.md`. Antes de escribir código, consultar también `README.md` (endpoints, DTOs, roles, códigos de error, versión vigente) y la sección de requisitos funcionales de este archivo.

- **Fuentes de verdad**: `README.md`, `docs/prompts/prompt_inicial.md` y `docs/prompts/agente-frontend.md`. No inventar endpoints, DTOs, códigos de error ni roles.
- **Componentes funcionales y hooks**: usar componentes funcionales con React Hooks. Evitar clases.
- **Separación por orientación**: las vistas horizontales (PC, Smart TV, tablet apaisada) y verticales (móvil, tablet retrato) viven en directorios independientes (`frontend/src/views/horizontal` y `frontend/src/views/vertical`). No se importan entre sí; la lógica común se extrae a `shared/`.
- **Layout interno obligatorio**: toda vista autenticada usa `AppShell` (TopBar + Sidebar plegable + Workspace) definido en `docs/prompts/agente-frontend.md` sección 3.2.
- **Separación de responsabilidades**:
  - Presentación: componentes UI puros que reciben props y renderizan.
  - Contenedores: componentes con estado y lógica de negocio (o hooks personalizados).
  - Servicios: módulos que encapsulan las llamadas a la API (`frontend/src/shared/services/*`), alineados con los endpoints publicados en `README.md`.
- **Estilos modernos**: CSS Modules + CSS Custom Properties + Container Queries. Tokens centralizados en `frontend/src/styles/tokens.css`. Prohibido hardcodear colores o espaciados.
- **i18n obligatorio**: `i18next` + `react-i18next`. Estructura `frontend/src/i18n/<locale>/<componente>/*.json`. Idiomas: `es` (fallback) y `en`. Cero textos hardcodeados en JSX.
- **Assets editables en runtime**: logos, imágenes corporativas y fuentes viven en `frontend/public/assets/` y se resuelven vía `useAsset()` leyendo `manifest.json`. Nunca importar estos assets desde `src/` con el bundler.
- **Storybook (History Book)**: obligatorio en `frontend/.storybook/`. Cada componente atómico/molecular/organismo tiene su `.stories.tsx` con Default, Variants, States, Responsive y DarkMode.
- **Manejo de estado**: estado local con hooks; estado global UI con Zustand; estado de servidor con TanStack Query. No duplicar estado de servidor en el store global.
- **Cliente HTTP único** en `frontend/src/shared/utils/http.ts` con interceptores JWT y refresh automático. Mapear códigos de error del backend a claves i18n en `shared/constants/httpStatus.ts`.
- **Pruebas**: unitarias (Vitest + Testing Library) por componente, integración por flujo (login → home → consulta) y E2E (Playwright) en 5 configuraciones (mobile-chrome, mobile-safari, tablet, desktop, tv). Auditoría a11y con `@axe-core/playwright`.
- **Rendimiento**: code splitting por ruta, lazy load de vistas pesadas, virtualización de listas > 100 filas, memoización selectiva justificada.
- **Seguridad**: nada de secretos en el bundle; solo variables con prefijo `VITE_`. Sanitización con DOMPurify. CSP estricta en `index.html` y en `docker/nginx/default.conf`. No loggear datos sensibles.
- **Accesibilidad**: WCAG 2.2 AA mínimo. Foco visible, navegación por teclado, `aria-live` en toasts y validaciones, `prefers-reduced-motion`.
- **Trazabilidad con el tablero**: cada vista o componente nace de un issue del tablero. Commits con formato `tipo(#N): descripción` y `Closes #N` o `Refs #N`. Ver README.md sección 106.
- **Definición de "Done" por PR**: la de `docs/prompts/agente-frontend.md` sección 18. Incluye i18n completo, stories, tests unitarios + integración + E2E, a11y, Lighthouse >= 90, assets mutables, documentación y referencia al issue.
- **Solicitud de archivos**: si falta contexto, ver sección "🧹 Reglas generales para la IA" y `docs/prompts/agente-frontend.md` sección 21.

---

# 🎯 Requisitos funcionales de la aplicación

1. Tener seguridad HTTPS y manejo de tokens JWT para la comunicación.
2. Crear usuarios con roles.
3. El cliente puede registrar todas sus inversiones en diferentes plataformas, con costos de comisión variables en el tiempo.
4. Registrar compras y ventas de acciones (cantidad, precio unitario, total, comisión, total movimiento).
5. Visualizar el total de movimientos y el resultado (positivo o negativo) de las inversiones.
6. Función de cálculo para determinar el precio mínimo de venta y la cantidad óptima para obtener una ganancia deseada, basado en los registros del cliente.
7. **Auditoría de cambios en usuarios** (INSERT/UPDATE/DELETE/Login) con snapshots y trazabilidad del usuario autenticado.
8. **Separación de credenciales de BD**: `investor` (admin) e `investment_app` (aplicación) con permisos diferenciados.

---

\*Fecha de actualización del prompt:** 2026-09-20  
**Versión del proyecto:** v0.1.3 (Perfil de usuario + `SYS-03` + login minimalista)  
**Próximo cambio planificado:\*\*

- Implementar frontend para website para pc, celular, tablet que sea auto configurable con el ancho de la pantalla, y si es de celular se hara una configuración especial por su manejo vertical, en vez del horizontal del pc, tv o tablet.
- Se deben implementar con traducción internacional i18n para ingles y español.
- Empezaremos creando los componentes (botones, pop-up info/warning/error, tablas, espacio de graficos con amplicación de pantalla, etc), crearemos vista (login, logut, home, consulta de datos, edición de datos) las vistas internas deben mantener un esquema dividido en 3 partes una barra superior informativa, barra lateral izquierda de procesos plegables, espacio de trabajo debajo de la barra superior y la lado derecho de la barra de procesos.
- PASAR POR LA IA PARA que analise y me pregunte para crear un RPA (solicitud de requisitos) del frontend que llevamos (manejo de usuarios), pero con proyección para lo que vamos a necesitar del proyecto para centralizar sus inversiones y obtener información de valor que le permita aprovechar oporunidades de compra y venta de acciones del interes del usuario, apartir de un analisis tecnico o social (elección del usuario)

```

```
