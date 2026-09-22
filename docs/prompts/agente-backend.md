# agente-backend.md

> Guía oficial de arquitectura y desarrollo backend.
> Versión: 1.0.0
> Stack base: Java LTS 21, Spring Boot 3.3.0, Tomcat 10 embebido, PostgreSQL 16 (JDBC con usuario investment_app), Maven, JUnit 5 + Spring Boot Test.
> Público objetivo: Desarrolladores backend senior, tech leads y agentes automatizados de generación de código.
> Documento hermano del frontend, la base de datos y el README del proyecto. Ver sección 0 y 22.

---

## 0. Contexto obligatorio y fuentes de verdad

Antes de proponer, generar, modificar o revisar cualquier artefacto del backend, el agente (humano o IA) DEBE leer y respetar las siguientes fuentes, en este orden de autoridad:

1. `README.md` (raíz de `investment-tracker/`)
   - Estado general del proyecto, versión vigente (Version/Release/Hotfix), arquitectura, endpoints publicados, stack, modelo de datos, seguridad, ofuscación, auditoría y Scrum.
   - Fuente principal para endpoints, DTOs, códigos de error, roles y reglas de seguridad.

2. `docs/prompts/prompt_inicial.md`
   - Idea general del proyecto, requisitos funcionales, reglas para la IA, directrices por capa y flujo obligatorio por issue.
   - Fuente para el propósito del producto y las reglas de negocio que impactan al backend.

3. `docs/prompts/agente-database.md`
   - Reglas de la base de datos: nomenclatura SQL, idempotencia, permisos investor/investment_app, auditoría con SECURITY DEFINER, funciones PL/pgSQL y migraciones.
   - Todo acceso a datos del backend debe respetar los nombres de tabla, columnas, funciones y permisos definidos aquí.

4. Este archivo (`docs/prompts/agente-backend.md`)
   - Especifica cómo se construye el backend: arquitectura hexagonal, capas, DTOs, manejo de errores, seguridad, ofuscación, auditoría, testing y reglas para agentes IA.

5. `docs/prompts/agente-frontend.md`
   - Define el contrato esperado por el frontend (formas de DTO, nombres de campos, códigos de error y códigos de éxito). El backend es responsable de mantener esos contratos estables.

Reglas derivadas:

- Si el agente no tiene contexto suficiente (entidad, repositorio, contrato de un endpoint, código de error existente), DEBE pedir el archivo concreto antes de generar código. Ver sección 21.
- Si detecta contradicción entre este archivo y `README.md`/`prompt_inicial.md`, DEBE señalarlo, proponer la corrección y actualizar el documento correspondiente en el mismo PR.
- Está prohibido inventar endpoints, campos, códigos de error, roles o funciones PL/pgSQL.

---

## 1. Principios rectores (Big-Tech Standard)

1. Arquitectura Hexagonal (Puertos y Adaptadores): Domain, Application, Infrastructure claramente separados. Sin dependencias del dominio hacia frameworks.
2. Contratos tipados: DTOs de request y response explícitos. Nunca exponer entidades JPA.
3. Funciones con un solo propósito: métodos pequeños, nombres claros, sin efectos colaterales ocultos.
4. Código limpio: sin warnings de compilación ni análisis estático. Baja complejidad ciclomática. Sin duplicación.
5. Seguridad por defecto: autenticación, autorización, validación, sanitización y ofuscación como capas transversales.
6. Ofuscación solo a la salida: nunca en dominio ni en validaciones internas. El JSON se enmascara, la lógica usa datos reales.
7. Auditoría automática: los cambios en `usuarios` se registran vía trigger; el usuario autenticado se propaga por `AuditUserAwareDataSource`.
8. Errores consistentes: códigos por dominio (AUTH-_, REG-_, REC-_, PWD-_, VAL-_, ENC-_, BIZ-_, RATE-_, SYS-\*). Nunca exponer stack traces ni detalles de Jakarta `@Valid` al cliente.
9. Pruebas deterministas: unitarias rápidas con mocks; integración con `@SpringBootTest`. Helpers de `BaseIntegrationTest` para consistencia.
10. Convención sobre configuración: nombres, paquetes y exports siguen una única convención para que cualquier dev o agente encuentre las cosas en segundos.
11. Fuentes de verdad primero: leer `README.md`, `prompt_inicial.md`, `agente-database.md` y este archivo antes de escribir código (ver sección 0).
12. Trazabilidad con el tablero: todo cambio nace de un issue del Project Board y se referencia en el commit/PR.

---

## 2. Estructura de directorios del backend

Solo se listan las ramas relevantes al backend. Las ramas frontend, database y backups se documentan en sus respectivos agentes o en el README.

- **`backend/`** - API REST Spring Boot 3.x + Java 21
  - `pom.xml` - Dependencias Maven (Spring Boot 3.3.0, Spring Security, Spring Data JPA, Spring Mail, Jackson, PostgreSQL driver, JUnit 5, Testcontainers si aplica)
  - **`src/`**
    - **`main/`**
      - **`java/`**
        - **`com/`**
          - **`investmenttracker/`**
            - `InvestmentTrackerApplication.java` - Clase principal (puerto 7700)
            - **`domain/`** - Capa de dominio (hexagonal)
              - **`model/`** - Entidades puras del dominio
              - **`vo/`** - Value Objects (Email, Username, Celular, PaisId)
              - **`port/`**
                - **`in/`** - Puertos de entrada (casos de uso)
                - **`out/`** - Puertos de salida (repositorios, servicios externos)
            - **`application/`** - Capa de aplicación
              - **`usecase/`** - Implementación de casos de uso
              - **`service/`** - Servicios de orquestación (los actuales LoginService, RegisterService, etc.)
            - **`infrastructure/`** - Capa de infraestructura
              - **`web/`**
                - **`controller/`** - AuthController, RegisterController, PasswordRecoveryController, EncryptionController, TestValidationController
                - **`dto/`**
                  - **`request/`** - ChangePasswordRequest, LoginRequest, RegisterRequest, RegisterConfirmRequest, PasswordRecoveryRequest, TokenVerificationRequest, RestartPasswordRequest, DeleteAccountRequest, UpdateMyProfileRequest
                  - **`response/`** - LoginResponse, ProfileResponse, ErrorResponse, SuccessResponse, EncryptionResponse
                - **`mapper/`** - Mappers DTO ↔ Dominio
              - **`persistence/`**
                - **`repository/`** - UserRepository, RoleRepository, PaisRepository (Spring Data JPA)
                - **`entity/`** - User, Role, Pais (JPA)
                - **`adapter/`** - Implementación de puertos de salida
              - **`security/`**
                - `JwtAuthFilter.java` - Filtro de autenticación JWT
                - `RateLimitFilter.java` - Filtro de rate limiting
                - `UserDetailsServiceImpl.java` - Carga de usuarios
              - **`masking/`** - Ofuscación
                - `MaskType.java` - Enum (EMAIL, CELULAR, NOMBRE)
                - `Masked.java` - Anotación `@Masked(MaskType)`
                - `DataMasking.java` - Reglas estáticas
                - `MaskingContext.java` - ThreadLocal<Boolean>
                - `MaskedSerializer.java` - JsonSerializer
                - `MaskingAnnotationIntrospector.java`
                - `MaskingFilter.java` - OncePerRequestFilter
                - `JacksonMaskingConfig.java`
              - **`audit/`**
                - `AuditUserAwareDataSource.java` - Wrapper del DataSource
                - `AuditContextService.java` - Forzar app.audit_user en login
              - **`config/`**
                - `EncryptedDataSourceConfig.java`
                - `SecurityConfig.java`
                - `MailConfig.java`
                - `SensitiveFieldsProperties.java`
              - **`exception/`**
                - `AuthenticationException.java`
                - `GlobalExceptionHandler.java`
              - **`util/`**
                - `LogSanitizer.java`
              - **`enums/`**
                - `ErrorCode.java`
                - `SuccessfulCode.java`
                - `LockLevel.java`
                - `Plan.java`
      - **`resources/`**
        - `application.yml` - Configuración (DB encriptada, JWT, SMTP, sensitive-fields, puerto 7700)
        - `application-dev.yml`
        - `application-test.yml`
    - **`test/`**
      - **`java/`**
        - **`com/investmenttracker/`**
          - **`config/TestConfig.java`**
          - **`controller/`**
            - `BaseIntegrationTest.java` - Helpers (loginAndGetToken, toJson, printBanner, printStep, printSubStep, clearBlacklist)
            - `AuthIntegrationTest.java` - 31 casos
            - `ChangeMyPasswordIntegrationTest.java` - 11 casos
            - `EncryptionIntegrationTest.java` - 7 casos
            - `PasswordRecoveryIntegrationTest.java` - 4 casos
            - `ProfileIntegrationTest.java` - 10 casos
            - `RateLimitIntegrationTest.java` - 4 casos
            - `RefreshTokenIntegrationTest.java` - 7 casos
            - `RegisterIntegrationTest.java` - 8 casos
          - **`service/`**
            - `LoginServiceTest.java` - 6 casos
            - `RegisterServiceTest.java` - 11 casos
      - **`resources/`**
        - `.unitTestEnv` - Datos de prueba

---

## 3. Arquitectura Hexagonal (obligatoria)

### 3.1 Capas

- **Domain**: entidades puras, value objects, reglas de negocio, interfaces de puertos. Sin dependencias de Spring, JPA ni HTTP.
- **Application**: casos de uso que orquestan el dominio y los puertos. Transaccionalidad aquí.
- **Infrastructure**: adaptadores concretos. Controllers REST, repositorios JPA, clientes SMTP, filtros de seguridad.

### 3.2 Reglas de dependencia

- Infrastructure → Application → Domain.
- El dominio nunca importa Spring, JPA, Jackson ni Jakarta Validation.
- Las validaciones de negocio viven en el dominio o en la capa de aplicación; las validaciones sintácticas (`@NotBlank`) viven en los DTOs de request.

### 3.3 Puertos y adaptadores

- Puertos de entrada (driving): casos de uso expuestos a los controllers.
- Puertos de salida (driven): repositorios, mail, encriptación, tokens.
- Cada puerto tiene una interfaz en `domain/port` y al menos una implementación en `infrastructure`.

---

## 4. DTOs y contratos

### 4.1 Reglas

- Nunca exponer entidades JPA en la API. Siempre DTOs.
- Request y response separados. No reutilizar DTOs entre operaciones si los campos difieren.
- Todos los campos obligatorios anotados con `@NotNull`/`@NotBlank`/`@Size` según corresponda.
- Los DTOs son inmutables cuando sea posible (records de Java 21).
- Los nombres de campo siguen el contrato publicado en `README.md`.

### 4.2 DTOs de request

- `LoginRequest`: username, password.
- `RegisterRequest`: username, email, nombreCompleto, password, repeatPassword, celular, paisId, plan.
- `RegisterConfirmRequest`: username, email, nombreCompleto, celular, paisId, plan, token.
- `PasswordRecoveryRequest`: username, email, nuevoPassword.
- `TokenVerificationRequest`: username, email, token, nuevoPassword.
- `ChangePasswordRequest`: username, email, actualPassword, nuevoPassword, repetirNuevoPassword.
- `RestartPasswordRequest`: username, email, nombre, nueva, repetir.
- `DeleteAccountRequest`: username.
- `UpdateMyProfileRequest`: id, username, email, nombreCompleto, paisId, celular. Todos obligatorios.
- `EncryptionRequest`: cadena_string_a_encriptar.

### 4.3 DTOs de response

- `LoginResponse`: solo token y refreshToken.
- `ProfileResponse`: id, username, email, nombreCompleto, celular, pais (PaisDTO), activo, ultimoLogin, createdAt.
- `SuccessResponse`: code, message, timestamp.
- `ErrorResponse`: code, message, timestamp.
- `EncryptionResponse`: textoOriginal, textoEncriptado (o textoEncriptado, textoDesencriptado).

### 4.4 Ofuscación en DTOs

- Cualquier campo del response que exponga email, celular, nombreCompleto, montos, saldos o datos personales/financieros DEBE anotarse con `@Masked(MaskType.XXX)`.
- Los endpoints en `MaskingFilter.OWN_DATA_PATHS` desactivan la máscara en runtime para el propio usuario.
- El login es minimalista: no retorna datos personales. El perfil propio se consulta en `/api/auth/get-my-profile`.

---

## 5. Manejo de errores

### 5.1 Códigos por dominio

| Prefijo | Dominio                      | Ejemplos                                                                           |
| ------- | ---------------------------- | ---------------------------------------------------------------------------------- |
| AUTH-\* | Autenticación y autorización | AUTH-001 credenciales inválidas, AUTH-007 acceso denegado, AUTH-008 no autenticado |
| REG-\*  | Registro y unicidad          | REG-001 username existe, REG-002 email existe, REG-007 país no encontrado          |
| REC-\*  | Recuperación de contraseña   | REC-001 intentos excedidos, REC-004 usuario no coincide                            |
| PWD-\*  | Contraseña                   | PWD-001 no coinciden, PWD-002 no cumple criterios, PWD-003 actual incorrecta       |
| VAL-\*  | Validaciones de negocio      | VAL-001 error de validación, VAL-005 campos vacíos                                 |
| ENC-\*  | Encriptación AES-GCM         | ENC-001 error al encriptar, ENC-003 texto null/vacío                               |
| BIZ-\*  | Reglas de negocio            | BIZ-001 usuario no encontrado, BIZ-002 plataforma no encontrada                    |
| RATE-\* | Rate limiting                | RATE-001 demasiadas peticiones                                                     |
| SYS-\*  | Errores internos y sistema   | SYS-001 error interno, SYS-02 error de conexión, SYS-03 argumentos inválidos       |

### 5.2 Regla de SYS-03

- Los errores de Jakarta Bean Validation (`@Valid`, `@NotBlank`, `@NotNull`, `@Size`) se reportan con `SYS-03` y HTTP 500.
- Nunca exponer al cliente el detalle de los campos que fallaron.
- El detalle se registra en logs con `log.warn("Validación fallida: {}", details)`.
- Las validaciones de negocio (en el servicio) usan códigos específicos (PWD-_, VAL-_, etc.) con HTTP 400.

### 5.3 GlobalExceptionHandler

- Único punto de manejo de excepciones. Traduce excepciones a `ErrorResponse` con el código correcto.
- `AuthenticationException` → AUTH-\*.
- `MethodArgumentNotValidException` → SYS-03 (500).
- `ConstraintViolationException` → SYS-03 (500).
- Excepciones no controladas → SYS-001 (500).

### 5.4 Nunca

- Devolver stack traces.
- Devolver nombres de tablas, columnas o detalles de BD.
- Exponer la lista de campos que fallaron en `@Valid`.
- Loggear datos sensibles (usar `LogSanitizer`).

---

## 6. Seguridad

### 6.1 Autenticación

- JWT con firma HMAC-SHA384, expiración 24h.
- Refresh token aleatorio de 64 bytes, TTL 1h, sesión deslizante.
- Almacenamiento en memoria (ConcurrentHashMap) con invalidación en logout.
- Endpoints públicos: `/api/auth/login`, `/api/auth/refresh-token`, `/api/auth/register/**`, `/api/auth/recovery/**`, `/api/test/health`.
- Todo lo demás requiere JWT válido.

### 6.2 Autorización

- Roles: ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM.
- Uso de `@PreAuthorize` o configuración equivalente en `SecurityConfig`.
- Endpoints ADMIN: `/api/auth/restart-password`, `/api/encryption/**`, `/api/test/delete-user/**`.
- Endpoints de propietario: `/api/auth/change-my-pass`, `/api/auth/delete-account`, `/api/auth/get-my-profile`, `/api/auth/update-my-profile`.
- Los endpoints de "mi propio X" validan que `username`/`id` del request coincida con el JWT.

### 6.3 Contraseñas

- BCrypt para hash.
- Validaciones: 8+ caracteres, 1 mayúscula, 1 carácter especial, sin comillas.
- Case-sensitive en comparaciones de contraseña.
- Case-insensitive en email.

### 6.4 Control de intentos fallidos

- 3 intentos. Bloqueo progresivo: 5min → 15min → 30min → 1h → 12h → 24h → permanente.
- Gestionado por `LoginComponent` y persistido en la entidad User.

### 6.5 AES-256-GCM

- Encriptación bidireccional para datos sensibles.
- IV aleatorio de 12 bytes por operación.
- `AESEncryptionComponent` maneja encrypt/decrypt.
- Usado por: credenciales de BD en `application.yml`, configuración SMTP, endpoints `/api/encryption/**`.

### 6.6 Tokens

- Blacklist de JWT en logout hasta expiración.
- Refresh tokens revocados en logout.
- `JwtAuthFilter` valida firma, expiración y blacklist.

---

## 7. Ofuscación de datos sensibles

### 7.1 Principios

- Ocurre solo en serialización (Jackson). Nunca en dominio.
- Las validaciones internas usan datos reales.
- Endpoints en `MaskingFilter.OWN_DATA_PATHS` devuelven datos reales al dueño.
- El resto aplica máscara por defecto.

### 7.2 Componentes

- `MaskType` (enum): EMAIL, CELULAR, NOMBRE. Extensible.
- `@Masked(MaskType)`: anota el campo del DTO.
- `DataMasking`: reglas estáticas.
- `MaskingContext`: ThreadLocal<Boolean> con el estado.
- `MaskedSerializer`: JsonSerializer que aplica la máscara.
- `MaskingAnnotationIntrospector`: conecta `@Masked` con `MaskedSerializer`.
- `MaskingFilter`: activa/desactiva por path.
- `JacksonMaskingConfig`: registra el introspector.

### 7.3 Formatos

| Tipo    | Input             | Output            |
| ------- | ----------------- | ----------------- |
| EMAIL   | user@test.com     | u***@***.com      |
| CELULAR | 3001234567        | \*\*\*4567        |
| NOMBRE  | Juan Pérez García | J*** P*** G\*\*\* |

### 7.4 Cómo extender

- Agregar tipo: enum `MaskType` + case en `DataMasking.mask`.
- Anotar campos: `@Masked(MaskType.NUEVO)`.
- Marcar endpoint propio: agregar ruta a `OWN_DATA_PATHS` en `MaskingFilter` (con justificación en commit).
- Forzar ofuscación global: vaciar `OWN_DATA_PATHS`.

### 7.5 Filtro de logs

- `SensitiveFieldsProperties` lee `security.sensitive-fields` desde `application.yml`.
- `LogSanitizer.sanitize(field, value)` devuelve `[PROTEGIDO]` si el campo está en la lista.
- Lista vigente: email, celular, nombre_completo, password, password_hash, passwordHash, token, refreshToken, actualPassword, nuevoPassword, repetirNuevoPassword.
- Nunca loggear sin pasar por `LogSanitizer`.

---

## 8. Auditoría

### 8.1 Auditoría de usuarios

- Tabla: `auditoria_usuarios` (BIGSERIAL PK) gestionada por trigger.
- Trigger: `trg_audit_usuarios` → función `fn_audit_usuarios` (SECURITY DEFINER, owner postgres).
- Disparo: AFTER INSERT OR UPDATE OR DELETE FOR EACH ROW sobre `usuarios`.
- Operaciones: I (INSERT), L (login), U (UPDATE), D (DELETE).
- Excluye `updated_at` del cálculo de campos_modificados.

### 8.2 Propagación del usuario autenticado

- `AuditUserAwareDataSource` envuelve el DataSource. Lee `SecurityContextHolder` y ejecuta `set_config('app.audit_user', <username>, false)` en cada `getConnection()`.
- `AuditContextService.setCurrentUser(username)` con `@Transactional(propagation = MANDATORY)` fuerza el username durante el login, antes de emitir el JWT.
- El trigger consume `current_setting('app.audit_user', true)`.

### 8.3 Reglas

- Cuando se modifiquen datos sensibles, el usuario autenticado se propaga automáticamente.
- Si el flujo no tiene JWT (ej: login), invocar explícitamente `AuditContextService.setCurrentUser(username)`.
- Nunca usar `investor` como usuario JDBC. Siempre `investment_app`.
- Nunca otorgar permisos sobre `auditoria_usuarios` a `investment_app`.

---

## 9. Usuario de base de datos

- Usuario de la aplicación: `investment_app`. Configurado en `application.yml` con credenciales AES-256-GCM.
- El backend nunca usa `investor` como usuario JDBC.
- Si se requiere consultar auditoría, se hace con `investor`/`postgres` (fuera del backend).
- Los scripts SQL de permisos viven en `database/sql/install/150_permisos/`.

---

## 10. Validación

### 10.1 Validación sintáctica

- Jakarta Bean Validation (`@Valid`) en los controllers.
- `@NotBlank`/`@NotNull`/`@Size` en los `*Request.java`.
- Los errores se manejan en `GlobalExceptionHandler.handleValidationException()` → SYS-03 (500) sin detalle.

### 10.2 Validación de negocio

- En la capa de aplicación o dominio.
- Devuelve códigos específicos (PWD-_, VAL-_, REG-\*, etc.) con HTTP 400.
- Ejemplos: contraseñas no coinciden (PWD-001), email ya registrado (REG-002), país inactivo (REG-007).

---

## 11. Testing

### 11.1 Tipos

- Unitarias: JUnit 5 + Mockito. Rápidas, sin Spring Context. Cubren servicios y componentes.
- Integración: `@SpringBootTest` con MockMvc. Cubren endpoints completos.

### 11.2 BaseIntegrationTest

- Helpers: `loginAndGetToken`, `toJson`, `printBanner`, `printStep`, `printSubStep`, `clearBlacklist`.
- `clearBlacklist()` limpia blacklist de JWT y rate limiter, pero **no** refresh tokens (intencional para RefreshTokenIntegrationTest).
- Usar `printBanner`, `printStep`, `printSubStep` para consistencia en logs.

### 11.3 Reglas por suite

- `ChangeMyPasswordIntegrationTest`: NO usa `@BeforeEach` para tokens (evita bloqueos). Usa `@BeforeAll` para obtener tokens de demo_user y admin una vez. Restauración de contraseña en la última prueba (CMP-11) con token admin.
- `RefreshTokenIntegrationTest`: NO usa `@BeforeEach` (necesita persistencia del refresh token entre pruebas).
- `ProfileIntegrationTest`: usa `@BeforeAll` para token e id reales. Restaura nombreCompleto original tras cada test que lo modifica.
- El resto: `@BeforeEach` para token fresco.

### 11.4 Datos de prueba

- `.unitTestEnv` en `src/test/resources/` con usuarios, emails, contraseñas y URLs.
- `TestConfig` centraliza el acceso a esas variables.

### 11.5 Cobertura

- Mínimo 80% en services y components.
- 100 pruebas actuales distribuidas entre las suites listadas en `README.md`.

### 11.6 Ejecución

- Todas: `mvn test`
- Suite específica: `mvn test -Dtest=NombreDeLaSuite`

---

## 12. Estilo de código

- Java 21 con records donde aplique.
- TypeScript no aplica. Sin `var` cuando el tipo no es obvio.
- Nombres:
  - Clases: PascalCase.
  - Métodos y variables: camelCase.
  - Constantes: UPPER_SNAKE_CASE.
  - Paquetes: minúsculas.
- Funciones de un solo propósito.
- Sin warnings de compilación ni de análisis estático (SonarLint).
- Sin duplicación. Baja complejidad ciclomática.
- Comentarios solo cuando aportan valor (decisiones, invariantes). Nada de comentarios obvios.

---

## 13. Logging

- SLF4J + Logback.
- Niveles: ERROR (fallos críticos), WARN (validaciones fallidas, intentos fallidos), INFO (eventos de negocio), DEBUG (detalle en desarrollo), TRACE (nunca en producción).
- Nunca loggear datos sensibles. Usar `LogSanitizer.sanitize(fieldName, value)`.
- Los campos de `security.sensitive-fields` nunca aparecen en logs en claro.
- El detalle de las validaciones Jakarta fallidas va en logs con `log.warn`.
- Los logs de login exitoso no incluyen email, celular ni nombre completo.

---

## 14. Configuración

- `application.yml` con valores por defecto sensatos.
- Sobrescritura por perfil: `application-dev.yml`, `application-test.yml`.
- Nunca commitear credenciales en claro. Las credenciales sensibles van encriptadas con AES-256-GCM.
- Variables de entorno para secretos en despliegue.
- Propiedades personalizadas bajo prefijos claros: `security.sensitive-fields`, `refresh-token`, `jwt`, `smtp`.
- Toda propiedad nueva se documenta en el README o en este archivo.

---

## 15. Convenciones de Maven

- `pom.xml` con Java 21, Spring Boot 3.3.0.
- Dependencias gestionadas por el BOM de Spring Boot. Sin versiones hardcodeadas excepto cuando sea indispensable.
- Plugins: `spring-boot-maven-plugin`, `maven-surefire-plugin`, `maven-compiler-plugin`.
- Sin dependencias innecesarias. Cada una justificada en PR.
- `mvn verify` debe pasar antes de abrir PR.

---

## 16. Seguridad en el código

- Sin `System.out.println`. Usar logger.
- Sin secretos hardcodeados.
- Sin SQL concatenado. Usar JPA o consultas parametrizadas.
- Sin `Runtime.exec` sobre entrada del usuario.
- Sanitización de HTML cuando se genere HTML dinámico.
- CORS configurado explícitamente en `SecurityConfig`.
- CSRF deshabilitado solo si se usa JWT stateless (documentar la decisión).
- Headers de seguridad (HSTS, X-Content-Type-Options, X-Frame-Options) configurados en Nginx.

---

## 17. Reglas para agentes automatizados (IA)

1. Leer primero `README.md`, `prompt_inicial.md`, `agente-database.md` y este archivo (ver sección 0) antes de proponer cualquier cambio.
2. No inventar endpoints, DTOs, códigos de error, roles ni funciones PL/pgSQL. Se toman del README y del código real.
3. Respetar la arquitectura hexagonal. El dominio no importa Spring, JPA ni Jakarta.
4. Cualquier DTO de response con datos sensibles debe anotar el campo con `@Masked`.
5. Nunca usar `investor` como usuario JDBC. Siempre `investment_app`.
6. Nunca otorgar permisos sobre `auditoria_usuarios` a `investment_app`.
7. Usar `LogSanitizer` antes de loggear datos sensibles.
8. Los errores de `@Valid` se reportan como SYS-03 (500) sin detalle.
9. Los endpoints "mi propio X" validan que `username`/`id` coincidan con el JWT.
10. Al agregar una prueba, seguir el patrón de `BaseIntegrationTest` y usar sus helpers.
11. Toda contribución nace de un issue del tablero y sigue el flujo de ramas del prompt_inicial.
12. Si falta contexto, solicitar el archivo concreto. Ver sección 21.
13. Si detecta contradicción entre documentos, señalarla y proponer la corrección en el mismo PR.
14. Al agregar un endpoint, actualizar el README con la fila correspondiente y agregar los tests.
15. Al agregar un código de error, actualizar `ErrorCode.java`, el README y las claves i18n del frontend.

---

## 18. Definición de "Done" (checklist por PR)

- [ ] Código compila sin warnings.
- [ ] `mvn verify` pasa.
- [ ] Cobertura >= 80% en services y components.
- [ ] Pruebas unitarias e integración verdes.
- [ ] Sin datos sensibles en logs (verificado con `LogSanitizer`).
- [ ] DTOs nuevos con `@Masked` donde aplique.
- [ ] Endpoints nuevos documentados en `README.md` (tabla de servicios publicados).
- [ ] Códigos de error nuevos registrados en `ErrorCode.java` y en `README.md`.
- [ ] Migraciones SQL asociadas creadas y enlazadas (con `agente-database.md`).
- [ ] Auditoría verificada si el cambio toca `usuarios`.
- [ ] Swagger/OpenAPI actualizado si aplica.
- [ ] Issue del tablero referenciado con `Closes #N` o `Refs #N`.
- [ ] Sin secretos hardcodeados. Sin `investor` como usuario JDBC.

---

## 19. Anti-patrones prohibidos

- Exponer entidades JPA en la API.
- Mezclar lógica de negocio en controllers.
- Duplicar validaciones entre controller y servicio sin justificación.
- Errores sin código.
- Logs con datos sensibles en claro.
- Uso de `investor` como usuario JDBC.
- Otorgar permisos sobre `auditoria_usuarios` a `investment_app`.
- SQL concatenado.
- `@Valid` con detalle expuesto al cliente.
- Exponer `username`, `email`, `nombreCompleto`, `celular`, `pais`, `tokenType`, `expiresIn` o `refreshTokenExpiresIn` en login o refresh-token.
- Inventar endpoints, DTOs o códigos de error.
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

El agente NUNCA debe inventar contexto. Si para responder, generar código, revisar un PR o proponer arquitectura le falta información, DEBE solicitarla explícitamente al usuario ANTES de continuar.

Formato obligatorio de solicitud (mensaje corto y concreto):

Para avanzar necesito los siguientes archivos:

1. <ruta/archivo.ext> — <motivo breve>
2. <ruta/archivo.ext> — <motivo breve>
   ...
   Con esos archivos continúo con: <entregable esperado>.

Reglas:

1. Pedir solo los archivos estrictamente necesarios para el siguiente paso, no todo el repositorio.
2. Priorizar fuentes de verdad: `README.md`, `docs/prompts/prompt_inicial.md`, `docs/prompts/agente-database.md`, `docs/prompts/agente-backend.md`, luego código real (controllers, services, DTOs, entidades, tests, application.yml).
3. Nunca asumir la forma de un DTO, un endpoint, un código de error ni un rol: si no está en las fuentes, se pide.
4. Si la tarea abarca varias capas (backend + DB), pedir primero el contrato de datos (tablas, funciones, permisos) y luego continuar.
5. Si el usuario pide "crear el endpoint X" sin contrato, pedir: (a) tabla(s) involucradas, (b) DTO de request, (c) DTO de response, (d) roles con acceso, (e) códigos de error aplicables, (f) si aplica auditoría.
6. Si el usuario pide "agregar auditoría", pedir el DDL de la tabla auditada y confirmar el mapeo de operaciones (I/U/L/D).
7. Si el usuario pide "agregar un código de error", pedir el listado actual de `ErrorCode.java` y el nombre del dominio.
8. Si el usuario pide "modificar la ofuscación", pedir el DTO afectado, la lista de `OWN_DATA_PATHS` y la lista de `security.sensitive-fields`.
9. Nunca avanzar con supuestos silenciosos. Si se hace un supuesto por continuidad, declararlo explícitamente y marcarlo como pendiente de validación.

Ejemplos:

- Petición: "Crea el endpoint /api/plataformas."
  Respuesta esperada: solicitar el DDL de `plataformas` (columnas, tipos, FKs), el DTO de request y response, los roles con acceso, los códigos de error previstos y confirmar si hay auditoría asociada.
- Petición: "Agrega un campo nuevo al perfil."
  Respuesta esperada: solicitar `UpdateMyProfileRequest.java`, `ProfileResponse.java`, el DDL actual de `usuarios` y confirmar si el campo va con `@Masked` y a `security.sensitive-fields`.
- Petición: "Cambia la validación de contraseña."
  Respuesta esperada: solicitar `SecurityLoginComponent.java`, `ChangeMyPasswordService.java` y las reglas actuales documentadas en README para no romper los códigos PWD-\*.

---

## 22. Referencias cruzadas entre documentos

- `README.md` (raíz del proyecto): estado general, versión vigente, endpoints publicados, stack, arquitectura, modelo de datos, seguridad, ofuscación, auditoría y Scrum.
- `docs/prompts/prompt_inicial.md`: idea general, requisitos funcionales, reglas para la IA, directrices por capa y flujo por issue.
- `docs/prompts/agente-frontend.md`: contrato esperado por el frontend (formas de DTO, nombres de campos, códigos de error y éxito).
- `docs/prompts/agente-database.md`: DDL, funciones PL/pgSQL, permisos, auditoría, nomenclatura SQL y migraciones.
- `docs/prompts/agente-backend.md`: este documento.

Regla de consistencia:

- Cualquier cambio en `README.md`, `prompt_inicial.md` o `agente-database.md` que afecte al backend debe reflejarse en este archivo en el mismo PR.
- Cualquier convención nueva de este archivo debe reflejarse en `README.md` (sección de stack) y, si aplica, en `prompt_inicial.md`.

---

Fin del documento.
