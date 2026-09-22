# agente-database.md

> Guía oficial de arquitectura y desarrollo de la base de datos.
> Versión: 1.0.0
> Stack base: PostgreSQL 16, PL/pgSQL, extensiones uuid-ossp y pgcrypto cuando aplique, usuario de aplicación investment_app, usuario administrador investor.
> Público objetivo: DBAs, desarrolladores backend senior y agentes automatizados de generación de SQL.
> Documento hermano del frontend, el backend y el README del proyecto. Ver sección 0 y 22.

---

## 0. Contexto obligatorio y fuentes de verdad

Antes de proponer, generar, modificar o revisar cualquier artefacto de base de datos, el agente (humano o IA) DEBE leer y respetar las siguientes fuentes, en este orden de autoridad:

1. `README.md` (raíz de `investment-tracker/`)
   - Estado general del proyecto, versión vigente (Version/Release/Hotfix), arquitectura, MER, relaciones clave, funciones PL/pgSQL disponibles, auditoría, datos de prueba, seguridad, ofuscación y Scrum.
   - Fuente principal para tablas, columnas, tipos, FKs, índices, funciones y permisos.

2. `docs/prompts/prompt_inicial.md`
   - Idea general del proyecto, requisitos funcionales, reglas para la IA, estándar de organización y nomenclatura SQL, scripts de construcción y directrices de implementación.

3. `docs/prompts/agente-backend.md`
   - Reglas del backend que condicionan el diseño de la BD: usuario `investment_app`, auditoría con `AuditUserAwareDataSource`, ofuscación, códigos de error, endpoints y DTOs.
   - El backend es consumidor de la BD: cualquier cambio de esquema que rompa un DTO o un repositorio debe coordinarse.

4. Este archivo (`docs/prompts/agente-database.md`)
   - Especifica cómo se construye la base de datos: estructura de directorios, nomenclatura, idempotencia, permisos, auditoría, migraciones y reglas para agentes IA.

5. `docs/prompts/agente-frontend.md`
   - Referencia de qué datos se muestran y cómo. Útil para saber qué columnas exponer sin romper contratos.

Reglas derivadas:

- Si el agente no tiene contexto suficiente (DDL actual de una tabla, versión vigente, permisos existentes, función PL/pgSQL), DEBE pedir el archivo concreto antes de generar SQL. Ver sección 21.
- Si detecta contradicción entre este archivo y `README.md`/`prompt_inicial.md`, DEBE señalarlo, proponer la corrección y actualizar el documento correspondiente en el mismo PR.
- Está prohibido inventar tablas, columnas, tipos, funciones o códigos. Se toman del README y del código real.

---

## 1. Principios rectores (Big-Tech Standard)

1. Modelo relacional normalizado hasta 3FN. Claves primarias UUID (por defecto). Relaciones claras y FKs explícitas.
2. Scripts idempotentes: `CREATE IF NOT EXISTS`, `ALTER IF EXISTS`, `DROP ... IF EXISTS`, bloques `DO $$ ... END $$` con verificación de existencia.
3. Versionado por archivo: cada script sigue la nomenclatura Version_Release_Hotfix_Orden_Prefijo_Nombre.sql.
4. Separación de responsabilidades por rol: `investor` (admin) e `investment_app` (aplicación). `REVOKE` explícito sobre tablas de auditoría.
5. Auditoría automática: trigger AFTER INSERT/UPDATE/DELETE sobre `usuarios`, con snapshots JSONB y usuario autenticado.
6. Lógica compleja en PL/pgSQL solo cuando aporte: acceso eficiente a datos, atomicidad transaccional o encapsulamiento de reglas.
7. Índices intencionados: en FKs, en columnas de búsqueda y en expresiones usadas con frecuencia (`lower(username)`, `lower(email)`, compuesto `(pais_id, celular)`).
8. Transacciones explícitas: `BEGIN; ... COMMIT;` en cada script, especialmente en migraciones.
9. Extensiones con propósito: `uuid-ossp` para `uuid_generate_v4()`, `pgcrypto` si se requiere. Cada extensión documentada.
10. Convención sobre configuración: nombres de tabla, columnas, índices, funciones y triggers siguen una única convención.
11. Fuentes de verdad primero: leer `README.md`, `prompt_inicial.md` y `agente-backend.md` antes de escribir SQL (ver sección 0).
12. Trazabilidad con el tablero: todo cambio nace de un issue del Project Board y se referencia en el commit/PR.

---

## 2. Estructura de directorios de la base de datos

Solo se listan las ramas relevantes a la base de datos. Las ramas frontend, backend y backups se documentan en sus respectivos agentes o en el README.

- **`database/`** - Base de datos
  - **`MER/`**
    - `diagram.md` - Diagrama entidad-relación
  - **`sql/`**
    - **`install/`** - Scripts de instalación completa (desde cero)
      - `10_esquemas/` - Creación del esquema y tabla `schema_version`
      - `20_extensiones/` - Extensiones PostgreSQL (uuid-ossp, pgcrypto)
      - `30_tipos/` - Tipos personalizados (ENUM, DOMAIN, COMPOSITE)
      - `40_tablas/` - Definición de tablas (una por archivo, en orden de dependencia)
      - `50_alter_tablas/` - Modificaciones a tablas
      - `60_restricciones/` - Restricciones de integridad (PK, FK, UQ, CK)
      - `70_indices/` - Índices de rendimiento y unicidad
      - `80_vistas/` - Vistas y vistas materializadas
      - `90_funciones/` - Funciones PL/pgSQL (una por archivo)
      - `100_procedimientos/` - Procedimientos almacenados
      - `110_disparadores/` - Triggers y sus funciones asociadas
      - `120_eventos/` - Eventos programados (pg_cron) o notificaciones
      - `130_secuencias/` - Secuencias (si no se definieron en tablas)
      - `140_datos_basicos/` - Datos iniciales (monedas, países, roles, usuarios de prueba)
      - `150_permisos/` - Creación de `investment_app` y GRANT/REVOKE
      - `160_comentarios/` - Comentarios de documentación (COMMENT ON)
    - **`updates/`** - Scripts de migración incremental (misma estructura numerada)
    - `aplica.sql` - Script consolidado de instalación (generado)
    - `aplica_00_001_000.sql` - Script de migración para versión 00_001_000 (generado)
  - `CreateInstallSqlInvestmentTracker.sh` - Generador de aplica.sql
  - `CreateRelease00_001_000SqlInvestmentTracker.sh` - Generador de aplica_V_R_H.sql

---

## 3. Nomenclatura de archivos SQL

Formato obligatorio:

Version_Release_Hotfix_Orden_Prefijo_Nombre.sql

Donde:

- **Version**: 2 dígitos (ej. `00`).
- **Release**: 3 dígitos (ej. `001`).
- **Hotfix**: 3 dígitos (ej. `000`).
- **Orden**: 2 dígitos (ej. `01`).
- **Prefijo**: uno de `cr_`, `upd_`, `del_`, `read_`.
  - `cr_` → CREATE
  - `upd_` → ALTER, UPDATE
  - `del_` → DROP, DELETE
  - `read_` → SELECT, funciones de consulta
- **Nombre**: descriptivo, snake_case.

Ejemplo completo: `00_001_000_01_cr_monedas.sql`.

Los números oficiales de Version/Release/Hotfix se obtienen del `README.md` (sección "PROMPT INICIAL - Sistema de Gestión de Inversiones"). Para la versión `v0.1.0`:

- Version = `00`
- Release = `001`
- Hotfix = `000`

---

## 4. Estándar de organización y nomenclatura

### 4.1 Directorios numerados

- `10_esquemas/` - CREATE SCHEMA y tabla `schema_version`.
- `20_extensiones/` - CREATE EXTENSION.
- `30_tipos/` - CREATE TYPE, CREATE DOMAIN.
- `40_tablas/` - CREATE TABLE (una por archivo, ordenadas por dependencia).
- `50_alter_tablas/` - ALTER TABLE ADD/DROP COLUMN, ALTER COLUMN TYPE.
- `60_restricciones/` - ALTER TABLE ADD CONSTRAINT.
- `70_indices/` - CREATE INDEX.
- `80_vistas/` - CREATE VIEW, CREATE MATERIALIZED VIEW.
- `90_funciones/` - CREATE FUNCTION.
- `100_procedimientos/` - CREATE PROCEDURE.
- `110_disparadores/` - CREATE TRIGGER + función asociada.
- `120_eventos/` - pg_cron, LISTEN/NOTIFY.
- `130_secuencias/` - CREATE SEQUENCE.
- `140_datos_basicos/` - INSERT de catálogos y datos de prueba esenciales.
- `150_permisos/` - CREATE ROLE + GRANT/REVOKE.
- `160_comentarios/` - COMMENT ON.

### 4.2 Orden de aplicación

- Directorios en orden numérico ascendente.
- Dentro de cada directorio, archivos en orden alfabético (que coincide con el orden numérico del prefijo).
- Respetar dependencias: tablas antes de FKs, funciones antes de triggers, roles antes de GRANT.

### 4.3 Al agregar nuevos scripts

- Asignar el siguiente número de orden disponible en el directorio correspondiente.
- Ejemplo: si el último archivo en `40_tablas/` es `09_cr_calculos_hist.sql`, el nuevo es `10_cr_nueva_tabla.sql`.
- Nunca reutilizar números de orden ya usados.
- Nunca modificar un script ya desplegado. Crear uno nuevo en `updates/`.

---

## 5. Scripts de construcción (build)

### 5.1 CreateInstallSqlInvestmentTracker.sh

- Recorre todos los directorios de `database/sql/install/` en orden numérico.
- Genera `database/sql/aplica.sql` con referencias `\ir` a cada archivo individual (no inline).
- Ejemplo de contenido generado:

  \ir install/10_esquemas/00_001_000_01_cr_schema.sql
  \ir install/40_tablas/00_001_000_01_cr_roles.sql
  \ir install/40_tablas/00_001_000_02_cr_usuarios.sql

### 5.2 CreateRelease00_001_000SqlInvestmentTracker.sh

- Genera `aplica_00_001_000.sql` con solo los scripts de `updates/` que correspondan a esa versión/release/hotfix.
- Se usa para actualizar instalaciones existentes.

### 5.3 Reglas de generación

- Incluir al inicio del script generado un comentario con descripción, fecha, autor y versión.
- Respetar orden numérico.
- No incluir código SQL inline; solo referencias `\ir`.
- Regenerar siempre que se agreguen scripts nuevos.

---

## 6. Idempotencia (obligatoria)

Todo script debe poder ejecutarse múltiples veces sin error.

### 6.1 Patrones

- `CREATE SCHEMA IF NOT EXISTS`.
- `CREATE EXTENSION IF NOT EXISTS`.
- `CREATE TABLE IF NOT EXISTS`.
- `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`.
- `DROP ... IF EXISTS`.
- `CREATE INDEX IF NOT EXISTS`.
- `CREATE OR REPLACE FUNCTION`.
- `CREATE OR REPLACE PROCEDURE`.
- `DROP TRIGGER IF EXISTS ...; CREATE TRIGGER ...`.
- Bloques `DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_... WHERE ...) THEN ... END IF; END $$;`.

### 6.2 Lo que nunca se hace

- `DROP TABLE` sin `IF EXISTS`.
- `CREATE TABLE` sin `IF NOT EXISTS`.
- Modificar un script ya aplicado en producción.
- Asumir que un objeto no existe.

### 6.3 Transacciones

- Cada script envuelto en `BEGIN; ... COMMIT;`.
- Si algo falla, `ROLLBACK` deja el esquema consistente.
- Evitar transacciones que toquen demasiadas tablas a la vez.

---

## 7. Modelo de datos

### 7.1 Esquema

- Nombre: `investment_tracker`.
- Todas las tablas viven en este esquema.
- `public` solo para extensiones y objetos del sistema.

### 7.2 Tablas actuales (ordenadas por dependencia)

1. `monedas` - 54 divisas internacionales con código ISO, nombre, símbolo y país.
2. `paises` - 55 países con código ISO, indicativo celular y FK a `monedas`.
3. `roles` - ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM.
4. `usuarios` - usuarios con username, email, password_hash, nombre_completo, celular, pais_id, activo, ultimo_login.
5. `usuario_roles` - relación N:M entre usuarios y roles.
6. `plataformas` - brokers/exchanges registrados por el usuario.
7. `comisiones` - comisiones variables por plataforma con vigencia temporal.
8. `transacciones` - compras y ventas de acciones.
9. `calculos_hist` - historial de cálculos de venta óptima.
10. `auditoria_usuarios` - bitácora de cambios en `usuarios`.

### 7.3 Columnas y tipos

- PKs: UUID con `uuid_generate_v4()`.
- FKs: UUID referenciando PKs.
- Timestamps: `TIMESTAMP` para `created_at`/`updated_at` en tablas de negocio. `TIMESTAMPTZ` en `auditoria_usuarios.fecha`.
- Booleanos: `BOOLEAN`.
- Decimales monetarios: `DECIMAL(18, 6)` o superior. Nunca `FLOAT`/`REAL`.
- Texto: `VARCHAR(n)` con n justificado. `TEXT` cuando no hay límite razonable.
- Snapshots: `JSONB` en `auditoria_usuarios`.
- Listas: `TEXT[]` en `campos_modificados`.

### 7.4 Restricciones

- PK en todas las tablas.
- FK con `ON DELETE` explícito (RESTRICT, CASCADE o SET NULL según la semántica).
- UNIQUE en columnas que lo requieran.
- CHECK cuando la columna tiene un dominio acotado.
- NOT NULL por defecto en columnas obligatorias.

---

## 8. Índices

### 8.1 Reglas

- Indexar todas las FKs.
- Indexar columnas usadas en WHERE y ORDER BY con frecuencia.
- Índices funcionales para búsquedas case-insensitive.
- Índices compuestos cuando el orden importa.
- Nunca indexar por inercia. Cada índice justificado por una consulta real.

### 8.2 Índices actuales destacados

- Índices funcionales: `lower(username)`, `lower(email)` para unicidad case-insensitive.
- Índice compuesto: `(pais_id, celular)` para unicidad a nivel de país.
- Índices de `auditoria_usuarios`: `usuario_id`, `fecha DESC`, `operacion`.

### 8.3 Nombres

- Formato: `idx_<tabla>_<columnas>`.
- Para índices funcionales: `idx_<tabla>_lower_<columna>`.
- Para únicos: `uq_<tabla>_<columnas>`.

---

## 9. Funciones PL/pgSQL

### 9.1 Funciones actuales

- `obtener_comision_actual(plataforma_id UUID, moneda_id UUID)`: retorna la comisión vigente.
- `calcular_comision(monto DECIMAL, plataforma_id UUID, moneda_id UUID)`: comisión total para un monto.
- `resumen_inversiones(usuario_id UUID)`: posiciones actuales por símbolo.
- `calcular_venta_optima(usuario_id UUID, plataforma_id UUID, simbolo VARCHAR, ganancia_deseada DECIMAL)`: precio mínimo y cantidad óptima.

### 9.2 Reglas

- Cada función documentada con `COMMENT ON FUNCTION`.
- Reciben y retornan UUIDs cuando aplique.
- Usan tipos de retorno explícitos. `RETURNS TABLE` para múltiples filas.
- Sin efectos secundarios ocultos. Si modifican datos, se documenta.
- `SECURITY DEFINER` solo cuando sea necesario y con `SET search_path` fijo.
- Manejo de errores con `RAISE` y SQLSTATE cuando aplique.
- No usar `RAISE NOTICE` como logging de producción.

### 9.3 Al agregar una función

- Un archivo por función en `90_funciones/`.
- Nombre descriptivo, snake_case.
- Parámetros y retorno documentados.
- Prueba con `SELECT funcion(args)` en un entorno de pruebas.
- Actualizar `README.md` en la tabla de Funciones PL/pgSQL.

---

## 10. Auditoría

### 10.1 Auditoría de usuarios

- Tabla: `auditoria_usuarios` (BIGSERIAL PK).
- Trigger: `trg_audit_usuarios` → función `fn_audit_usuarios`.
- Disparo: AFTER INSERT OR UPDATE OR DELETE FOR EACH ROW sobre `usuarios`.
- Operaciones: I (INSERT), L (login), U (UPDATE), D (DELETE).
- `updated_at` se excluye del cálculo de `campos_modificados`.

### 10.2 Estructura de `auditoria_usuarios`

- `id BIGSERIAL PRIMARY KEY`
- `operacion CHAR(1)`
- `usuario_id UUID` (FK a usuarios.id)
- `datos_anteriores JSONB`
- `datos_nuevos JSONB`
- `campos_modificados TEXT[]`
- `usuario_bd VARCHAR(100)` (SESSION_USER)
- `usuario_aplicacion VARCHAR(100)` (JWT o 'desconocido')
- `ip_cliente INET`
- `fecha TIMESTAMPTZ DEFAULT NOW()`

### 10.3 Seguridad de la función

- `SECURITY DEFINER` con owner `postgres`.
- `SET search_path = investment_tracker, pg_temp`.
- El usuario `investment_app` no tiene privilegios sobre la tabla ni su secuencia.
- El trigger corre con permisos del owner.

### 10.4 Propagación del usuario

- El backend ejecuta `set_config('app.audit_user', <username>, false)` en cada conexión (vía `AuditUserAwareDataSource`).
- La función lee `current_setting('app.audit_user', true)`.
- Si no hay valor, se registra `'desconocido'`.

### 10.5 Retención

- Por definir. Solo `investor`/`postgres` pueden limpiar la tabla.
- No otorgar `TRUNCATE` a `investment_app`.

---

## 11. Permisos y roles de BD

### 11.1 Roles

- `investor`: administrador / operación manual. Superusuario funcional sobre `investment_tracker`. Acceso total incluyendo `auditoria_usuarios`. Usado por pgAdmin, scripts y DBA.
- `investment_app`: usuario del backend (JDBC vía `application.yml`). SELECT/INSERT/UPDATE/DELETE sobre tablas de negocio. **Sin acceso** a `auditoria_usuarios` ni a su secuencia.

### 11.2 Reglas

- El backend NUNCA usa `investor` como usuario JDBC.
- `investment_app` no puede leer, modificar, borrar ni truncar `auditoria_usuarios`.
- `REVOKE` explícito sobre `auditoria_usuarios` en `150_permisos/`.
- El trigger corre con `SECURITY DEFINER` para que `investment_app` no necesite privilegios sobre la auditoría.
- Cualquier tabla nueva debe evaluar si `investment_app` requiere acceso. Las tablas de auditoría se revocan explícitamente.

### 11.3 GRANT/REVOKE

- `GRANT USAGE ON SCHEMA investment_tracker TO investment_app;`
- `GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA investment_tracker TO investment_app;`
- `REVOKE ALL ON auditoria_usuarios FROM investment_app;`
- `REVOKE ALL ON SEQUENCE auditoria_usuarios_id_seq FROM investment_app;`
- Los GRANT/REVOKE se aplican en `150_permisos/` con nomenclatura estándar.

---

## 12. Datos básicos

### 12.1 Contenido actual

- 54 monedas internacionales.
- 55 países con código ISO, indicativo celular y FK a moneda.
- 3 roles (ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM).
- 3 usuarios de prueba: demo_user, admin, incognito.
- 5 plataformas: eToro, Interactive Brokers, Robinhood, Binance, Trii.
- 11 transacciones de ejemplo en USD y COP.

### 12.2 Reglas

- Los scripts de datos básicos son idempotentes: usar `INSERT ... ON CONFLICT DO NOTHING` o verificar existencia antes.
- Respetar el orden: monedas → países → roles → usuarios → usuario_roles → plataformas → transacciones.
- No duplicar registros entre ejecuciones.
- Los datos de prueba se pueden recrear desde cero en cualquier entorno.

---

## 13. Migraciones y versionado

### 13.1 Versiones

- La versión vigente se obtiene del `README.md`.
- Cada migración tiene un prefijo Version_Release_Hotfix.
- Las migraciones viven en `database/sql/updates/`.

### 13.2 Reglas

- Nunca modificar un script ya desplegado.
- Crear un nuevo script incremental en `updates/`.
- Regenerar `aplica_V_R_H.sql` con el script de construcción.
- Probar la migración en un entorno limpio antes de aplicarla.
- Documentar el cambio en el `README.md` (sección Historial de Versiones).

### 13.3 Rollback

- Cada migración debe evaluar si es reversible.
- Si no lo es, documentarlo explícitamente en el script.
- Los cambios destructivos (DROP) requieren justificación y backup previo.

---

## 14. Seguridad en la BD

- `pg_hba.conf` con autenticación por contraseña. Sin `trust`.
- Contraseñas en `docker-compose.yml` no versionadas en claro.
- Credenciales del backend en `application.yml` encriptadas con AES-256-GCM.
- Conexiones por SSL cuando el entorno lo requiera.
- Sin acceso remoto a PostgreSQL salvo redes controladas.
- Los usuarios `investor` e `investment_app` con contraseñas robustas y rotables.
- Backups cifrados cuando salgan del servidor.

---

## 15. Rendimiento

- `EXPLAIN ANALYZE` antes de agregar índices.
- VACUUM y ANALYZE periódicos (autovacuum por defecto).
- Evitar `SELECT *` en funciones PL/pgSQL y consultas de negocio.
- Evitar funciones en WHERE que impidan el uso de índices.
- Materializar vistas solo cuando aporte y documentar la decisión.
- Paginación en consultas de listas largas.
- Límites de conexión y pooling gestionados por el backend.

---

## 16. Docker e inicialización

### 16.1 Contenedor PostgreSQL

- Imagen: `postgres:16-alpine`.
- Puerto: 5432.
- Volumen: `investment_tracker_data`.
- Variables: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`.
- Ejecuta `docker/postgres/init.sh` al iniciar.

### 16.2 init.sh

- Verifica si el esquema `investment_tracker` existe.
- Si no existe, ejecuta `aplica.sql` (instalación completa).
- Si existe, no toca la BD (preserva datos en reinicios).
- Para migrar, se ejecuta manualmente `aplica_V_R_H.sql`.

### 16.3 Backups

- Scripts en `docker/shellTest/`: `backup-db.sh`, `restore-db.sh`, `reset-all.sh`, `reset-pgadmin.sh`, `check-all.sh`.
- Backups en `backups/` con fecha en el nombre.
- Restauración documentada y probada.

---

## 17. Reglas para agentes automatizados (IA)

1. Leer primero `README.md`, `prompt_inicial.md` y `agente-backend.md` (ver sección 0) antes de proponer cualquier cambio.
2. No inventar tablas, columnas, tipos, funciones ni códigos. Se toman del README y del código real.
3. Todo script es idempotente. Todo script usa transacción explícita.
4. Respetar la nomenclatura Version_Release_Hotfix_Orden_Prefijo_Nombre.sql.
5. Agregar nuevos scripts en el directorio correcto, con el siguiente número de orden disponible.
6. Nunca modificar scripts ya desplegados. Crear uno nuevo en `updates/`.
7. Actualizar `README.md` (MER, relaciones, funciones, datos de prueba) en el mismo PR.
8. Actualizar `aplica.sql` y `aplica_V_R_H.sql` regenerándolos con los scripts de construcción.
9. Respetar la separación `investor`/`investment_app`. Nunca otorgar permisos sobre `auditoria_usuarios` a `investment_app`.
10. Toda tabla nueva debe evaluar permisos y auditoría.
11. Toda contribución nace de un issue del tablero y sigue el flujo de ramas del prompt_inicial.
12. Si falta contexto, solicitar el archivo concreto. Ver sección 21.
13. Si detecta contradicción entre documentos, señalarla y proponer la corrección en el mismo PR.
14. Al agregar una función PL/pgSQL, documentarla con `COMMENT ON FUNCTION` y agregarla a la tabla del README.
15. Al agregar un índice, justificar la consulta que lo motiva.

---

## 18. Definición de "Done" (checklist por PR)

- [ ] Script idempotente (probado ejecutándolo dos veces).
- [ ] Script envuelto en `BEGIN; ... COMMIT;`.
- [ ] Nomenclatura Version_Release_Hotfix_Orden_Prefijo_Nombre.sql respetada.
- [ ] Ubicado en el directorio correcto, con el siguiente número de orden disponible.
- [ ] `README.md` actualizado (MER, relaciones, funciones, datos de prueba, historial de versiones).
- [ ] `aplica.sql` y/o `aplica_V_R_H.sql` regenerados.
- [ ] Permisos evaluados. `REVOKE` sobre tablas de auditoría si aplica.
- [ ] Índices justificados por consultas reales.
- [ ] Función documentada con `COMMENT ON FUNCTION` si aplica.
- [ ] Probado en entorno limpio antes del PR.
- [ ] Issue del tablero referenciado con `Closes #N` o `Refs #N`.
- [ ] Sin `DROP` destructivos sin justificación y backup previo.

---

## 19. Anti-patrones prohibidos

- Scripts no idempotentes.
- Nomenclatura fuera del estándar.
- Modificar scripts ya desplegados.
- `DROP TABLE` sin `IF EXISTS` ni backup.
- Otorgar permisos sobre `auditoria_usuarios` a `investment_app`.
- Usar `investor` como usuario del backend.
- `SELECT *` en consultas de negocio.
- Funciones en WHERE que impiden el uso de índices.
- Índices sin justificación.
- Tipos `FLOAT`/`REAL` para dinero.
- FKs sin índice.
- Triggers sin `SECURITY DEFINER` cuando acceden a tablas restringidas.
- Auditoría sin snapshots JSONB.
- Credenciales en claro en el repositorio.
- Avanzar sin haber leído las fuentes de verdad.

---

## 20. Regla de entrega de archivos .md o comandos que generan archivos .md

Cuando el usuario pida un archivo .md, un documento, una guía, un README, un archivo de configuración con formato markdown, o cualquier comando/salida que vaya a producir un archivo .md, el agente DEBE responder siguiendo estrictamente esta regla:

- No puedo generar ni adjuntar archivos descargables directamente desde esta conversación: solo produzco texto. Lo que sí puedo hacer es entregarte el contenido en un único bloque de código para que lo copies y lo pegues directamente en tu editor (VSCode, Notepad++, etc.) y lo guardes tú como <nombre-archivo>.md. Ese bloque no interpreta nada del contenido, lo conserva literal.

Aplicación obligatoria:

1. Entregar SIEMPRE el contenido completo dentro de un único bloque de código (cercado con backticks triples), sin dividirlo en varios bloques.
2. No interpretar ni renderizar el markdown interno: debe verse como texto plano dentro del bloque.
3. No resumir, no truncar, no usar "..." ni "resto igual": el archivo debe quedar listo para pegar y guardar.
4. Indicar claramente el nombre exacto del archivo a crear.
5. Si el contenido incluye bloques de código internos, usar un delimitador de más backticks para el bloque externo (por ejemplo, cuatro backticks) para evitar que se cierre antes de tiempo.
6. Si el usuario pide explícitamente un archivo binario o descargable, ofrecer alternativa en base64 indicando el comando de decodificación según sistema operativo (certutil -decode en Windows, base64 -d en Linux/Mac).
7. Nunca afirmar que se adjunta, genera o envía un archivo: el agente solo produce texto plano reproducible por el usuario.

---

## 21. Solicitud de archivos para avanzar (regla obligatoria)

El agente NUNCA debe inventar contexto. Si para responder, generar SQL, revisar un PR o proponer arquitectura le falta información, DEBE solicitarla explícitamente al usuario ANTES de continuar.

Formato obligatorio de solicitud (mensaje corto y concreto):

Para avanzar necesito los siguientes archivos:

1. <ruta/archivo.ext> — <motivo breve>
2. <ruta/archivo.ext> — <motivo breve>
   ...
   Con esos archivos continúo con: <entregable esperado>.

Reglas:

1. Pedir solo los archivos estrictamente necesarios para el siguiente paso, no todo el repositorio.
2. Priorizar fuentes de verdad: `README.md`, `docs/prompts/prompt_inicial.md`, `docs/prompts/agente-backend.md`, `docs/prompts/agente-database.md`, luego DDL y scripts reales (`database/sql/install/...`, `database/sql/updates/...`, `application.yml`).
3. Nunca asumir el estado de una tabla, columna, índice, función o permiso: si no está en las fuentes, se pide.
4. Si la tarea abarca varias capas (BD + backend), pedir primero el contrato de datos (tablas, columnas, funciones, permisos) y luego continuar.
5. Si el usuario pide "crear la tabla X", pedir: (a) columnas y tipos, (b) FKs y relaciones, (c) índices necesarios, (d) permisos, (e) si aplica auditoría.
6. Si el usuario pide "agregar un índice", pedir la consulta que lo motiva y el `EXPLAIN ANALYZE` si existe.
7. Si el usuario pide "modificar una función PL/pgSQL", pedir el DDL actual de la función y sus consumidores en el backend.
8. Si el usuario pide "cambiar permisos", pedir la lista actual de GRANT/REVOKE y confirmar la separación `investor`/`investment_app`.
9. Nunca avanzar con supuestos silenciosos. Si se hace un supuesto por continuidad, declararlo explícitamente y marcarlo como pendiente de validación.

Ejemplos:

- Petición: "Crea la tabla plataformas."
  Respuesta esperada: solicitar el MER actual, el DDL de tablas relacionadas (usuarios, monedas), las columnas y tipos, y confirmar permisos y auditoría.
- Petición: "Agrega un índice a usuarios."
  Respuesta esperada: solicitar la consulta que lo motiva, el `EXPLAIN ANALYZE` actual y el DDL de `usuarios`.
- Petición: "Modifica la función calcular_venta_optima."
  Respuesta esperada: solicitar el DDL actual de la función, los consumidores en el backend y el contrato esperado (parámetros y retorno).

---

## 22. Referencias cruzadas entre documentos

- `README.md` (raíz del proyecto): estado general, versión vigente, MER, relaciones, funciones PL/pgSQL, auditoría, datos de prueba y Scrum.
- `docs/prompts/prompt_inicial.md`: idea general, requisitos, reglas para la IA, estándar de organización, nomenclatura SQL y scripts de construcción.
- `docs/prompts/agente-backend.md`: consumidor de la BD. Define el usuario `investment_app`, la auditoría, la ofuscación y los códigos de error.
- `docs/prompts/agente-frontend.md`: consumidor indirecto. Define los datos que se muestran en la UI.
- `docs/prompts/agente-database.md`: este documento.

Regla de consistencia:

- Cualquier cambio en `README.md`, `prompt_inicial.md` o `agente-backend.md` que afecte a la BD debe reflejarse en este archivo en el mismo PR.
- Cualquier convención nueva de este archivo debe reflejarse en `README.md` (MER, relaciones, funciones) y, si aplica, en `prompt_inicial.md`.

---

Fin del documento.
