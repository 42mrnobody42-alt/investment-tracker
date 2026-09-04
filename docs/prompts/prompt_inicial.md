# Quiero crear una aplicación web que tenga los siguientes componentes:

Usar contenedores docker para los servicios postgresql para la DB, tomcat para el servicio web.
Los lenguajes de programación que vamos a usar es pl/sql, java para la logica ultima version LTS.
Para el frontend quiero usar react css para que se vea lo mas moderno y potente.
Tengo un servidor en pop os 22.04 y tengo instalado visual estudio code, necesito una guia para programar y probar en local desde mi servidor.
El versionamiento de todos los archivos seran llevados en un nuevo proyecto de git github separados por carpetas para Docker, DB, back y front.
Quiero que crees un paso a paso del procedimiento de toda la programación con diagramas, modelo MER y documentos.
Quiero que guardes este promp en un directorio de promps para el proyecto en formato MD

---

# 🧠 CONDICIONES DE DESARROLLO PARA LA IA (actualizadas al 2026-08-30)

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
- **Pruebas**: JUnit 5 + Spring Boot Test (70 pruebas automatizadas)

## 🔐 Seguridad y autenticación

- **JWT** con firma HMAC-SHA384 (expiración 24h).
- **Refresh Token**: token aleatorio de 64 bytes, almacenado en memoria (`ConcurrentHashMap`) con TTL de 1 hora y sesión deslizante (se renueva con cada uso). Configurado en `application.yml` bajo `refresh-token`.
- **AES-256-GCM** para encriptación bidireccional de datos sensibles.
- **BCrypt** para hash de contraseñas.
- **Roles**: `ROLE_ADMIN`, `ROLE_USER`, `ROLE_PREMIUM`.
- **Control de intentos fallidos**: 3 intentos, bloqueo progresivo.
- **2FA SMTP** para recuperación de contraseña (token de 6 dígitos por correo, TTL 5 min).

## 📡 Endpoints publicados (API REST)

| Endpoint                     | Método | Auth                   | Descripción                                              |
| ---------------------------- | ------ | ---------------------- | -------------------------------------------------------- |
| `/api/auth/login`            | POST   | No                     | Login - Retorna JWT + Refresh Token                      |
| `/api/auth/restart-password` | POST   | ADMIN                  | Restablecer contraseña de cualquier usuario              |
| `/api/auth/refresh-token`    | POST   | No (usa refresh token) | Renueva el access token usando un refresh token válido   |
| `/api/test/health`           | GET    | No                     | Health check del servicio                                |
| `/api/encryption/encrypt`    | POST   | ADMIN                  | Encriptar texto con AES-GCM                              |
| `/api/encryption/decrypt`    | POST   | ADMIN                  | Desencriptar texto con AES-GCM                           |
| `/api/auth/logout`           | POST   | JWT                    | Cerrar sesión - invalida el token y el refresh token     |
| `/api/auth/recovery/request` | POST   | No                     | Solicitar recuperación - envía token 6 dígitos por email |
| `/api/auth/recovery/verify`  | POST   | No                     | Verificar token y cambiar contraseña                     |
| `/api/auth/change-my-pass`   | POST   | JWT                    | Cambiar contraseña propia con validación actual          |

## 🧪 Pruebas automatizadas

- **Total**: 70 pruebas (integración + unitarias).
- **Orden de ejecución** (según lo observado en el entorno local):
  1. `ChangeMyPasswordIntegrationTest` (11 pruebas)
  2. `AuthIntegrationTest` (31 pruebas)
  3. `EncryptionIntegrationTest` (7 pruebas)
  4. `RefreshTokenIntegrationTest` (7 pruebas)
  5. `RateLimitIntegrationTest` (4 pruebas)
  6. `PasswordRecoveryIntegrationTest` (4 pruebas)
  7. `LoginServiceTest` (6 pruebas)

- **Clase base**: `BaseIntegrationTest` proporciona helpers (`loginAndGetToken`, `toJson`, `printBanner`, `clearBlacklist`).
  - **Nota importante:** En `clearBlacklist()` (ejecutado en `@BeforeEach`) se limpian la blacklist de JWT y el rate limiter, pero **no** se limpian los refresh tokens. Esto es intencional para permitir que `RefreshTokenIntegrationTest` genere y reutilice tokens entre pruebas.

- **`ChangeMyPasswordIntegrationTest`**:
  - **No usa `@BeforeEach`** para obtener tokens (evita bloqueos al cambiar la contraseña).
  - Usa `@BeforeAll` para obtener tokens de `demo_user` y `admin` una sola vez.
  - **No usa `@AfterEach`**; la restauración de la contraseña se hace explícitamente en la última prueba (CMP-11) con token de admin.

## 📂 Estructura de archivos relevante

- **Código fuente del backend**: `/prog/datos/investment-tracker/backend/src/main/java/com/investmenttracker/`
- **Pruebas del backend**: `/prog/datos/investment-tracker/backend/src/test/java/com/investmenttracker/`
- **Configuración**: `/prog/datos/investment-tracker/backend/src/main/resources/application.yml`
- **Archivo de entorno de pruebas**: `/prog/datos/investment-tracker/backend/src/test/resources/.unitTestEnv`
- **Docker**: `/prog/datos/investment-tracker/docker/docker-compose.yml`
- **Base de datos (SQL)**: `/prog/datos/investment-tracker/database/sql/`
- **Documentación**: `/prog/datos/investment-tracker/README.md`

## 🧹 Reglas generales para la IA

1. **Cada comando ejecutado debe tener path absoluto** y no usar variables de entorno (`/prog/datos/investment-tracker`).
2. **El archivo `README.md` contiene la información CRÍTICA y el estado general del proyecto**. Siempre consultarlo antes de responder.
3. **El código recomendado debe ajustarse al código ya implementado**. Si no se tiene contexto de un archivo, función o script, **pedirlo explícitamente** antes de dar una respuesta. Luego, entregar una respuesta basada en el código real de la aplicación.
4. **Todas las respuestas deben incluir, cuando sea aplicable, el uso de los helpers de `BaseIntegrationTest`** (como `printBanner`, `printStep`, `printSubStep`) para mantener consistencia en los logs de pruebas.

---

## 🏛️ Directrices de desarrollo por capa

### Backend (Java / Spring Boot)

- **Arquitectura Hexagonal (Puertos y Adaptadores)**: Separar claramente las capas:
  - **Domain**: entidades, value objects, reglas de negocio, interfaces de puertos (repositorios, servicios externos).
  - **Application**: casos de uso, servicios que orquestan la lógica de negocio usando los puertos.
  - **Infrastructure**: implementaciones concretas de adaptadores (JPA, REST controllers, clientes HTTP, etc.).
- **Funciones con un solo propósito**: cada método debe hacer una única cosa y estar bien nombrado.
- **Código limpio**: sin warnings de compilación ni de análisis estático (usar SonarLint o similares). Manejar excepciones adecuadamente, evitar código duplicado y mantener baja complejidad ciclomática.
- **Pruebas unitarias y de integración**: cubrir todas las capas. Usar mocks para dependencias externas en pruebas unitarias, y `@SpringBootTest` para integración. Las pruebas deben ser deterministas y rápidas.
- **Uso de DTOs**: para transferencia de datos entre capas, evitar exponer entidades directamente en la API.
- **Validaciones**: tanto a nivel de controlador (validación de entrada) como a nivel de dominio (invariantes).
- **Scripts de migración de base de datos**: deben ser **idempotentes** (es decir, se pueden ejecutar múltiples veces sin causar errores). Usar `CREATE IF NOT EXISTS`, `ALTER IF EXISTS` o bloques `DO $$ ... END $$` con condiciones para evitar fallos si el objeto ya existe.

### Base de Datos (PostgreSQL / PL/pgSQL)

- **Modelo relacional normalizado**: al menos hasta 3FN, con claves primarias UUID y relaciones claras.
- **PL/pgSQL para lógica compleja**: usar funciones y procedimientos almacenados solo cuando la lógica requiera acceso eficiente a los datos o cuando se necesite atomicidad transaccional. Documentar cada función con su propósito y parámetros.
- **Migraciones controladas**: todos los cambios de esquema deben reflejarse en scripts SQL versionados (por ejemplo, `01_schema.sql`, `02_functions.sql`, `03_seed.sql`).
- **Índices**: crear índices apropiados para las columnas más consultadas (especialmente claves foráneas y campos de búsqueda).
- **Transacciones**: usar transacciones explícitas cuando se modifiquen múltiples tablas o se ejecuten funciones con efectos secundarios.
- **Manejo de errores**: en PL/pgSQL, usar `RAISE` con códigos de error claros y manejar excepciones cuando sea necesario.

#### Estándar de organización y nomenclatura (próximo cambio planificado)

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

Los números de **Version**, **Release** y **Hotfix** se obtienen del archivo `README.md` (sección "Historial de Versiones"). Por ejemplo, para la versión `v0.1.0`, se traduce a:

- Version = `00`
- Release = `001`
- Hotfix = `000`

#### Scripts de construcción (build)

Para facilitar el despliegue y la migración, se generarán dos scripts agregados a partir de los archivos individuales:

1. **`aplica.sql`** (instalación completa):
   - Contiene **todos** los scripts de la carpeta `install/` combinados en orden:
     - Primero todos los archivos del directorio `10_esquemas/` (ordenados por `Version`_`Release`_`Hotfix`\_`Orden`).
     - Luego `20_extensiones/`, `30_tipos/`, ..., hasta `160_comentarios/`.
   - Este script se utiliza para una instalación completa desde cero.
   - Se genera automáticamente mediante un script o herramienta (ej. `build_aplicaSql.sh`) que recorre los directorios y concatena los archivos respetando el orden numérico.

2. **`aplica_V_R_H.sql`** (migración por versión):
   - Contiene **solo los scripts del directorio `updates/`** que corresponden a una versión, release y hotfix específicos.
   - Ejemplo: para la versión `v0.1.0`, se generaría `aplica_00_001_000.sql` con todos los scripts de `updates/` que tengan esa misma versión, release y hotfix (`00_001_000_*`).
   - Este script se utiliza para actualizar una instalación existente a una versión específica.
   - Se genera de manera similar, filtrando por el prefijo de versión correspondiente.

**Reglas de generación**:

- El orden dentro de cada directorio se define por el número `Version`_`Release`_`Hotfix`_`Orden` del archivo (inicia con 00_000_000_01_\*).
- Se respeta el orden de los directorios (10, 20, 30, ...).
- Cada script agregado debe incluir al inicio un comentario breve con la descripción, la fecha de generación, autor y la versión que contiene.

#### Directrices de implementación

- **Scripts idempotentes**: todos los scripts deben poder ejecutarse múltiples veces sin generar errores. Usar `CREATE IF NOT EXISTS`, `ALTER IF EXISTS`, `DROP ... IF EXISTS` y bloques `DO $$ ... END $$` con condiciones para verificar existencia previa.
- **Transacciones explícitas**: envolver cada script en una transacción (`BEGIN; ... COMMIT;`) para garantizar atomicidad, especialmente en actualizaciones.
- **Manejo de errores**: en PL/pgSQL, usar `RAISE` con códigos de error claros y manejar excepciones cuando sea necesario.
- **Índices y rendimiento**: crear índices apropiados para las columnas más consultadas (especialmente claves foráneas y campos de búsqueda). Documentarlos en el script correspondiente.
- **Migraciones controladas**: todos los cambios de esquema deben reflejarse en scripts SQL versionados. No modificar scripts ya desplegados; en su lugar, crear un nuevo script incremental en `updates/`.
- **Pruebas**: cada script debe probarse en un entorno de pruebas antes de aplicarse a producción.

### Frontend (React + CSS)

- **Componentes funcionales y hooks**: usar componentes funcionales con React Hooks (useState, useEffect, useContext, etc.). Evitar clases.
- **Separación de responsabilidades**:
  - **Presentación**: componentes UI puros (stateless) que reciben props y renderizan.
  - **Contenedores**: componentes con estado y lógica de negocio (o usar hooks personalizados para aislar lógica).
  - **Servicios**: módulos que encapsulan las llamadas a la API (Axios) y manejan la autenticación.
- **Estilos modernos**: usar CSS Modules, Styled Components o Tailwind CSS para mantener estilos encapsulados y escalables. Evitar CSS global siempre que sea posible.
- **Manejo de estado global**: si es necesario, usar Context API o Redux (preferir Context para casos simples).
- **Pruebas**: escribir pruebas unitarias para componentes (React Testing Library) y pruebas de integración para flujos completos.
- **Rendimiento**: usar `React.memo`, `useCallback` y `useMemo` cuando sea apropiado para evitar renders innecesarios.

---

# 🎯 Requisitos funcionales de la aplicación

1. Tener seguridad HTTPS y manejo de tokens JWT para la comunicación.
2. Crear usuarios con roles.
3. El cliente puede registrar todas sus inversiones en diferentes plataformas, con costos de comisión variables en el tiempo.
4. Registrar compras y ventas de acciones (cantidad, precio unitario, total, comisión, total movimiento).
5. Visualizar el total de movimientos y el resultado (positivo o negativo) de las inversiones.
6. Función de cálculo para determinar el precio mínimo de venta y la cantidad óptima para obtener una ganancia deseada, basado en los registros del cliente.

---

**Fecha de actualización del prompt:** 2026-08-30  
**Versión del proyecto:** v0.1.0 (Refresh Token implementado)  
**Próximo cambio planificado:** Estandarización de scripts de base de datos según el estándar industrial descrito.
