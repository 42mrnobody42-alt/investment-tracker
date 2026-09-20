# CAP-01 — Crear frontend para login, home, datos del usuario y edición

**Estado:** Ready
**Rama base:** `developer`
**Rama de trabajo:** `feature/CAP-01-frontend-base`

## Objetivo

Implementar el frontend React 18 del sistema Investment Tracker Pro para las
funcionalidades de autenticación, home, consulta y edición de perfil de usuario,
con soporte responsive (PC, tablet, móvil vertical) e i18n (EN/ES).

## Alcance

- Setup React 18 + Vite + TypeScript
- i18n con namespaces por funcionalidad (`en/` y `es/`)
- Diseño responsive (breakpoints 576 / 992 / 1200)
- Componentes base: layout, botones, modales, tablas, gráficos, formularios
- Vistas: Login, Home, Perfil, Edición de perfil, NotFound
- Layout: TopBar + Sidebar plegable + WorkArea

## Árbol de Features / User Stories / Tasks

### FT-001 — Setup e infraestructura base
- **US-001** — Configurar proyecto React 18 con Vite + TypeScript
  - TS-050 — Eliminar carpeta `frontend/` actual (1h)
  - TS-001 — Inicializar proyecto Vite + React 18 + TS (2h)
  - TS-002 — Configurar ESLint, Prettier y tsconfig estricto (2h)
- **US-002** — Definir arquitectura de carpetas y convenciones
  - TS-003 — Crear estructura de carpetas (2h)
  - TS-004 — Documentar convenciones en `frontend/README.md` (1h)
- **US-003** — Configurar i18n (inglés/español)
  - TS-005 — Instalar y configurar `react-i18next` con namespaces (2h)
  - TS-006 — Crear subcarpetas `en/` y `es/` con archivos por funcionalidad (3h)
  - TS-007 — Selector de idioma con persistencia en `localStorage` (2h)
- **US-004** — Configurar sistema responsive y tema visual
  - TS-008 — Definir breakpoints (2h)
  - TS-009 — Implementar `ThemeContext` con CSS variables (3h)
  - TS-010 — Helpers para orientación vertical en móvil (2h)
- **US-005** — Configurar Axios, interceptores y manejo de tokens
  - TS-011 — `apiClient` con base URL desde env (2h)
  - TS-012 — Interceptor de request (adjuntar JWT) (2h)
  - TS-013 — Interceptor de response con refresh automático (4h)
- **US-006** — Configurar enrutamiento y layout raíz
  - TS-014 — React Router v6 con rutas públicas/privadas (3h)
  - TS-015 — `AppLayout` (top bar + sidebar + work area) (4h)

### FT-002 — Librería de componentes base
- **US-007** — Componentes de layout
  - TS-016 — `TopBar` informativa (3h)
  - TS-017 — `Sidebar` plegable con secciones expandibles (4h)
  - TS-018 — `WorkArea` contenedor responsive (2h)
- **US-008** — Botones y controles básicos
  - TS-019 — `Button` con variantes (2h)
  - TS-020 — `Input`, `Select`, `Checkbox` con estados de error (3h)
- **US-009** — Modales y pop-ups
  - TS-021 — `Modal` base con overlay y accesibilidad (4h)
  - TS-022 — `InfoModal`, `WarningModal`, `ErrorModal` (3h)
  - TS-023 — `Toast` para notificaciones (3h)
- **US-010** — Tablas de datos
  - TS-024 — `DataTable` con paginación, orden y filtros (4h)
  - TS-025 — Estado vacío y skeleton loader (2h)
- **US-011** — Espacio de gráficos con ampliación
  - TS-026 — `ChartContainer` con Recharts (3h)
  - TS-027 — `FullscreenChartModal` (3h)
- **US-012** — Formularios y validación
  - TS-028 — React Hook Form + Zod (3h)
  - TS-029 — `FormField` con mensajes de error i18n (2h)

### FT-003 — Módulo de autenticación
- **US-013** — Vista de Login
  - TS-030 — Maquetar `LoginView` responsive (3h)
  - TS-031 — Conectar con `POST /api/auth/login` (3h)
  - TS-032 — Almacenar `token` y `refreshToken` (2h)
- **US-014** — Gestión de sesión y refresh automático
  - TS-033 — `AuthContext` con estado de sesión (3h)
  - TS-034 — `useRefreshToken` con sesión deslizante (3h)
- **US-015** — Logout y cierre de sesión
  - TS-035 — `LogoutButton` → `POST /api/auth/logout` (2h)
  - TS-036 — Limpiar estado y redirigir a login (1h)
- **US-016** — Rutas protegidas y control de roles
  - TS-037 — `ProtectedRoute` y `RoleGuard` (3h)

### FT-004 — Vista Home / Dashboard
- **US-017** — Dashboard inicial
  - TS-038 — Maquetar `HomeView` con widgets resumen (4h)
  - TS-039 — Consumir `GET /api/test/health` (1h)
  - TS-040 — Placeholder de futuros endpoints de negocio (2h)
- **US-018** — Perfil rápido en Home
  - TS-041 — Widget de perfil resumido con `get-my-profile` (3h)

### FT-005 — Gestión de perfil de usuario
- **US-019** — Consulta de perfil
  - TS-042 — Maquetar `ProfileView` (3h)
  - TS-043 — Mostrar datos reales sin ofuscar (1h)
- **US-020** — Edición de perfil
  - TS-044 — Maquetar `EditProfileView` con formulario precargado (3h)
  - TS-045 — Conectar con `POST /api/auth/update-my-profile` (4h)
  - TS-046 — Mapear errores (SYS-* genérico, otros individuales) (3h)
  - TS-047 — Tras UPT-0001, actualizar AuthContext y refetch (3h)
- **US-021** — Eliminación de cuenta (lógica)
  - TS-048 — Modal de confirmación `delete-account` (3h)
  - TS-049 — Limpiar sesión y redirigir tras borrado (2h)

## Criterios de aceptación

- [ ] Login funcional contra `/api/auth/login`
- [ ] Refresh token automático
- [ ] Rutas protegidas por rol
- [ ] Home con perfil resumido
- [ ] Consulta y edición de perfil
- [ ] i18n operativo (EN/ES sin recargar)
- [ ] Responsive verificado en 3 breakpoints
