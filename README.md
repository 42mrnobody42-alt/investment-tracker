# PROMPT INICIAL - Sistema de Gestión de Inversiones

## Fecha: 2026-06-23

## Proyecto: Investment Tracker Pro

### Descripción General

Aplicación web para seguimiento de inversiones con arquitectura de microservicios usando Docker.

### Stack Tecnológico

- **Backend**: Java LTS 21 (Spring Boot 3.x)
- **Base de datos**: PostgreSQL 16
- **Frontend**: React 18+ con CSS moderno
- **Servidor Web**: Tomcat 10 (embebido en Spring Boot)
- **Seguridad**: HTTPS + JWT
- **Contenedores**: Docker + Docker Compose
- **Gestion de DB**: pgadmin 4 Latest
- **Control de versiones**: Git/GitHub
- **Sistema Operativo**: Pop OS 22.04
- **IDE**: Visual Studio Code

### Requisitos Funcionales

1. Sistema de autenticación con JWT
2. Roles de usuario
3. Registro de inversiones en múltiples plataformas
4. Gestión de comisiones variables por plataforma
5. Registro de compras y ventas de acciones
6. Dashboard de resultados de inversiones
7. Calculadora de venta óptima para ganancias objetivo

### Estructura del Proyecto

#### Estructura de directorios

- **`investment-tracker/`** - Raíz del proyecto
  - **`docker/`** - Configuración de contenedores
    - `docker-compose.yml` - Orquestación de servicios
    - `Dockerfile.backend` - Imagen Spring Boot
    - `Dockerfile.frontend` - Imagen React
    - **`nginx/`** - Reverse proxy
      - `default.conf` - Configuración HTTPS
    - **`pgadmin/`** - Admin DB
      - `servers.json` - Configuración servidores
    - **`postgres/`** - Base de datos
      - `init.sql` - Inicialización BD
    - **`shellTest/`** - Scripts de mantenimiento
      - `check-all.sh` - Verificación completa
      - `reset-all.sh` - Reset BD (mantiene pgadmin)
      - `reset-pgadmin.sh` - Reset solo pgadmin
      - `backup-db.sh` - Backup BD
      - `restore-db.sh` - Restaurar BD
  - **`database/`** - Scripts SQL
    - **`sql/`**
      - `01_schema.sql` - Esquema v2.1.0 (UUID + Monedas)
      - `02_functions.sql` - Funciones PL/pgSQL v2.0.0
      - `03_seed.sql` - Datos iniciales v2.1.0
  - **`backend/`** - API REST Spring Boot
    - `pom.xml` - Dependencias Maven
    - **`src/`** - Código fuente Java 21
  - **`frontend/`** - SPA React 18
    - `package.json` - Dependencias npm
    - **`src/`** - Código fuente React
  - **`docs/`** - Documentación
    - `README.md` - Documento principal
    - **`prompts/`** - Historial de prompts

#### Estructura detallada de archivos (62 archivos, 46 directorios)

- **`investment-tracker/`** - Raíz del proyecto
  - `.gitignore` - Archivos ignorados por Git
  - `LICENSE` - Licencia del proyecto
  - `README.md` - Documentación principal
  - **`.vscode/`**
    - `settings.json` - Configuración de VS Code
  - **`docker/`** - Contenedores y orquestación
    - `.env` - Variables de entorno Docker
    - `docker-compose.yml` - Orquestación de servicios
    - `Dockerfile.backend` - Imagen para Spring Boot
    - `Dockerfile.frontend` - Imagen para React
    - **`nginx/`**
      - `default.conf` - Reverse proxy HTTPS
      - `nginx-frontend.conf` - Servidor frontend
      - **`ssl/`**
        - `localhost.crt` - Certificado SSL autofirmado
        - `localhost.key` - Llave privada SSL
    - **`pgadmin/`**
      - `servers.json` - Configuración servidores pgAdmin
    - **`postgres/`**
      - `init.sql` - Inicialización de BD
    - **`shellTest/`** - Scripts de mantenimiento
      - `check-all.sh` - Verificación completa
      - `reset-all.sh` - Reset BD (mantiene pgadmin)
      - `reset-pgadmin.sh` - Reset solo pgadmin
      - `backup-db.sh` - Backup de BD
      - `restore-db.sh` - Restaurar desde backup
      - `final-check-uuid.sh` - Verificación UUID
  - **`database/`** - Base de datos
    - **`sql/`**
      - `01_schema.sql` - Esquema v2.1.0 (UUID + Monedas)
      - `02_functions.sql` - Funciones PL/pgSQL v2.0.0
      - `03_seed.sql` - Datos iniciales v2.1.0
    - **`MER/`**
      - `diagram.md` - Diagrama entidad-relación
  - **`backend/`** - API REST Spring Boot 3.x + Java 21
    - `pom.xml` - Dependencias Maven
    - **`src/main/java/com/investmenttracker/`**
      - `InvestmentTrackerApplication.java` - Clase principal (puerto 7700)
      - **`config/`**
        - `SecurityConfig.java` - Spring Security + JWT
      - **`controller/`** - Endpoints REST
        - `AuthController.java` - Login + restart-password
        - `TestValidationController.java` - Health check
      - **`service/`** - Lógica de negocio
        - `LoginService.java` - Autenticación + control de intentos
        - `JwtService.java` - Generación/validación JWT
        - `RestartUserPasswordService.java` - Restablecer contraseña (ADMIN)
      - **`component/`** - Componentes reutilizables
        - `LoginComponent.java` - Control de intentos fallidos y bloqueos
        - `SecurityLoginComponent.java` - Encriptación BCrypt + validación
      - **`security/`** - Capa de seguridad
        - `JwtAuthFilter.java` - Filtro de autenticación JWT
        - `UserDetailsServiceImpl.java` - Carga usuarios desde BD
      - **`model/`** - Modelo de datos
        - **`entity/`** - `User.java`, `Role.java`
        - **`enums/`** - `ErrorCode.java`, `LockLevel.java`, `SuccessfulCode.java`
        - **`request/`** - `LoginRequest.java`, `RestartPasswordRequest.java`
        - **`response/`** - `LoginResponse.java`, `ErrorResponse.java`, `SuccessResponse.java`
        - **`dto/`** - `UserPasswordDTO.java`
      - **`repository/`** - `UserRepository.java`
      - **`exception/`** - `AuthenticationException.java`, `GlobalExceptionHandler.java`
    - **`src/main/resources/`**
      - `application.yml` - Configuración (DB, JWT, puerto 7700)
    - **`src/test/java/com/investmenttracker/`** - Pruebas (32 tests)
      - **`controller/`** - `AuthIntegrationTest.java` (26 pruebas de integración)
      - **`service/`** - `LoginServiceTest.java` (6 pruebas unitarias)
  - **`frontend/`** - SPA React 18 (estructura inicial)
    - `package.json` - Dependencias npm
    - `README.md` - Documentación frontend
    - **`src/`**
      - `App.js` - Componente principal
      - **`component/`** - `Dashboard.js`
      - **`services/`** - `api.js` - Configuración Axios
      - **`styles/`** - `global.css` - Estilos globales
  - **`docs/`** - Documentación
    - `README_IdeaICompletaDeArchivos.md` - Idea completa de arquitectura
    - **`prompts/`** - `prompt_inicial.md` - Prompt original
    - **`serverConfig/`** - `popOS22.04.md` - Guía de instalación
    - **`sql/`** - `consultasBasicas.sql` - Consultas de referencia

---

# Investment Tracker Pro - Documentación Completa

## ÍNDICE

- [1. Arquitectura del Sistema](#1-arquitectura-del-sistema)
  - [Diagrama de Arquitectura](#diagrama-de-arquitectura)

  - [Diagrama de Flujo: Login + Restart Password](#diagrama-de-flujo-login--restart-password)

  - [Contenedores Docker](#contenedores-docker)

  - [Diagrama MER (Modelo Entidad-Relación)](#diagrama-mer-modelo-entidad-relación)

  - [Relaciones Clave](#relaciones-clave)

- [2. Base de Datos](#2-base-de-datos)
  - [Funciones PL/pgSQL Disponibles](#funciones-plpgsql-disponibles)

  - [Datos de Prueba](#datos-de-prueba)

- [3. BACKEND - JAVA SPRING BOOT 3.x](#3-backend---api-rest)
  - [Servicios Publicados](#servicios-publicados)

  - [Seguridad](#seguridad)

  - [Pruebas](#pruebas)

- [4. Servicios Docker](#4-servicios-docker)

- [5. Scripts de Mantenimiento](#5-scripts-de-mantenimiento)

- [6. Estructura del Proyecto](#6-estructura-del-proyecto)

- [7. Stack Tecnológico](#7-stack-tecnológico)

- [8. Historial de Versiones](#8-historial-de-versiones)

- [9. Requisitos Funcionales](#9-requisitos-funcionales)

---

## 1. ARQUITECTURA DEL SISTEMA

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                      🌐 CLIENTE (HTTPS)                      │
│                   React SPA + Axios + JWT                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   🔒 NGINX Reverse Proxy                     │
│                      Puerto: 443 (SSL/TLS)                   │
│                  Redirección: / → Frontend                   │
│                              /api → Backend                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
            ┌──────────────┴──────────────┐
            ▼                             ▼
┌───────────────────────┐    ┌────────────────────────────────┐
│   🎨 FRONTEND (3000)   │    │   ⚙️  BACKEND (7700)            │
│   React 18 + CSS       │    │   Spring Boot 3.x + Java 21   │
│   Nginx/Alpine         │    │   Tomcat 10 Embedido           │
│   SPA + React Router   │    │   JWT Authentication           │
└───────────────────────┘    └──────────────┬─────────────────┘
                                            │
                    ┌───────────────────────┴
                    │
                    ▼
┌──────────────────────────────┐    ┌──────────────────────────────┐
│   🗄️  PostgreSQL 16 (5432)    │◄──│   📊 pgAdmin 4 (5050)        │
│   Esquema: investment_tracker│    │   Admin DB Web UI            │
│   PL/pgSQL + UUID + 54 monedas│   │   http://localhost:5050       │
└──────────────────────────────┘    └──────────────────────────────┘
```

### Diagrama de Flujo: Login + Restart Password

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FLUJO DE AUTENTICACIÓN                        │
└─────────────────────────────────────────────────────────────────────┘

👤 Usuario                    🔒 Backend                     🗄️ PostgreSQL
   │                             │                              │
   │  POST /api/auth/login       │                              │
   │  {username, password}       │                              │
   │────────────────────────────>│                              │
   │                             │  Buscar usuario              │
   │                             │─────────────────────────────>│
   │                             │  User (username, hash, roles)│
   │                             │<─────────────────────────────│
   │                             │                              │
   │                             │  Validar:                    │
   │                             │  ┌─ Bloqueo?                 │
   │                             │  ├─ Activo?                  │
   │                             │  ├─ BCrypt.verify()          │
   │                             │  └─ Intentos fallidos        │
   │                             │                              │
   │  JWT + datos usuario       │                              │
   │<────────────────────────────│                              │
   │                             │                              │

👑 ADMIN                     🔒 Backend                     🗄️ PostgreSQL
   │                             │                              │
   │  POST /auth/restart-password│                              │
   │  Header: Bearer <JWT>      │                              │
   │  {username, email, nombre,  │                              │
   │   nuevoPassword, repetir}   │                              │
   │────────────────────────────>│                              │
   │                             │  Validar JWT + ROLE_ADMIN    │
   │                             │  Validar campos + criterios  │
   │                             │  BCrypt.encode(nuevoPassword)│
   │                             │  UPDATE password_hash        │
   │                             │─────────────────────────────>│
   │                             │  OK                          │
   │                             │<─────────────────────────────│
   │                             │  Reset intentos fallidos     │
   │  200 OK                     │                              │
   │<────────────────────────────│                              │
```

### Contenedores Docker

```
┌──────────────────────────────────────────────────────────────┐
│                  DOCKER COMPOSE NETWORK                       │
│                  investment_network (bridge)                  │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │  investment-db    │  │ investment-backend│                │
│  │  postgres:16-alp  │  │ spring-boot:3.x  │                 │
│  │  :5432 → :5432    │◄─┤ :7700 → :7700    │                 │
│  │  volume: data     │  │ JWT + BCrypt     │                 │
│  └──────────────────┘  └──────────────────┘                 │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                 │
│  │ investment-pgadmin│  │ investment-nginx  │                 │
│  │ pgadmin4:latest   │  │ nginx:alpine     │                 │
│  │ :5050 → :80       │  │ :80, :443        │                 │
│  │ volume: pgadmin   │  │ SSL + proxy      │                 │
│  └──────────────────┘  └──────────────────┘                 │
└──────────────────────────────────────────────────────────────┘
```

### Diagrama MER (Modelo Entidad-Relación)

```
┌────────────────────────────────────────────────────────────────────┐
│                    INVESTMENT TRACKER - MER v2.1.0                  │
│                    Todas las PK son UUID v4                         │
└────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐         ┌─────────────────────┐
│      ROLES          │         │      USUARIOS       │
├─────────────────────┤         ├─────────────────────┤
│ 🔑 id        UUID   │         │ 🔑 id        UUID   │
│    nombre    VARCHAR│         │    username  VARCHAR │
│    desc      TEXT   │         │    password  VARCHAR │
│    created_at TIMEST│         │    email     VARCHAR │
└──────────┬──────────┘         │    nombre    VARCHAR │
           │                    │    activo    BOOLEAN │
           │  ┌─────────────────│    ultimo_login TIMEST│
           │  │                 │    created_at TIMEST │
           │  │                 │    updated_at TIMEST │
           │  │                 └──────────────────────┘
           │  │
           │  │                 ┌──────────────────────┐
           │  └─────────────────┤   USUARIO_ROLES      │
           └────────────────────┤   (N:M)              │
                                ├──────────────────────┤
                                │ 🔑 FK usuario_id UUID│
                                │ 🔑 FK rol_id     UUID│
                                │    asignado_en TIMEST │
                                └──────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│                        TABLAS DE NEGOCIO                           │
└────────────────────────────────────────────────────────────────────┘

┌─────────────────────┐         ┌─────────────────────┐
│      MONEDAS        │         │    PLATAFORMAS      │
│  (54 divisas)       │         ├─────────────────────┤
├─────────────────────┤         │ 🔑 id        UUID   │
│ 🔑 id        UUID   │         │    nombre    VARCHAR │
│    codigo    CHAR(3)│         │    desc      TEXT   │
│    nombre    VARCHAR│         │    tipo      VARCHAR │
│    simbolo   VARCHAR│         │    activo    BOOLEAN │
│    pais      VARCHAR│         │    created_at TIMEST │
│    activo    BOOLEAN │         │ 📎 FK usuario UUID  │
│    created_at TIMEST │         │ 📎 FK moneda  UUID  │
└──────────┬──────────┘         └──────────┬───────────┘
           │                               │
           │                    ┌──────────┴───────────┐
           │                    │     COMISIONES       │
           │                    ├──────────────────────┤
           │                    │ 🔑 id        UUID   │
           ├────────────────────│ 📎 FK plataforma UUID│
           │                    │    porcentaje DECIMAL│
           │                    │    valor_fijo DECIMAL│
           │                    │ 📎 FK moneda  UUID   │
           │                    │    desc      VARCHAR │
           │                    │    fecha_inicio TIMEST│
           │                    │    fecha_fin  TIMEST │
           │                    │    activo    BOOLEAN │
           │                    │    created_at TIMEST │
           │                    └──────────────────────┘
           │
           │  ┌──────────────────────────────────────┐
           │  │           TRANSACCIONES              │
           │  ├──────────────────────────────────────┤
           │  │ 🔑 id        UUID                    │
           └──│ 📎 FK usuario UUID                   │
              │ 📎 FK plataforma UUID                │
              │ 📎 FK moneda  UUID                   │
              │    tipo      VARCHAR (COMPRA/VENTA)  │
              │    simbolo   VARCHAR                 │
              │    empresa   VARCHAR                 │
              │    cantidad  INTEGER                 │
              │    precio_uni DECIMAL                │
              │    comision  DECIMAL                 │
              │    valor_total DECIMAL               │
              │    fecha     TIMESTAMP               │
              │    notas     TEXT                    │
              │    created_at TIMESTAMP              │
              └──────────────────────────────────────┘

              ┌──────────────────────────────────────┐
              │         CALCULOS_HIST                │
              ├──────────────────────────────────────┤
              │ 🔑 id        UUID                    │
              │ 📎 FK usuario UUID                   │
              │ 📎 FK plataforma UUID                │
              │    simbolo   VARCHAR                 │
              │    ganancia_deseada DECIMAL          │
              │    precio_minimo DECIMAL             │
              │    cantidad_optima INTEGER           │
              │    comision_estimada DECIMAL         │
              │    ganancia_neta DECIMAL             │
              │    parametros_json JSONB             │
              │    created_at TIMESTAMP              │
              └──────────────────────────────────────┘
```

### Relaciones Clave

| Origen      | Destino       | Tipo | Descripción                                   |
| ----------- | ------------- | ---- | --------------------------------------------- |
| usuarios    | usuario_roles | 1:N  | Un usuario tiene varios roles                 |
| roles       | usuario_roles | 1:N  | Un rol pertenece a varios usuarios            |
| usuarios    | plataformas   | 1:N  | Un usuario registra varias plataformas        |
| monedas     | plataformas   | 1:N  | Una plataforma opera en una moneda            |
| plataformas | comisiones    | 1:N  | Una plataforma tiene estructura de comisiones |
| monedas     | comisiones    | 1:N  | La comisión se cobra en una moneda            |
| usuarios    | transacciones | 1:N  | Un usuario realiza varias transacciones       |
| plataformas | transacciones | 1:N  | Una transacción se ejecuta en una plataforma  |
| monedas     | transacciones | 1:N  | Una transacción se registra en una moneda     |
| usuarios    | calculos_hist | 1:N  | Historial de cálculos por usuario             |

Se incluyen **54 divisas internacionales** organizadas por región: principales (USD, COP, EUR, GBP), Américas (16), Europa (11), Asia-Pacífico (14) y Medio Oriente/África (9). Cada moneda tiene código ISO de 3 letras, nombre, símbolo y país asociado.

### Funciones PL/pgSQL Disponibles

| Función                   | Descripción                                   |
| ------------------------- | --------------------------------------------- |
| `obtener_comision_actual` | Retorna la comisión vigente de una plataforma |
| `calcular_comision`       | Calcula la comisión total para un monto dado  |
| `resumen_inversiones`     | Retorna las posiciones actuales por símbolo   |
| `calcular_venta_optima`   | Calcula precio mínimo para ganancia deseada   |

> Las funciones reciben y retornan UUIDs. Ver `database/sql/02_functions.sql` para detalles de parámetros.

### Datos de Prueba

- **3 usuarios**: demo_user, admin, incognito (con roles USER, ADMIN y PREMIUM)
- **5 plataformas**: eToro, Interactive Brokers, Robinhood, Binance (USD) y Trii (COP)
- **11 transacciones** de ejemplo en USD y COP con fechas en UTC

## 3. BACKEND - JAVA SPRING BOOT 3.x

### Servicios Publicados

| Endpoint                     | Método | Auth  | Descripción                                 |
| ---------------------------- | ------ | ----- | ------------------------------------------- |
| `/api/auth/login`            | POST   | No    | Login - Retorna JWT                         |
| `/api/auth/restart-password` | POST   | ADMIN | Restablecer contraseña de cualquier usuario |
| `/api/test/health`           | GET    | No    | Health check del servicio                   |

### Seguridad

- **JWT** con firma HMAC-SHA384
- **BCrypt** para hash de contraseñas
- **Roles**: ROLE_ADMIN, ROLE_USER, ROLE_PREMIUM
- Control de intentos fallidos: 3 intentos, bloqueo progresivo (5min → 15min → 30min → 1h → 12h → 24h → permanente)
- Validaciones de contraseña: 8+ caracteres, 1 mayúscula, 1 carácter especial, sin comillas
- Validación case-insensitive para email, case-sensitive para contraseñas

### Pruebas

- **32 pruebas automatizadas** (26 integración + 6 unitarias)
- Cobertura: login, restart-password, validaciones de contraseña, control de roles, bloqueos
- Ejecutar: `mvn test`

## 4. Servicios Docker

| Servicio    | Puerto | URL                   |
| ----------- | ------ | --------------------- |
| PostgreSQL  | 5432   | localhost:5432        |
| pgAdmin     | 5050   | http://localhost:5050 |
| Backend     | 8081   | http://localhost:8081 |
| Frontend    | 3000   | http://localhost:3000 |
| Nginx HTTPS | 443    | https://localhost     |

## 5. Scripts de Mantenimiento

### Verificar sistema completo

./docker/shellTest/check-all.sh

### Reset base de datos (mantiene configuración pgadmin)

./docker/shellTest/reset-all.sh

### Reset solo pgadmin

./docker/shellTest/reset-pgadmin.sh

### Backup base de datos

./docker/shellTest/backup-db.sh

### Restaurar backup

./docker/shellTest/restore-db.sh <archivo.sql>
