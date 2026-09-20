#!/usr/bin/env bash
# =========================================================
# create-cap01.sh — Crea CAP-01 + FT + US + TS en GitHub
# =========================================================
set -euo pipefail

REPO="42mrnobody42-alt/investment-tracker"
PROJECT_OWNER="42mrnobody42-alt"
PROJECT_NUMBER=2
KANBAN_DIR="/prog/datos/investment-tracker/docs/scrum/kanban"

echo "══════════════════════════════════════════════════════"
echo "  Creando CAP-01 en $REPO"
echo "══════════════════════════════════════════════════════"

# ---------------------------------------------------------
# 1) LABELS
# ---------------------------------------------------------
echo "==> [1/7] Creando labels..."
gh label create "capability"  --repo "$REPO" --color "6f42c1" --description "Capability del proyecto" --force
gh label create "feature"     --repo "$REPO" --color "0e8a16" --description "Feature dentro de una capability" --force
gh label create "user-story"  --repo "$REPO" --color "1d76db" --description "User Story dentro de una feature" --force
gh label create "task"        --repo "$REPO" --color "fbca04" --description "Tarea técnica (<=4h)" --force
gh label create "frontend"    --repo "$REPO" --color "5319e7" --description "Relacionado con frontend React" --force
gh label create "i18n"        --repo "$REPO" --color "c5def5" --description "Internacionalización" --force
gh label create "responsive"  --repo "$REPO" --color "bfd4f2" --description "Diseño responsive" --force

# ---------------------------------------------------------
# 2) CAPABILITY
# ---------------------------------------------------------
echo "==> [2/7] Creando Capability CAP-01..."
CAP=$(gh issue create --repo "$REPO" \
  --title "CAP-01 — Crear frontend para login, home, datos del usuario y edición" \
  --label "capability,frontend" \
  --body "$(cat <<'BODY'
## Objetivo
Implementar el frontend React 18 del sistema para autenticación, home, consulta y edición de perfil de usuario.

## Alcance
- Setup React 18 + Vite + TypeScript
- i18n (EN/ES) con namespaces por funcionalidad
- Diseño responsive (PC, tablet, móvil vertical)
- Componentes base: botones, modales, tablas, gráficos, formularios
- Vistas: Login, Home, Perfil, Edición de perfil
- Layout: top bar + sidebar plegable + work area

## Features
- FT-001 — Setup e infraestructura base
- FT-002 — Librería de componentes base
- FT-003 — Módulo de autenticación
- FT-004 — Vista Home / Dashboard
- FT-005 — Gestión de perfil de usuario

## Criterios de aceptación
- [ ] Login funcional contra /api/auth/login
- [ ] Refresh token automático
- [ ] Rutas protegidas por rol
- [ ] Home con perfil resumido
- [ ] Consulta y edición de perfil
- [ ] i18n operativo (EN/ES sin recargar)
- [ ] Responsive en 3 breakpoints

**Rama base:** developer
**Rama de trabajo:** feature/CAP-01-frontend-base
BODY
)" | grep -oE '[0-9]+$')
echo "   CAP-01 = #$CAP"

# ---------------------------------------------------------
# 3) FEATURES
# ---------------------------------------------------------
echo "==> [3/7] Creando Features..."

FT001=$(gh issue create --repo "$REPO" \
  --title "FT-001 — Setup e infraestructura base del frontend" \
  --label "feature,frontend" \
  --body "Configuración inicial: Vite + React 18 + TS, estructura de carpetas, i18n, sistema responsive, Axios con interceptores y enrutamiento base.

## User Stories
- US-001 — Configurar proyecto React 18 con Vite + TypeScript
- US-002 — Definir arquitectura de carpetas y convenciones
- US-003 — Configurar i18n (inglés/español)
- US-004 — Configurar sistema responsive y tema visual
- US-005 — Configurar Axios, interceptores y manejo de tokens
- US-006 — Configurar enrutamiento y layout raíz

## Dependencias
Ninguna. Base para las demás features." | grep -oE '[0-9]+$')

FT002=$(gh issue create --repo "$REPO" \
  --title "FT-002 — Librería de componentes base reutilizables" \
  --label "feature,frontend" \
  --body "Componentes UI reutilizables: layout, botones, inputs, modales, toasts, tablas, gráficos y formularios validados.

## User Stories
- US-007 — Componentes de layout
- US-008 — Botones y controles básicos
- US-009 — Modales y pop-ups
- US-010 — Tablas de datos
- US-011 — Espacio de gráficos con ampliación
- US-012 — Formularios y validación

## Dependencias
FT-001." | grep -oE '[0-9]+$')

FT003=$(gh issue create --repo "$REPO" \
  --title "FT-003 — Módulo de autenticación (login / logout / sesión)" \
  --label "feature,frontend" \
  --body "Vista de Login, gestión de sesión con JWT + Refresh Token, logout y rutas protegidas por rol.

## User Stories
- US-013 — Vista de Login
- US-014 — Gestión de sesión y refresh automático
- US-015 — Logout y cierre de sesión
- US-016 — Rutas protegidas y control de roles

## Dependencias
FT-001, FT-002." | grep -oE '[0-9]+$')

FT004=$(gh issue create --repo "$REPO" \
  --title "FT-004 — Vista Home / Dashboard" \
  --label "feature,frontend" \
  --body "Home con widgets de resumen, estado del sistema y perfil rápido. Placeholders para futuros endpoints de negocio.

## User Stories
- US-017 — Dashboard inicial
- US-018 — Perfil rápido en Home

## Dependencias
FT-002, FT-003." | grep -oE '[0-9]+$')

FT005=$(gh issue create --repo "$REPO" \
  --title "FT-005 — Gestión de perfil de usuario" \
  --label "feature,frontend" \
  --body "Consulta y edición del perfil del usuario autenticado, incluyendo borrado lógico de cuenta.

## User Stories
- US-019 — Consulta de perfil
- US-020 — Edición de perfil
- US-021 — Eliminación de cuenta (lógica)

## Dependencias
FT-002, FT-003." | grep -oE '[0-9]+$')

echo "   FT-001=#$FT001 FT-002=#$FT002 FT-003=#$FT003 FT-004=#$FT004 FT-005=#$FT005"

# ---------------------------------------------------------
# 4) USER STORIES
# ---------------------------------------------------------
echo "==> [4/7] Creando User Stories..."

US001=$(gh issue create --repo "$REPO" \
  --title "US-001 — Configurar proyecto React 18 con Vite + TypeScript" \
  --label "user-story,frontend" \
  --body "Eliminar frontend actual e inicializar proyecto desde cero con Vite + React 18 + TS, ESLint y Prettier.

## Tareas
- TS-050: Eliminar carpeta frontend/ actual (1h)
- TS-001: Inicializar proyecto Vite + React 18 + TS (2h)
- TS-002: Configurar ESLint, Prettier y tsconfig estricto (2h)

## Criterios de aceptación
- [ ] npm run dev levanta sin errores
- [ ] npm run build sin warnings
- [ ] ESLint y Prettier pasan limpios" | grep -oE '[0-9]+$')

US002=$(gh issue create --repo "$REPO" \
  --title "US-002 — Definir arquitectura de carpetas y convenciones" \
  --label "user-story,frontend" \
  --body "Estructura de carpetas del frontend y documentación de convenciones.

## Tareas
- TS-003: Crear estructura de carpetas (2h)
- TS-004: Documentar convenciones en frontend/README.md (1h)" | grep -oE '[0-9]+$')

US003=$(gh issue create --repo "$REPO" \
  --title "US-003 — Configurar i18n (inglés/español)" \
  --label "user-story,frontend,i18n" \
  --body "Integrar react-i18next con namespaces por funcionalidad y persistencia de idioma.

## Estructura
src/i18n/
├── config.ts
├── en/{comun,seguridad,login,usuarioPerfiles,negocio}.json
└── es/{comun,seguridad,login,usuarioPerfiles,negocio}.json

## Tareas
- TS-005: Instalar y configurar react-i18next con namespaces (2h)
- TS-006: Crear subcarpetas en/ y es/ con un archivo por funcionalidad (3h)
- TS-007: Selector de idioma con persistencia (2h)

## Criterios de aceptación
- [ ] Cambio EN/ES sin recargar
- [ ] Idioma persiste en localStorage
- [ ] Cada vista consume su namespace
- [ ] comun.json incluye error.sysGenerico" | grep -oE '[0-9]+$')

US004=$(gh issue create --repo "$REPO" \
  --title "US-004 — Configurar sistema responsive y tema visual" \
  --label "user-story,frontend,responsive" \
  --body "Breakpoints, tema visual con CSS variables y helpers para orientación vertical en móvil.

## Tareas
- TS-008: Definir breakpoints (2h)
- TS-009: ThemeContext con CSS variables (3h)
- TS-010: Helpers para orientación vertical en móvil (2h)" | grep -oE '[0-9]+$')

US005=$(gh issue create --repo "$REPO" \
  --title "US-005 — Configurar Axios, interceptores y manejo de tokens" \
  --label "user-story,frontend" \
  --body "Axios con interceptores para adjuntar JWT y refrescar token automáticamente.

## Tareas
- TS-011: apiClient con base URL desde env (2h)
- TS-012: Interceptor de request (2h)
- TS-013: Interceptor de response con refresh automático (4h)" | grep -oE '[0-9]+$')

US006=$(gh issue create --repo "$REPO" \
  --title "US-006 — Configurar enrutamiento y layout raíz" \
  --label "user-story,frontend" \
  --body "React Router v6 con rutas públicas/privadas y layout raíz con top bar + sidebar + work area.

## Tareas
- TS-014: React Router v6 (3h)
- TS-015: AppLayout con top bar + sidebar plegable + work area (4h)" | grep -oE '[0-9]+$')

US007=$(gh issue create --repo "$REPO" \
  --title "US-007 — Componentes de layout" \
  --label "user-story,frontend" \
  --body "Componentes de estructura: TopBar, Sidebar plegable, WorkArea.

## Tareas
- TS-016: TopBar informativa (3h)
- TS-017: Sidebar plegable (4h)
- TS-018: WorkArea contenedor (2h)" | grep -oE '[0-9]+$')

US008=$(gh issue create --repo "$REPO" \
  --title "US-008 — Botones y controles básicos" \
  --label "user-story,frontend" \
  --body "Botones con variantes y controles de formulario con estados de error.

## Tareas
- TS-019: Button con variantes (2h)
- TS-020: Input, Select, Checkbox (3h)" | grep -oE '[0-9]+$')

US009=$(gh issue create --repo "$REPO" \
  --title "US-009 — Modales y pop-ups" \
  --label "user-story,frontend" \
  --body "Modal base, modales específicos y sistema de toasts.

## Tareas
- TS-021: Modal base con overlay y accesibilidad (4h)
- TS-022: InfoModal, WarningModal, ErrorModal (3h)
- TS-023: Toast para notificaciones (3h)" | grep -oE '[0-9]+$')

US010=$(gh issue create --repo "$REPO" \
  --title "US-010 — Tablas de datos" \
  --label "user-story,frontend" \
  --body "DataTable con paginación, ordenamiento, filtros y estados de carga.

## Tareas
- TS-024: DataTable (4h)
- TS-025: Estado vacío y skeleton loader (2h)" | grep -oE '[0-9]+$')

US011=$(gh issue create --repo "$REPO" \
  --title "US-011 — Espacio de gráficos con ampliación" \
  --label "user-story,frontend" \
  --body "Contenedor responsive de gráficos e implementación de modal de pantalla completa.

## Tareas
- TS-026: ChartContainer con Recharts (3h)
- TS-027: FullscreenChartModal (3h)" | grep -oE '[0-9]+$')

US012=$(gh issue create --repo "$REPO" \
  --title "US-012 — Formularios y validación" \
  --label "user-story,frontend" \
  --body "Integración de React Hook Form + Zod y componente FormField.

## Tareas
- TS-028: React Hook Form + Zod (3h)
- TS-029: FormField con errores i18n (2h)" | grep -oE '[0-9]+$')

US013=$(gh issue create --repo "$REPO" \
  --title "US-013 — Vista de Login" \
  --label "user-story,frontend" \
  --body "Maquetar LoginView responsive y conectar con POST /api/auth/login.

## Tareas
- TS-030: Maquetar LoginView (3h)
- TS-031: Conectar con POST /api/auth/login (3h)
- TS-032: Almacenar token y refreshToken (2h)" | grep -oE '[0-9]+$')

US014=$(gh issue create --repo "$REPO" \
  --title "US-014 — Gestión de sesión y refresh automático" \
  --label "user-story,frontend" \
  --body "AuthContext con estado de sesión y hook para refresh automático.

## Tareas
- TS-033: AuthContext (3h)
- TS-034: useRefreshToken hook (3h)" | grep -oE '[0-9]+$')

US015=$(gh issue create --repo "$REPO" \
  --title "US-015 — Logout y cierre de sesión" \
  --label "user-story,frontend" \
  --body "Botón de logout que llama al endpoint y limpia estado.

## Tareas
- TS-035: LogoutButton (2h)
- TS-036: Limpiar estado y redirigir (1h)" | grep -oE '[0-9]+$')

US016=$(gh issue create --repo "$REPO" \
  --title "US-016 — Rutas protegidas y control de roles" \
  --label "user-story,frontend" \
  --body "ProtectedRoute y RoleGuard (ADMIN, USER, PREMIUM).

## Tareas
- TS-037: ProtectedRoute y RoleGuard (3h)" | grep -oE '[0-9]+$')

US017=$(gh issue create --repo "$REPO" \
  --title "US-017 — Dashboard inicial" \
  --label "user-story,frontend" \
  --body "HomeView con widgets resumen, health check y placeholders para negocio.

## Tareas
- TS-038: Maquetar HomeView (4h)
- TS-039: Consumir GET /api/test/health (1h)
- TS-040: Placeholder dashboard/resumen (2h)" | grep -oE '[0-9]+$')

US018=$(gh issue create --repo "$REPO" \
  --title "US-018 — Perfil rápido en Home" \
  --label "user-story,frontend" \
  --body "Widget de perfil resumido en Home usando get-my-profile.

## Tareas
- TS-041: Widget de perfil resumido (3h)" | grep -oE '[0-9]+$')

US019=$(gh issue create --repo "$REPO" \
  --title "US-019 — Consulta de perfil" \
  --label "user-story,frontend" \
  --body "ProfileView que consume GET /api/auth/get-my-profile (datos reales sin ofuscar, endpoint en OWN_DATA_PATHS).

## Tareas
- TS-042: Maquetar ProfileView (3h)
- TS-043: Mostrar datos reales sin ofuscar (1h)" | grep -oE '[0-9]+$')

US020=$(gh issue create --repo "$REPO" \
  --title "US-020 — Edición de perfil" \
  --label "user-story,frontend" \
  --body "Formulario de edición de perfil contra POST /api/auth/update-my-profile.

## Reglas de manejo de error
- SYS-* → mensaje genérico: 'Contacte al administrador del sistema.!!!'
- REG-002, REG-003, REG-007, AUTH-007 → mensajes específicos

## Tareas
- TS-044: Maquetar EditProfileView (3h)
- TS-045: Conectar update-my-profile (4h)
- TS-046: Mapear errores (SYS-* genérico) (3h)
- TS-047: Tras UPT-0001, actualizar AuthContext y refetch (3h)" | grep -oE '[0-9]+$')

US021=$(gh issue create --repo "$REPO" \
  --title "US-021 — Eliminación de cuenta (lógica)" \
  --label "user-story,frontend" \
  --body "Modal de confirmación y llamada a POST /api/auth/delete-account.

## Tareas
- TS-048: Modal de confirmación (3h)
- TS-049: Limpiar sesión y redirigir (2h)" | grep -oE '[0-9]+$')

echo "   US creadas: 001..021"

# ---------------------------------------------------------
# 5) TASKS
# ---------------------------------------------------------
echo "==> [5/7] Creando Tasks..."

create_task() {
  local title="$1"; local us="$2"; local hours="$3"; local desc="$4"
  gh issue create --repo "$REPO" \
    --title "$title" \
    --label "task,frontend" \
    --body "$(printf '## Descripción\n%s\n\n## Estimación\n%s\n\n## US padre\nUS-%s' "$desc" "$hours" "$us")" \
    | grep -oE '[0-9]+$'
}

# --- US-001
TS050=$(create_task "TS-050 — Eliminar carpeta frontend/ actual" "001 (#$US001)" "1h" "Eliminar /prog/datos/investment-tracker/frontend completo. Verificar Dockerfile.frontend y docker-compose.yml.")
TS001=$(create_task "TS-001 — Inicializar proyecto Vite + React 18 + TS" "001 (#$US001)" "2h" "npm create vite@latest frontend -- --template react-ts. Verificar npm run dev.")
TS002=$(create_task "TS-002 — Configurar ESLint, Prettier y tsconfig estricto" "001 (#$US001)" "2h" "ESLint + Prettier + tsconfig en modo estricto.")
# --- US-002
TS003=$(create_task "TS-003 — Crear estructura de carpetas" "002 (#$US002)" "2h" "components/, views/, services/, hooks/, contexts/, i18n/, styles/, types/, utils/")
TS004=$(create_task "TS-004 — Documentar convenciones en frontend/README.md" "002 (#$US002)" "1h" "Convenciones de nombres, imports alias @, i18n por namespace.")
# --- US-003
TS005=$(create_task "TS-005 — Instalar y configurar react-i18next con namespaces" "003 (#$US003)" "2h" "react-i18next + i18next + LanguageDetector, defaultNS=comun.")
TS006=$(create_task "TS-006 — Crear en/ y es/ con archivos por funcionalidad" "003 (#$US003)" "3h" "Subcarpetas en/ y es/ con comun.json, seguridad.json, login.json, usuarioPerfiles.json, negocio.json. comun.json DEBE incluir error.sysGenerico = 'Contacte al administrador del sistema.!!!'")
TS007=$(create_task "TS-007 — Selector de idioma con persistencia" "003 (#$US003)" "2h" "Selector en TopBar, persistencia en localStorage (clave i18nextLng).")
# --- US-004
TS008=$(create_task "TS-008 — Definir breakpoints" "004 (#$US004)" "2h" "mobile<=576, tablet<=992, desktop>=1200. Archivo styles/breakpoints.ts.")
TS009=$(create_task "TS-009 — ThemeContext con CSS variables" "004 (#$US004)" "3h" "Modo claro/oscuro con CSS variables y persistencia.")
TS010=$(create_task "TS-010 — Helpers para orientación vertical en móvil" "004 (#$US004)" "2h" "mediaQuery.mobilePortrait y mobileLandscape.")
# --- US-005
TS011=$(create_task "TS-011 — apiClient con base URL desde env" "005 (#$US005)" "2h" "services/apiClient.ts con VITE_API_BASE_URL.")
TS012=$(create_task "TS-012 — Interceptor de request (adjuntar JWT)" "005 (#$US005)" "2h" "Lee token de tokenStorage y adjunta Authorization Bearer.")
TS013=$(create_task "TS-013 — Interceptor de response con refresh automático" "005 (#$US005)" "4h" "Ante 401, llamar refresh-token y reintentar. Si falla, limpiar sesión y redirigir.")
# --- US-006
TS014=$(create_task "TS-014 — React Router v6" "006 (#$US006)" "3h" "Rutas públicas y privadas con Outlet.")
TS015=$(create_task "TS-015 — AppLayout (top bar + sidebar + work area)" "006 (#$US006)" "4h" "Layout con TopBar, Sidebar plegable y WorkArea.")
# --- US-007
TS016=$(create_task "TS-016 — TopBar informativa" "007 (#$US007)" "3h" "Usuario, selector de idioma, logout.")
TS017=$(create_task "TS-017 — Sidebar plegable" "007 (#$US007)" "4h" "Secciones expandibles, botón de colapso.")
TS018=$(create_task "TS-018 — WorkArea contenedor responsive" "007 (#$US007)" "2h" "Área de trabajo flexible.")
# --- US-008
TS019=$(create_task "TS-019 — Button con variantes" "008 (#$US008)" "2h" "primary, secondary, danger, ghost.")
TS020=$(create_task "TS-020 — Input, Select, Checkbox" "008 (#$US008)" "3h" "Con estado de error y label.")
# --- US-009
TS021=$(create_task "TS-021 — Modal base con overlay y accesibilidad" "009 (#$US009)" "4h" "Overlay, cierre con Escape, focus trap.")
TS022=$(create_task "TS-022 — InfoModal, WarningModal, ErrorModal" "009 (#$US009)" "3h" "Variantes con íconos y colores.")
TS023=$(create_task "TS-023 — Toast para notificaciones" "009 (#$US009)" "3h" "ToastProvider + ToastHost, auto-cierre 4s.")
# --- US-010
TS024=$(create_task "TS-024 — DataTable" "010 (#$US010)" "4h" "Paginación, orden, filtros, columna render custom.")
TS025=$(create_task "TS-025 — Estado vacío y skeleton loader" "010 (#$US010)" "2h" "Placeholder y skeleton.")
# --- US-011
TS026=$(create_task "TS-026 — ChartContainer con Recharts" "011 (#$US011)" "3h" "Container responsive con Recharts.")
TS027=$(create_task "TS-027 — FullscreenChartModal" "011 (#$US011)" "3h" "Botón de ampliación y modal fullscreen.")
# --- US-012
TS028=$(create_task "TS-028 — React Hook Form + Zod" "012 (#$US012)" "3h" "Integración con @hookform/resolvers/zod.")
TS029=$(create_task "TS-029 — FormField con errores i18n" "012 (#$US012)" "2h" "Wrapper con label, error y traducción.")
# --- US-013
TS030=$(create_task "TS-030 — Maquetar LoginView responsive" "013 (#$US013)" "3h" "Vista de login con breakpoints.")
TS031=$(create_task "TS-031 — Conectar con POST /api/auth/login" "013 (#$US013)" "3h" "Manejo de errores AUTH-001, AUTH-002, RATE-001.")
TS032=$(create_task "TS-032 — Almacenar token y refreshToken" "013 (#$US013)" "2h" "tokenStorage con localStorage.")
# --- US-014
TS033=$(create_task "TS-033 — AuthContext" "014 (#$US014)" "3h" "Estado de sesión, login, logout, refreshProfile.")
TS034=$(create_task "TS-034 — useRefreshToken hook" "014 (#$US014)" "3h" "Sesión deslizante.")
# --- US-015
TS035=$(create_task "TS-035 — LogoutButton" "015 (#$US015)" "2h" "Llama a POST /api/auth/logout.")
TS036=$(create_task "TS-036 — Limpiar estado y redirigir" "015 (#$US015)" "1h" "Limpiar tokenStorage y navegar a /login.")
# --- US-016
TS037=$(create_task "TS-037 — ProtectedRoute y RoleGuard" "016 (#$US016)" "3h" "Validación de autenticación y roles.")
# --- US-017
TS038=$(create_task "TS-038 — Maquetar HomeView" "017 (#$US017)" "4h" "Widgets de resumen.")
TS039=$(create_task "TS-039 — Consumir GET /api/test/health" "017 (#$US017)" "1h" "Estado del sistema.")
TS040=$(create_task "TS-040 — Placeholder dashboard/resumen" "017 (#$US017)" "2h" "Preparar espacio para endpoints futuros.")
# --- US-018
TS041=$(create_task "TS-041 — Widget de perfil resumido" "018 (#$US018)" "3h" "Usa get-my-profile en HomeView.")
# --- US-019
TS042=$(create_task "TS-042 — Maquetar ProfileView" "019 (#$US019)" "3h" "Vista de perfil del usuario autenticado.")
TS043=$(create_task "TS-043 — Mostrar datos sin ofuscar" "019 (#$US019)" "1h" "get-my-profile está en OWN_DATA_PATHS; NO aplicar máscara en el cliente.")
# --- US-020
TS044=$(create_task "TS-044 — Maquetar EditProfileView" "020 (#$US020)" "3h" "Formulario precargado con RHF + Zod.")
TS045=$(create_task "TS-045 — Conectar update-my-profile" "020 (#$US020)" "4h" "Validar id/username contra el JWT del AuthContext.")
TS046=$(create_task "TS-046 — Mapear errores" "020 (#$US020)" "3h" "SYS-* → comun:error.sysGenerico. Otros errores mapeo individual (REG-002, REG-003, REG-007, AUTH-007).")
TS047=$(create_task "TS-047 — Refetch tras UPT-0001" "020 (#$US020)" "3h" "Actualizar AuthContext Y volver a consultar get-my-profile.")
# --- US-021
TS048=$(create_task "TS-048 — Modal de confirmación" "021 (#$US021)" "3h" "Confirmación para POST /api/auth/delete-account.")
TS049=$(create_task "TS-049 — Limpiar sesión y redirigir" "021 (#$US021)" "2h" "Tras borrado lógico, limpiar y redirigir a login.")

echo "   Tasks creadas."

# ---------------------------------------------------------
# 6) AGREGAR AL PROJECT
# ---------------------------------------------------------
echo "==> [6/7] Agregando al Project #$PROJECT_NUMBER..."

ALL_ISSUES="$CAP $FT001 $FT002 $FT003 $FT004 $FT005 \
$US001 $US002 $US003 $US004 $US005 $US006 $US007 $US008 $US009 $US010 $US011 $US012 \
$US013 $US014 $US015 $US016 $US017 $US018 $US019 $US020 $US021 \
$TS050 $TS001 $TS002 $TS003 $TS004 $TS005 $TS006 $TS007 $TS008 $TS009 $TS010 \
$TS011 $TS012 $TS013 $TS014 $TS015 $TS016 $TS017 $TS018 $TS019 $TS020 \
$TS021 $TS022 $TS023 $TS024 $TS025 $TS026 $TS027 $TS028 $TS029 $TS030 \
$TS031 $TS032 $TS033 $TS034 $TS035 $TS036 $TS037 $TS038 $TS039 $TS040 \
$TS041 $TS042 $TS043 $TS044 $TS045 $TS046 $TS047 $TS048 $TS049"

ADDED=0
for iss in $ALL_ISSUES; do
  if gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" \
    --url "https://github.com/$REPO/issues/$iss" >/dev/null 2>&1; then
    ADDED=$((ADDED + 1))
  fi
done
echo "   $ADDED issues agregados al Project #$PROJECT_NUMBER"

# ---------------------------------------------------------
# 7) VINCULAR JERARQUÍA (SUB-ISSUES) — con retry y sleep
# ---------------------------------------------------------
echo "==> [7/7] Vinculando jerarquía (sub-issues)..."

LINKED=0
FAILED=0

link_sub() {
  local parent=$1; local child=$2
  local attempt=1
  local max_attempts=3
  local pid cid

  pid=$(gh issue view "$parent" --repo "$REPO" --json id --jq '.id' 2>/dev/null || echo "")
  cid=$(gh issue view "$child"  --repo "$REPO" --json id --jq '.id' 2>/dev/null || echo "")

  if [ -z "$pid" ] || [ -z "$cid" ]; then
    echo "   ⚠ No se obtuvieron IDs: #$parent → #$child"
    FAILED=$((FAILED + 1))
    return 1
  fi

  while [ "$attempt" -le "$max_attempts" ]; do
    if gh api graphql -f query='
      mutation($p:ID!, $c:ID!) {
        addSubIssue(input:{issueId:$p, subIssueId:$c}) { issue { id } }
      }' -f p="$pid" -f c="$cid" >/dev/null 2>&1; then
      echo "   ✓ #$parent ← #$child"
      LINKED=$((LINKED + 1))
      sleep 0.3
      return 0
    fi
    sleep 1
    attempt=$((attempt + 1))
  done

  echo "   ❌ Falló tras $max_attempts intentos: #$parent ← #$child"
  FAILED=$((FAILED + 1))
  return 1
}

# CAP -> FT
for ft in $FT001 $FT002 $FT003 $FT004 $FT005; do link_sub "$CAP" "$ft"; done

# FT -> US
for us in $US001 $US002 $US003 $US004 $US005 $US006; do link_sub "$FT001" "$us"; done
for us in $US007 $US008 $US009 $US010 $US011 $US012; do link_sub "$FT002" "$us"; done
for us in $US013 $US014 $US015 $US016; do link_sub "$FT003" "$us"; done
for us in $US017 $US018; do link_sub "$FT004" "$us"; done
for us in $US019 $US020 $US021; do link_sub "$FT005" "$us"; done

# US -> TS
link_sub "$US001" "$TS050"; link_sub "$US001" "$TS001"; link_sub "$US001" "$TS002"
link_sub "$US002" "$TS003"; link_sub "$US002" "$TS004"
link_sub "$US003" "$TS005"; link_sub "$US003" "$TS006"; link_sub "$US003" "$TS007"
link_sub "$US004" "$TS008"; link_sub "$US004" "$TS009"; link_sub "$US004" "$TS010"
link_sub "$US005" "$TS011"; link_sub "$US005" "$TS012"; link_sub "$US005" "$TS013"
link_sub "$US006" "$TS014"; link_sub "$US006" "$TS015"
link_sub "$US007" "$TS016"; link_sub "$US007" "$TS017"; link_sub "$US007" "$TS018"
link_sub "$US008" "$TS019"; link_sub "$US008" "$TS020"
link_sub "$US009" "$TS021"; link_sub "$US009" "$TS022"; link_sub "$US009" "$TS023"
link_sub "$US010" "$TS024"; link_sub "$US010" "$TS025"
link_sub "$US011" "$TS026"; link_sub "$US011" "$TS027"
link_sub "$US012" "$TS028"; link_sub "$US012" "$TS029"
link_sub "$US013" "$TS030"; link_sub "$US013" "$TS031"; link_sub "$US013" "$TS032"
link_sub "$US014" "$TS033"; link_sub "$US014" "$TS034"
link_sub "$US015" "$TS035"; link_sub "$US015" "$TS036"
link_sub "$US016" "$TS037"
link_sub "$US017" "$TS038"; link_sub "$US017" "$TS039"; link_sub "$US017" "$TS040"
link_sub "$US018" "$TS041"
link_sub "$US019" "$TS042"; link_sub "$US019" "$TS043"
link_sub "$US020" "$TS044"; link_sub "$US020" "$TS045"; link_sub "$US020" "$TS046"; link_sub "$US020" "$TS047"
link_sub "$US021" "$TS048"; link_sub "$US021" "$TS049"

echo "   Links OK: $LINKED | Fallidos: $FAILED"

# ---------------------------------------------------------
# Guardar IDs
# ---------------------------------------------------------
cat > "$KANBAN_DIR/kanban-ids.env" <<ENV
CAP=$CAP
FT001=$FT001
FT002=$FT002
FT003=$FT003
FT004=$FT004
FT005=$FT005
US001=$US001
US002=$US002
US003=$US003
US004=$US004
US005=$US005
US006=$US006
US007=$US007
US008=$US008
US009=$US009
US010=$US010
US011=$US011
US012=$US012
US013=$US013
US014=$US014
US015=$US015
US016=$US016
US017=$US017
US018=$US018
US019=$US019
US020=$US020
US021=$US021
TS050=$TS050
TS001=$TS001
TS002=$TS002
TS003=$TS003
TS004=$TS004
TS005=$TS005
TS006=$TS006
TS007=$TS007
TS008=$TS008
TS009=$TS009
TS010=$TS010
TS011=$TS011
TS012=$TS012
TS013=$TS013
TS014=$TS014
TS015=$TS015
TS016=$TS016
TS017=$TS017
TS018=$TS018
TS019=$TS019
TS020=$TS020
TS021=$TS021
TS022=$TS022
TS023=$TS023
TS024=$TS024
TS025=$TS025
TS026=$TS026
TS027=$TS027
TS028=$TS028
TS029=$TS029
TS030=$TS030
TS031=$TS031
TS032=$TS032
TS033=$TS033
TS034=$TS034
TS035=$TS035
TS036=$TS036
TS037=$TS037
TS038=$TS038
TS039=$TS039
TS040=$TS040
TS041=$TS041
TS042=$TS042
TS043=$TS043
TS044=$TS044
TS045=$TS045
TS046=$TS046
TS047=$TS047
TS048=$TS048
TS049=$TS049
ENV

echo ""
echo "══════════════════════════════════════════════════════"
echo "  ✅ CAP-01 creada exitosamente"
echo "  - 1 Capability"
echo "  - 5 Features"
echo "  - 21 User Stories"
echo "  - 50 Tasks"
echo "  - Sub-issues vinculados: $LINKED (fallidos: $FAILED)"
echo "  IDs guardados en: $KANBAN_DIR/kanban-ids.env"
echo "══════════════════════════════════════════════════════"

if [ "$FAILED" -gt 0 ]; then
  echo ""
  echo "⚠️  ATENCIÓN: $FAILED vinculaciones fallaron."
  echo "   Ejecuta el script de reintento o vuelve a correr este script."
  exit 1
fi
