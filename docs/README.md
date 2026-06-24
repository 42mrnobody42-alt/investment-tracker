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
investment-tracker/
├── docker/
│ ├── docker-compose.yml
│ ├── postgres/
│ │ └── init.sql
│ └── Dockerfile.backend
├── database/
│ ├── sql/
│ │ ├── 01_schema.sql
│ │ ├── 02_functions.sql
│ │ ├── 03_procedures.sql
│ │ └── 04_seed.sql
│ └── MER/
│ └── diagram.md
├── backend/
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



# Investment Tracker Pro - Documentación Completa

## ÍNDICE
1. [Arquitectura del Sistema](#1-arquitectura-del-sistema)
2. [Modelo Entidad-Relación (MER)](#2-modelo-entidad-relación)
3. [Configuración del Entorno de Desarrollo](#3-configuración-del-entorno)
4. [Base de Datos](#4-base-de-datos)
5. [Backend (Java Spring Boot)](#5-backend)
6. [Frontend (React)](#6-frontend)
7. [Seguridad JWT y HTTPS](#7-seguridad)
8. [Despliegue con Docker](#8-despliegue)
9. [Calculadora de Venta Óptima](#9-calculadora)
10. [Pruebas y Debugging](#10-pruebas)

---

## 1. ARQUITECTURA DEL SISTEMA

### Diagrama de Arquitectura
┌───────────────────────────────────────┐
│ CLIENTE (HTTPS)                       │
└────────┬──────────────────────────────┘
         │
┌────────▼─────────┐
│ NGINX (443)      │ ← SSL/TLS
│ Reverse Proxy    │
└────────┬─────────┘
         │
┌────────▼─────────┐
│ React App        │ ← Frontend (SPA)
│ (Nginx/Alpine)   │
└────────┬─────────┘
         │ HTTP/2
┌────────▼──────────────┐
│ Spring Boot 3.x       │ ← Backend API REST
│ (Tomcat Embedido)     │ JWT Authentication
│ Java 21 LTS           │
└────────┬──────────────┘
         │ JDBC
┌────────▼─────────┐
│ PostgreSQL 16    │ ← Base de Datos
│ + PL/SQL         │
└──────────────────┘



### Contenedores Docker
┌─────────────────────────────────────┐
│ DOCKER COMPOSE NETWORK              │
│ ┌──────────┐  ┌──────────┐          │
│ │ POSTGRES │  │ BACKEND  │          │
│ │ :5432    │◄─┤ :8080    │          │
│ └──────────┘  └─────┬────┘          │
│                     │               │
│ ┌──────▼──────┐                     │
│ │ FRONTEND    │                     │
│ │ :3000       │                     │
│ └─────────────┘                     │
└─────────────────────────────────────┘



## 2. MODELO ENTIDAD-RELACIÓN (MER)

### Diagrama MER
┌──────────────┐ ┌──────────────┐
│ USUARIOS     │ │ ROLES        │
├──────────────┤ ├──────────────┤
│ PK id        │──┐ │ PK id │
│ username     │ │ │ nombre │
│ password     │ │ │ desc │
│ email        │ │ └──────────────┘
│ created_at   │ │ ▲
└──────────────┘ │ │
│ │ ┌──────┴──────┐
│ └────┤USUARIO_ROLES│
│ ├──────────────┤
│ │ FK usuario_id│
│ │ FK rol_id │
│ └──────────────┘
│
│ ┌──────────────┐
├──┤ PLATAFORMAS │
│ ├──────────────┤
│ │ PK id │
│ │ nombre │
│ │ desc │
│ │ FK usuario_id│
│ └──────┬───────┘
│ │
│ ┌──────▼──────────┐
│ │ COMISIONES │
│ ├─────────────────┤
│ │ PK id │
│ │ porcentaje │
│ │ valor_fijo │
│ │ fecha_inicio │
│ │ fecha_fin │
│ │ FK plataforma_id│
│ └─────────────────┘
│
│ ┌──────────────┐
├──┤ TRANSACCIONES│
│ ├──────────────┤
│ │ PK id │
│ │ tipo │ ← COMPRA/VENTA
│ │ simbolo │ ← AAPL, TSLA...
│ │ cantidad │
│ │ precio_uni│
│ │ comision │
│ │ total │
│ │ fecha │
│ │ FK usuario_id│
│ │ FK plataforma│
│ └──────────────┘
│
│ ┌──────────────┐
└──┤ CALCULOS_HIST│
├──────────────┤
│ PK id │
│ precio_min│
│ cant_opt │
│ ganancia │
│ created_at│
│ FK usuario_id│
└──────────────┘


