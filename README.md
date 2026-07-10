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

investment-tracker/
├── docker/
│ ├── docker-compose.yml # Orquestación de servicios
│ ├── Dockerfile.backend # Imagen Spring Boot
│ ├── Dockerfile.frontend # Imagen React
│ ├── nginx/
│ │ └── default.conf # Reverse proxy HTTPS
│ ├── pgadmin/
│ │ └── servers.json # Configuración servidores
│ ├── postgres/
│ │ └── init.sql # Inicialización BD
│ └── shellTest/
│ ├── check-all.sh # Verificación completa
│ ├── reset-all.sh # Reset BD (mantiene pgadmin)
│ ├── reset-pgadmin.sh # Reset solo pgadmin
│ ├── backup-db.sh # Backup BD
│ └── restore-db.sh # Restaurar BD├── database/
├── database/
│ └── sql/
│ ├── 01_schema.sql # Esquema v2.1.0 (UUID + Monedas)
│ ├── 02_functions.sql # Funciones PL/pgSQL v2.0.0
│ └── 03_seed.sql # Datos iniciales v2.1.0├── backend/
│ ├── src/
│ ├── pom.xml
│ └── README.md
├── frontend/
│ ├── src/
│ ├── package.json
│ └── README.md
└── docs/
├── README.md
└── prompts/
└── prompt_inicial.md

#### Estructura detallada de archivos

investment-tracker/
│
├── .vscode/
│ └── settings.json # Configuración de VS Code
│
├── .gitignore # Archivos ignorados por Git
├── README.md # Documentación principal del proyecto
│
├── docker/
│ ├── docker-compose.yml # Orquestación de servicios
│ ├── .env # Variables de entorno Docker
│ ├── Dockerfile.backend # Imagen para Spring Boot
│ ├── Dockerfile.frontend # Imagen para React
│ ├── nginx/
│ │ ├── default.conf # Configuración de Nginx reverse proxy
│ │ ├── nginx-frontend.conf # Configuración Nginx frontend
│ │ └── ssl/
│ │ ├── localhost.crt # Certificado SSL autofirmado
│ │ └── localhost.key # Llave privada SSL
│ ├── pgadmin/
│ │ └── servers.json # Configuración servidores pgAdmin
│ ├── postgres/
│ │ └── init.sql # Script de inicialización de BD
│ └── shellTest/
│ ├── check-all.sh # Verificación completa del sistema
│ ├── reset-all.sh # Reset BD (mantiene pgadmin)
│ ├── reset-pgadmin.sh # Reset solo pgadmin
│ ├── backup-db.sh # Backup de base de datos
│ └── restore-db.sh # Restaurar desde backup
│
├── database/
│ └── sql/
│ ├── 01_schema.sql # Esquema v2.1.0 (UUID + Monedas)
│ ├── 02_functions.sql # Funciones PL/pgSQL v2.0.0
│ └── 03_seed.sql # Datos iniciales v2.1.0
│
├── backend/
│ ├── pom.xml # Dependencias Maven
│ ├── README.md # Documentación del backend
│ └── src/
│ ├── main/
│ │ ├── java/com/investmenttracker/
│ │ │ ├── InvestmentTrackerApplication.java # Clase principal
│ │ │ ├── config/
│ │ │ │ ├── SecurityConfig.java # Configuración Spring Security
│ │ │ │ ├── JwtConfig.java # Configuración JWT
│ │ │ │ ├── CorsConfig.java # Configuración CORS
│ │ │ │ └── SwaggerConfig.java # Documentación API
│ │ │ ├── controller/
│ │ │ │ ├── AuthController.java # Login/Registro
│ │ │ │ ├── UsuarioController.java # CRUD usuarios
│ │ │ │ ├── PlataformaController.java # Gestión plataformas
│ │ │ │ ├── ComisionController.java # Gestión comisiones
│ │ │ │ ├── TransaccionController.java # Compras/Ventas
│ │ │ │ └── CalculadoraController.java # Cálculos óptimos
│ │ │ ├── model/
│ │ │ │ ├── entity/
│ │ │ │ │ ├── Usuario.java
│ │ │ │ │ ├── Rol.java
│ │ │ │ │ ├── Moneda.java
│ │ │ │ │ ├── Plataforma.java
│ │ │ │ │ ├── Comision.java
│ │ │ │ │ ├── Transaccion.java
│ │ │ │ │ └── CalculoHistorico.java
│ │ │ │ └── dto/
│ │ │ │ ├── LoginRequest.java
│ │ │ │ ├── RegisterRequest.java
│ │ │ │ ├── AuthResponse.java
│ │ │ │ ├── TransaccionRequest.java
│ │ │ │ ├── TransaccionDTO.java
│ │ │ │ ├── ResumenInversionesDTO.java
│ │ │ │ ├── CalculoOptimoDTO.java
│ │ │ │ └── ComisionDTO.java
│ │ │ ├── repository/
│ │ │ │ ├── UsuarioRepository.java
│ │ │ │ ├── RolRepository.java
│ │ │ │ ├── MonedaRepository.java
│ │ │ │ ├── PlataformaRepository.java
│ │ │ │ ├── ComisionRepository.java
│ │ │ │ ├── TransaccionRepository.java
│ │ │ │ └── CalculoHistoricoRepository.java
│ │ │ ├── service/
│ │ │ │ ├── AuthService.java
│ │ │ │ ├── JwtService.java
│ │ │ │ ├── UserService.java
│ │ │ │ ├── PlataformaService.java
│ │ │ │ ├── ComisionService.java
│ │ │ │ ├── TransaccionService.java
│ │ │ │ └── CalculadoraVentaService.java
│ │ │ ├── security/
│ │ │ │ ├── JwtAuthFilter.java
│ │ │ │ ├── JwtTokenProvider.java
│ │ │ │ └── UserDetailsServiceImpl.java
│ │ │ └── exception/
│ │ │ ├── GlobalExceptionHandler.java
│ │ │ ├── NoPositionException.java
│ │ │ └── CustomExceptions.java
│ │ └── resources/
│ │ ├── application.yml # Configuración principal
│ │ ├── application-dev.yml # Config desarrollo
│ │ └── application-prod.yml # Config producción
│ └── test/
│ └── java/com/investmenttracker/
│ ├── controller/
│ │ ├── AuthControllerTest.java
│ │ └── TransaccionControllerTest.java
│ ├── service/
│ │ ├── CalculadoraVentaServiceTest.java
│ │ └── TransaccionServiceTest.java
│ └── repository/
│ └── TransaccionRepositoryTest.java
│
├── frontend/
│ ├── package.json # Dependencias npm
│ ├── package-lock.json # Lock file npm
│ ├── README.md # Documentación frontend
│ ├── .env.development # Variables entorno desarrollo
│ ├── .env.production # Variables entorno producción
│ ├── public/
│ │ ├── index.html # HTML principal
│ │ ├── favicon.ico # Favicon
│ │ └── manifest.json # PWA manifest
│ └── src/
│ ├── index.js # Punto de entrada React
│ ├── App.js # Componente principal
│ ├── App.test.js # Tests de App
│ ├── context/
│ │ └── AuthContext.js # Contexto de autenticación
│ ├── hooks/
│ │ ├── useAuth.js # Hook de autenticación
│ │ ├── useTransacciones.js # Hook de transacciones
│ │ └── useCalculadora.js # Hook de calculadora
│ ├── services/
│ │ ├── api.js # Configuración Axios
│ │ ├── authService.js # Servicios auth
│ │ ├── transaccionService.js # Servicios transacciones
│ │ └── calculadoraService.js # Servicios calculadora
│ ├── components/
│ │ ├── common/
│ │ │ ├── Navbar.jsx # Barra de navegación
│ │ │ ├── Sidebar.jsx # Menú lateral
│ │ │ ├── Footer.jsx # Pie de página
│ │ │ ├── LoadingSpinner.jsx # Indicador de carga
│ │ │ ├── ErrorMessage.jsx # Mensaje de error
│ │ │ ├── PrivateRoute.jsx # Ruta protegida
│ │ │ └── Notification.jsx # Notificaciones
│ │ ├── dashboard/
│ │ │ ├── Dashboard.jsx # Panel principal
│ │ │ ├── ResumenInversiones.jsx # Resumen de inversiones
│ │ │ ├── GraficoRendimiento.jsx # Gráficos de rendimiento
│ │ │ ├── UltimasTransacciones.jsx # Últimas transacciones
│ │ │ └── RendimientoPorSimbolo.jsx # Rendimiento por acción
│ │ ├── transacciones/
│ │ │ ├── Transacciones.jsx # Lista de transacciones
│ │ │ ├── TransaccionForm.jsx # Formulario de transacción
│ │ │ ├── TransaccionCard.jsx # Tarjeta de transacción
│ │ │ └── FiltrosTransacciones.jsx # Filtros de búsqueda
│ │ ├── calculadora/
│ │ │ ├── CalculadoraVenta.jsx # Calculadora de venta óptima
│ │ │ ├── ResultadosCalculo.jsx # Resultados del cálculo
│ │ │ └── ConfigCalculadora.jsx # Configuración de cálculo
│ │ ├── plataformas/
│ │ │ ├── Plataformas.jsx # Gestión de plataformas
│ │ │ ├── PlataformaForm.jsx # Formulario de plataforma
│ │ │ └── ComisionesManager.jsx # Gestión de comisiones
│ │ └── auth/
│ │ ├── Login.jsx # Página de login
│ │ ├── Register.jsx # Página de registro
│ │ └── PasswordReset.jsx # Recuperar contraseña
│ ├── pages/
│ │ ├── Home.jsx # Página principal
│ │ ├── Dashboard.jsx # Dashboard completo
│ │ ├── Transacciones.jsx # Página de transacciones
│ │ ├── Calculadora.jsx # Página de calculadora
│ │ ├── Plataformas.jsx # Página de plataformas
│ │ ├── Perfil.jsx # Perfil de usuario
│ │ └── Configuracion.jsx # Configuración
│ ├── styles/
│ │ ├── global.css # Estilos globales
│ │ ├── variables.css # Variables CSS
│ │ ├── animations.css # Animaciones
│ │ ├── components/
│ │ │ ├── navbar.css
│ │ │ ├── dashboard.css
│ │ │ ├── transacciones.css
│ │ │ ├── calculadora.css
│ │ │ └── forms.css
│ │ └── themes/
│ │ ├── light.css # Tema claro
│ │ └── dark.css # Tema oscuro
│ └── utils/
│ ├── formatters.js # Formateo de moneda/fechas
│ ├── validators.js # Validaciones
│ └── constants.js # Constantes
│
└── docs/
├── README.md # Documentación del proyecto
├── CHANGELOG.md # Historial de cambios
├── CONTRIBUTING.md # Guía de contribución
├── prompts/
│ ├── prompt_inicial.md # Prompt original
│ ├── prompt_mejoras.md # Mejoras solicitadas
│ └── prompt_historial.md # Historial de cambios
├── diagrams/
│ ├── architecture.png # Diagrama de arquitectura
│ ├── data-flow.png # Diagrama de flujo de datos
│ ├── sequence/
│ │ ├── login-sequence.png # Secuencia de login
│ │ └── calculo-sequence.png # Secuencia de cálculo
│ └── components/
│ └── component-tree.png # Árbol de componentes
└── guides/
├── installation.md # Guía de instalación
├── deployment.md # Guía de despliegue
├── development.md # Guía de desarrollo
├── testing.md # Guía de pruebas
└── security.md # Guía de seguridad

# Investment Tracker Pro - Documentación Completa

## ÍNDICE

1. [Arquitectura del Sistema](#1-arquitectura-del-sistema)
2. [Modelo Entidad-Relación (MER)](#2-modelo-entidad-relación)
3. [Configuración del Entorno de Desarrollo](#3-configuración-del-entorno)
4. [Base de Datos](#4-base-de-datos)
5. [Backend (Java Spring Boot)](#5-backend)
6. [Frontend (React)](#6-frontend)
7. [Seguridad JWT y HTTPS](#7-seguridad)
8. [🐳 Servicios Docker](#8-🐳-Servicios-Docker)
9. [🔧 Scripts de Mantenimiento](#9-🔧-Scripts-de-Mantenimiento)
10. [Calculadora de Venta Óptima](#10-calculadora)
11. [Pruebas y Debugging](#11-pruebas)

---

## 1. ARQUITECTURA DEL SISTEMA

### Diagrama de Arquitectura

┌───────────────────────────────────────┐
│ CLIENTE (HTTPS) │
└────────┬──────────────────────────────┘
│
┌────────▼─────────┐
│ NGINX (443) │ ← SSL/TLS
│ Reverse Proxy │
└────────┬─────────┘
│
┌────────▼─────────┐
│ React App │ ← Frontend (SPA)
│ (Nginx/Alpine) │
└────────┬─────────┘
│ HTTP/2
┌────────▼──────────────┐
│ Spring Boot 3.x │ ← Backend API REST
│ (Tomcat Embedido) │ JWT Authentication
│ Java 21 LTS │
└────────┬──────────────┘
│ JDBC
┌────────▼─────────┐
│ PostgreSQL 16 │ ← Base de Datos
│ + PL/SQL │
└──────────────────┘

### Contenedores Docker

┌─────────────────────────────────────┐
│ DOCKER COMPOSE NETWORK │
│ ┌──────────┐ ┌──────────┐ │
│ │ POSTGRES │ │ BACKEND │ │
│ │ :5432 │◄─┤ :8080 │ │
│ └──────────┘ └─────┬────┘ │
│ │ │
│ ┌──────▼──────┐ │
│ │ FRONTEND │ │
│ │ :3000 │ │
│ └─────────────┘ │
└─────────────────────────────────────┘

## 2. MODELO ENTIDAD-RELACIÓN (MER)

### Diagrama MER

──────────────┐ ┌──────────────┐
│ USUARIOS │ │ ROLES │
├──────────────┤ ├──────────────┤
│ PK id (UUID) │──┐ │ PK id (UUID) │
│ username │ │ │ nombre │
│ password │ │ │ desc │
│ email │ │ └──────────────┘
│ created_at│ │ ▲
└──────────────┘ │ │
│ │ ┌──────┴──────┐
│ └────┤USUARIO_ROLES│
│ ├──────────────┤
│ │ FK usuario_id│
│ │ FK rol_id │
│ └──────────────┘
│
│ ┌──────────────┐ ┌──────────────┐
├──┤ PLATAFORMAS │ │ MONEDAS │
│ ├──────────────┤ ├──────────────┤
│ │ PK id (UUID) │ │ PK id (UUID) │
│ │ nombre │ ┌──│ codigo │
│ │ desc │ │ │ nombre │
│ │ FK usuario_id│ │ │ simbolo │
│ │ FK moneda_id │───┘ │ pais │
│ └──────┬───────┘ └──────────────┘
│ │
│ ┌──────▼──────────┐
│ │ COMISIONES │
│ ├─────────────────┤
│ │ PK id (UUID) │
│ │ porcentaje │
│ │ valor_fijo │
│ │ FK moneda_id │───┐
│ │ fecha_inicio │ │
│ │ fecha_fin │ │
│ │ FK plataforma_id│ │
│ └─────────────────┘ │
│ │
│ ┌──────────────┐ │
├──┤ TRANSACCIONES│ │
│ ├──────────────┤ │
│ │ PK id (UUID) │ │
│ │ tipo │ │
│ │ simbolo │ │
│ │ cantidad │ │
│ │ precio_uni│ │
│ │ comision │ │
│ │ total │ │
│ │ fecha │ │
│ │ FK usuario_id│ │
│ │ FK plataforma│ │
│ │ FK moneda_id │──────┘
│ └──────────────┘
│
│ ┌──────────────┐
└──┤ CALCULOS_HIST│
├──────────────┤
│ PK id (UUID) │
│ precio_min│
│ cant_opt │
│ ganancia │
│ created_at│
│ FK usuario_id│
└──────────────┘

## 3. CONFIGURACIÓN DEL ENTORNO DE DESARROLLO (Pop OS)

### 3.1 Instalación de Dependencias

Ejecutar el paso a paso del documento docs/serverConfig/popOS22.04.md

Docker version 29.5.2, build 79eb04c
docker-compose version 1.29.2, build unknown

openjdk 21.0.11 2026-04-21
OpenJDK Runtime Environment (build 21.0.11+10-1-22.04.2-Ubuntu)
OpenJDK 64-Bit Server VM (build 21.0.11+10-1-22.04.2-Ubuntu, mixed mode, sharing)

node --version && npm --version
v20.20.2
10.8.2

Apache Maven 3.6.3
Maven home: /usr/share/maven
Java version: 21.0.11, vendor: Ubuntu, runtime: /usr/lib/jvm/java-21-openjdk-amd64
Default locale: es_CO, platform encoding: UTF-8
OS name: "linux", version: "6.17.9-76061709-generic", arch: "amd64", family: "unix"

code --install-extension vscjava.vscode-java-pack
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-ossdata.vscode-postgresql
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode

### 3.2 Configurar VS Code para Desarrollo

Abre tu proyecto en VS Code.
Crea una carpeta llamada .vscode en la raíz del proyecto si no existe.
Dentro de esa carpeta, crea un archivo llamado settings.json.
Copia y pega el contenido:
{
"java.configuration.updateBuildConfiguration": "automatic",
"java.compile.nullAnalysis.mode": "automatic",
"editor.formatOnSave": true,
"editor.codeActionsOnSave": {
"source.organizeImports": "explicit"
}
}

## 4. BASE DE DATOS

### Tablas del Sistema (v2.1.0)

| #   | Tabla            | Descripción                                | PK                    |
| --- | ---------------- | ------------------------------------------ | --------------------- |
| 1   | `schema_version` | Control de versiones de scripts ejecutados | UUID                  |
| 2   | `roles`          | Roles del sistema (ADMIN, USER, PREMIUM)   | UUID                  |
| 3   | `usuarios`       | Usuarios registrados en el sistema         | UUID                  |
| 4   | `usuario_roles`  | Relación muchos a muchos usuarios-roles    | Compuesta (UUID+UUID) |
| 5   | `monedas`        | Catálogo de divisas internacionales        | UUID                  |
| 6   | `plataformas`    | Plataformas de inversión por usuario       | UUID                  |
| 7   | `comisiones`     | Estructura de comisiones por plataforma    | UUID                  |
| 8   | `transacciones`  | Registro de compras y ventas de acciones   | UUID                  |
| 9   | `calculos_hist`  | Historial de cálculos de venta óptima      | UUID                  |

### Catálogo de Monedas

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

## 5. BACKEND - JAVA SPRING BOOT 3.x

### 5.1 Estructura del Proyecto Spring Boot

### 5.1 Estructura del Proyecto Spring Boot

backend/src/main/java/com/investmenttracker/InvestmentTrackerApplication.java
backend/src/main/java/com/investmenttracker/config/SecurityConfig.java

### 5.2 Controladores REST Clave

backend/src/main/java/com/investmenttracker/controller/AuthController.java
backend/src/main/java/com/investmenttracker/controller/TransaccionController.java

### 5.3 Configuración application.yml

backend/src/main/java/com/investmenttracker/resources/application.yml

## 🐳 Servicios Docker

| Servicio    | Puerto | URL                   |
| ----------- | ------ | --------------------- |
| PostgreSQL  | 5432   | localhost:5432        |
| pgAdmin     | 5050   | http://localhost:5050 |
| Backend     | 8081   | http://localhost:8081 |
| Frontend    | 3000   | http://localhost:3000 |
| Nginx HTTPS | 443    | https://localhost     |

## 🔧 Scripts de Mantenimiento

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
