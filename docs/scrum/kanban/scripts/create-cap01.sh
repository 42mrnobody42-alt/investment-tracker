#!/usr/bin/env bash
# =========================================================
# create-cap01.sh — Crea CAP-01 + FT + US + TS en GitHub
# Estructura: 9 FT · 41 US · 143 TS
# Alineado a README.md, prompt_inicial.md, agente-frontend.md,
# agente-backend.md y agente-database.md.
# =========================================================
set -euo pipefail

REPO="42mrnobody42-alt/investment-tracker"
PROJECT_OWNER="42mrnobody42-alt"
PROJECT_NUMBER=2
KANBAN_DIR="/prog/datos/investment-tracker/docs/scrum/kanban"

echo "══════════════════════════════════════════════════════"
echo "  Creando CAP-01 (completo) en $REPO"
echo "══════════════════════════════════════════════════════"

# ---------------------------------------------------------
# 1) LABELS
# ---------------------------------------------------------
echo "==> [1/7] Creando labels..."
gh label create "capability"      --repo "$REPO" --color "6f42c1" --description "Capability del proyecto" --force
gh label create "feature"         --repo "$REPO" --color "0e8a16" --description "Feature dentro de una capability" --force
gh label create "user-story"      --repo "$REPO" --color "1d76db" --description "User Story dentro de una feature" --force
gh label create "task"            --repo "$REPO" --color "fbca04" --description "Tarea técnica (<=4h)" --force
gh label create "frontend"        --repo "$REPO" --color "5319e7" --description "Relacionado con frontend React" --force
gh label create "i18n"            --repo "$REPO" --color "c5def5" --description "Internacionalización" --force
gh label create "responsive"      --repo "$REPO" --color "bfd4f2" --description "Diseño responsive" --force
gh label create "design-system"   --repo "$REPO" --color "d4c5f9" --description "Componentes del Design System" --force
gh label create "storybook"       --repo "$REPO" --color "ff8c00" --description "History Book / Storybook" --force
gh label create "tokens"          --repo "$REPO" --color "c2e0c6" --description "Design tokens y theming" --force
gh label create "runtime-assets"  --repo "$REPO" --color "f9d0c4" --description "Assets editables post-deploy" --force
gh label create "testing"         --repo "$REPO" --color "0e8a16" --description "Tests unitarios / integración / E2E" --force
gh label create "a11y"            --repo "$REPO" --color "1d76db" --description "Accesibilidad WCAG 2.2 AA" --force
gh label create "performance"     --repo "$REPO" --color "fbca04" --description "Performance y presupuesto" --force
gh label create "e2e"             --repo "$REPO" --color "5319e7" --description "End-to-end Playwright" --force
gh label create "public-page"     --repo "$REPO" --color "c5def5" --description "Vista pública pre-login" --force

# ---------------------------------------------------------
# 2) HELPERS
# ---------------------------------------------------------
create_ft() {
  local title="$1" body="$2"
  gh issue create --repo "$REPO" --title "$title" --label "feature,frontend" \
    --body "$(printf '%b' "$body")" | grep -oE '[0-9]+$'
}

create_us() {
  local title="$1" labels="$2" body="$3"
  gh issue create --repo "$REPO" --title "$title" --label "$labels" \
    --body "$(printf '%b' "$body")" | grep -oE '[0-9]+$'
}

create_task() {
  local title="$1" us="$2" hours="$3" desc="$4"
  gh issue create --repo "$REPO" --title "$title" --label "task,frontend" \
    --body "$(printf '## Descripción\n%s\n\n## Estimación\n%s\n\n## US padre\n%s' "$desc" "$hours" "$us")" \
    | grep -oE '[0-9]+$'
}

# ---------------------------------------------------------
# 3) CAPABILITY
# ---------------------------------------------------------
echo "==> [2/7] Creando Capability CAP-01..."
CAP=$(gh issue create --repo "$REPO" \
  --title "CAP-01 — Frontend React: infraestructura, design system, InitPage, autenticación y perfil" \
  --label "capability,frontend" \
  --body "$(cat <<'BODY'
## Objetivo
Implementar el frontend React 18 + TypeScript + Vite del sistema, alineado a `docs/prompts/agente-frontend.md` v1.3.0.

## Alcance
- Setup completo (Vite, TS estricto, ESLint, Prettier, Stylelint, Husky, commitlint).
- Storybook (History Book) con stories obligatorias por componente.
- Design System completo: átomos, moléculas, organismos, layout.
- Design tokens + theming (light/dark/high-contrast).
- i18n con namespaces por componente (es/en).
- Assets editables en runtime vía `manifest.json` + `useAsset()`.
- AppShell (TopBar + Sidebar plegable + Workspace) con `OrientationGate`.
- Vistas por orientación: `views/horizontal/` y `views/vertical/`.
- Guards: PublicRoute, ProtectedRoute, RoleRoute, OnboardingRoute.
- InitPage público con botones **Contáctenos**, **Login**, **Registrar**.
- Login, logout, registro (2 pasos), recuperación (2 pasos), cambio de contraseña.
- Home / Dashboard, Perfil (consulta, edición, eliminación lógica).
- Vistas de error 404/403/500.
- Testing: Vitest + Testing Library + Playwright (5 configs) + `@axe-core/playwright`.
- Calidad: Lighthouse ≥ 90, a11y WCAG 2.2 AA, presupuesto de bundle.

## Features
- FT-001 — Setup e infraestructura base
- FT-002 — Design tokens, i18n y assets runtime
- FT-003 — Design System: átomos
- FT-004 — Design System: moléculas
- FT-005 — Design System: organismos y layout
- FT-006 — AppShell, routing y guards
- FT-007 — InitPage público (presentación del proyecto)
- FT-008 — Autenticación, registro y recuperación
- FT-009 — Home, perfil y calidad transversal

## Criterios de aceptación
- [ ] Login funcional contra `POST /api/auth/login` (manejo AUTH-001, AUTH-002, RATE-001).
- [ ] Refresh automático contra `POST /api/auth/refresh-token`.
- [ ] Rutas protegidas por rol (ADMIN, USER, PREMIUM).
- [ ] InitPage pública con CTA a Contáctenos, Login, Registrar.
- [ ] Home con perfil resumido contra `GET /api/auth/get-my-profile`.
- [ ] Consulta y edición de perfil contra `POST /api/auth/update-my-profile` (manejo UPT-0001 y REG-002/003/007, AUTH-007, SYS-03).
- [ ] Eliminación lógica contra `POST /api/auth/delete-account`.
- [ ] i18n operativo (es/en sin recargar).
- [ ] Responsive en horizontal (PC/tablet apaisada/TV) y vertical (móvil/tablet retrato).
- [ ] Storybook con stories de todos los componentes.
- [ ] Playwright 5 configs verdes + a11y sin violaciones críticas.

**Rama base:** developer
**Rama de trabajo:** feature/CAP-01-frontend-base
BODY
)" | grep -oE '[0-9]+$')
echo "   CAP-01 = #$CAP"

# ---------------------------------------------------------
# 4) FEATURES
# ---------------------------------------------------------
echo "==> [3/7] Creando Features..."
declare -A FT
FT[FT-001]=$(create_ft "FT-001 — Setup e infraestructura base" \
"Configuración inicial del proyecto: Vite + React 18 + TypeScript estricto, ESLint/Prettier/Stylelint, Storybook, testing (Vitest + Playwright), Husky, variables de entorno y proxy /api.\n\n## User Stories\n- US-001 a US-006\n\n## Dependencias\nNinguna. Base para las demás features.")

FT[FT-002]=$(create_ft "FT-002 — Design tokens, i18n y assets runtime" \
"Sistema de diseño base: tokens CSS, temas light/dark/high-contrast, i18n con namespaces por componente (es/en), assets editables en runtime vía manifest.json y useAsset().\n\n## User Stories\n- US-007 a US-009\n\n## Dependencias\nFT-001.")

FT[FT-003]=$(create_ft "FT-003 — Design System: átomos" \
"Átomos obligatorios del Design System: Button, Input, Textarea, Select, Checkbox, Radio, Switch, Icon, Badge, Tag, Avatar, Tooltip, Spinner, Divider, Skeleton. Cada uno con .tsx, .module.css, .types.ts, .test.tsx, .stories.tsx e index.ts.\n\n## User Stories\n- US-010, US-011\n\n## Dependencias\nFT-001, FT-002.")

FT[FT-004]=$(create_ft "FT-004 — Design System: moléculas" \
"Moléculas obligatorias: Modal (info/warning/error/success/confirm), Toast, Popover, Dropdown, Tabs, Accordion, Breadcrumbs, Pagination, FormField, SearchBar, LanguageSwitcher, ThemeSwitcher.\n\n## User Stories\n- US-012 a US-014\n\n## Dependencias\nFT-003.")

FT[FT-005]=$(create_ft "FT-005 — Design System: organismos y layout" \
"Organismos: DataTable, ChartPanel, MediaPlayer, FileUploader, Wizard, SidebarMenu, NotificationCenter, UserMenu. Layout: SafeAreaView, KeyboardAwareView, PublicHeader, Footer, OrientationGate.\n\n## User Stories\n- US-015 a US-018\n\n## Dependencias\nFT-004.")

FT[FT-006]=$(create_ft "FT-006 — AppShell, routing y guards" \
"AppShell (TopBar + Sidebar plegable + Workspace), React Router v6 con lazy loading, paths, guards (Public/Protected/Role/Onboarding), detección de viewport/orientación/dispositivo y cliente HTTP con interceptores JWT + refresh.\n\n## User Stories\n- US-019 a US-023\n\n## Dependencias\nFT-002, FT-004, FT-005.")

FT[FT-007]=$(create_ft "FT-007 — InitPage público (presentación del proyecto)" \
"Vista pública pre-login con hero, beneficios, cómo funciona, partners, casos de éxito, footer. Incluye botones **Contáctenos**, **Login** y **Registrar** en la barra superior, que redirigen a /contact, /login y /register respectivamente. Versión horizontal (PC, tablet apaisada, TV) y vertical (móvil, tablet retrato).\n\n## User Stories\n- US-024 a US-026\n\n## Dependencias\nFT-002, FT-005, FT-006.")

FT[FT-008]=$(create_ft "FT-008 — Autenticación, registro y recuperación" \
"LoginView (horizontal + vertical), AuthContext, useRefreshToken, logout, registro en 2 pasos, recuperación de contraseña en 2 pasos y cambio de contraseña propia. Todos los flujos consumen endpoints reales del README y manejan códigos de error por dominio.\n\n## User Stories\n- US-027 a US-034\n\n## Dependencias\nFT-002, FT-006.")

FT[FT-009]=$(create_ft "FT-009 — Home, perfil y calidad transversal" \
"HomeView, widget de perfil resumido, ProfileView, EditProfileView, eliminación lógica de cuenta, vistas de error 404/403/500. Cierra con auditoría a11y completa (axe-core), presupuesto de performance (Lighthouse ≥ 90) y E2E Playwright en 5 configuraciones.\n\n## User Stories\n- US-035 a US-041\n\n## Dependencias\nFT-006, FT-008.")

echo "   FT creadas: 001..009"

# ---------------------------------------------------------
# 5) USER STORIES
# ---------------------------------------------------------
echo "==> [4/7] Creando User Stories..."
declare -A US
declare -A US_PARENT

# ---- FT-001 -------------------------------------------------------------
US[US-001]=$(create_us "US-001 — Inicializar proyecto Vite + React 18 + TypeScript estricto" \
  "user-story,frontend" \
"## Objetivo\nEliminar el frontend actual y arrancar un proyecto limpio con Vite + React 18 + TypeScript en modo estricto.\n\n## Tareas\n- TS-001 Inicializar Vite + React 18 + TS (2h)\n- TS-002 ESLint + Prettier + tsconfig estricto (2h)\n- TS-003 Stylelint para CSS Modules (1h)\n- TS-004 Eliminar frontend/ actual (1h)\n\n## Criterios\n- [ ] npm run dev levanta sin errores\n- [ ] npm run build sin warnings\n- [ ] ESLint/Prettier/Stylelint limpios")
US_PARENT[US-001]=FT-001

US[US-002]=$(create_us "US-002 — Estructura de carpetas, alias y convenciones" \
  "user-story,frontend" \
"## Objetivo\nDefinir la estructura src/ y alias de imports (@app, @components, @views, @shared, @i18n, @styles).\n\n## Tareas\n- TS-005 Estructura src/ (2h)\n- TS-006 Alias en tsconfig + vite (1h)\n- TS-007 Documentar convenciones en frontend/README.md (1h)")
US_PARENT[US-002]=FT-001

US[US-003]=$(create_us "US-003 — Configurar Storybook (History Book)" \
  "user-story,frontend,storybook" \
"## Objetivo\nStorybook operativo con decoradores globales (ThemeProvider, I18nextProvider, Router) y build estático.\n\n## Tareas\n- TS-008 Instalar y configurar Storybook (2h)\n- TS-009 Decoradores globales (2h)\n- TS-010 Story DesignTokens/Overview (2h)\n- TS-011 Build estático (1h)")
US_PARENT[US-003]=FT-001

US[US-004]=$(create_us "US-004 — Testing setup (Vitest + Playwright + axe)" \
  "user-story,frontend,testing" \
"## Objetivo\nInfraestructura de pruebas: unitarias con Vitest + Testing Library, E2E con Playwright en 5 configs y auditoría a11y con @axe-core/playwright.\n\n## Tareas\n- TS-012 Vitest + Testing Library + setup.ts (2h)\n- TS-013 Playwright 5 proyectos (3h)\n- TS-014 @axe-core/playwright (2h)\n- TS-015 Scripts npm (1h)")
US_PARENT[US-004]=FT-001

US[US-005]=$(create_us "US-005 — Husky + lint-staged + commitlint" \
  "user-story,frontend" \
"## Objetivo\nHooks de Git que garantizan calidad antes de commit/push.\n\n## Tareas\n- TS-016 Husky + pre-commit (2h)\n- TS-017 commitlint + commit-msg (1h)\n- TS-018 pre-push (1h)")
US_PARENT[US-005]=FT-001

US[US-006]=$(create_us "US-006 — Variables de entorno y proxy /api" \
  "user-story,frontend" \
"## Objetivo\nVariables VITE_* tipadas y proxy /api hacia el backend en desarrollo.\n\n## Tareas\n- TS-019 .env.example + .env.development/staging/production (1h)\n- TS-020 vite.config.ts con proxy /api (2h)\n- TS-021 env.d.ts tipado (1h)")
US_PARENT[US-006]=FT-001

# ---- FT-002 -------------------------------------------------------------
US[US-007]=$(create_us "US-007 — Design tokens y theming (light/dark/high-contrast)" \
  "user-story,frontend,tokens" \
"## Objetivo\nTokens CSS (color, spacing, radius, typography, z-index) y 3 temas con data-theme en <html>.\n\n## Tareas\n- TS-022 tokens.css (3h)\n- TS-023 themes/light.css, dark.css, high-contrast.css (3h)\n- TS-024 ThemeProvider con persistencia (2h)\n\n## Criterios\n- [ ] Cambio de tema sin recargar\n- [ ] Preferencia persistida en localStorage")
US_PARENT[US-007]=FT-002

US[US-008]=$(create_us "US-008 — i18n con namespaces por componente" \
  "user-story,frontend,i18n" \
"## Objetivo\nreact-i18next con namespaces por componente (estructura i18n/<locale>/<componente>/), scripts check-i18n y gen-i18n-types.\n\n## Tareas\n- TS-026 i18next + LanguageDetector (2h)\n- TS-027 Estructura i18n/es/<componente>/ y i18n/en/... (3h)\n- TS-028 Namespaces + common/errors/validations (2h)\n- TS-030 check-i18n.mjs y gen-i18n-types.mjs (3h)\n\n## Criterios\n- [ ] Cambio es/en sin recargar\n- [ ] common/errors.json incluye claves AUTH-*, REG-*, REC-*, PWD-*, RATE-*, SYS-*")
US_PARENT[US-008]=FT-002

US[US-009]=$(create_us "US-009 — Assets runtime y useAsset()" \
  "user-story,frontend,runtime-assets" \
"## Objetivo\npublic/assets/ con logos, imágenes por dominio, iconos y fuentes. manifest.json + useAsset() + gen-assets-manifest.mjs.\n\n## Tareas\n- TS-031 public/assets/ estructura + placeholders (2h)\n- TS-032 manifest.json + gen-assets-manifest.mjs (2h)\n- TS-033 useAsset hook (1h)\n- TS-034 fonts.css con @font-face swap (1h)")
US_PARENT[US-009]=FT-002

# ---- FT-003 -------------------------------------------------------------
US[US-010]=$(create_us "US-010 — Átomos: botones y controles de formulario" \
  "user-story,frontend,design-system,storybook" \
"## Objetivo\nButton (primary/secondary/ghost/danger), Input, Textarea, Select, Checkbox, Radio, Switch. Cada uno con plantilla completa (tsx, module.css, types, test, stories, index).\n\n## Tareas\n- TS-035 Button con variantes (3h)\n- TS-036 Input y Textarea (2h)\n- TS-037 Select, Checkbox, Radio, Switch (3h)")
US_PARENT[US-010]=FT-003

US[US-011]=$(create_us "US-011 — Átomos: presentación (Icon, Badge, Tag, Avatar, Tooltip, Spinner, Divider, Skeleton)" \
  "user-story,frontend,design-system,storybook" \
"## Objetivo\nÁtomos de presentación con stories y tests.\n\n## Tareas\n- TS-038 Icon, Badge, Tag, Avatar (3h)\n- TS-039 Tooltip, Spinner, Divider, Skeleton (3h)")
US_PARENT[US-011]=FT-003

# ---- FT-004 -------------------------------------------------------------
US[US-012]=$(create_us "US-012 — Moléculas: feedback (Modal, Toast, Popover)" \
  "user-story,frontend,design-system,storybook,a11y" \
"## Objetivo\nModal con variantes info/warning/error/success/confirm, sistema de toasts con aria-live, popover anclado. Focus trap obligatorio.\n\n## Tareas\n- TS-040 Modal base + focus trap (4h)\n- TS-041 Variantes Info/Warning/Error/Success/Confirm (3h)\n- TS-042 Toast + ToastProvider + aria-live (3h)\n- TS-043 Popover (3h)")
US_PARENT[US-012]=FT-004

US[US-013]=$(create_us "US-013 — Moléculas: navegación (Dropdown, Tabs, Accordion, Breadcrumbs, Pagination)" \
  "user-story,frontend,design-system,storybook" \
"## Tareas\n- TS-044 Dropdown (3h)\n- TS-045 Tabs (3h)\n- TS-046 Accordion (2h)\n- TS-047 Breadcrumbs (2h)\n- TS-048 Pagination (2h)")
US_PARENT[US-013]=FT-004

US[US-014]=$(create_us "US-014 — Moléculas: formularios (FormField, SearchBar, LanguageSwitcher, ThemeSwitcher)" \
  "user-story,frontend,design-system,storybook,i18n" \
"## Tareas\n- TS-049 FormField con error i18n (2h)\n- TS-050 SearchBar con debounce (2h)\n- TS-051 LanguageSwitcher (2h)\n- TS-052 ThemeSwitcher (2h)")
US_PARENT[US-014]=FT-004

# ---- FT-005 -------------------------------------------------------------
US[US-015]=$(create_us "US-015 — Organismos: datos (DataTable, ChartPanel)" \
  "user-story,frontend,design-system,storybook" \
"## Objetivo\nDataTable con paginación, sorting, filtros, estados loading/empty/error y virtualización >100 filas. ChartPanel con botón de pantalla completa.\n\n## Tareas\n- TS-053 DataTable (5h)\n- TS-054 Estado vacío + skeleton (2h)\n- TS-055 ChartContainer con Recharts (3h)\n- TS-056 FullscreenChartModal (3h)")
US_PARENT[US-015]=FT-005

US[US-016]=$(create_us "US-016 — Organismos: contenido (MediaPlayer, FileUploader, Wizard)" \
  "user-story,frontend,design-system,storybook" \
"## Tareas\n- TS-057 MediaPlayer con fullscreen y PiP (4h)\n- TS-058 FileUploader con drag & drop (4h)\n- TS-059 Wizard multi-paso (4h)")
US_PARENT[US-016]=FT-005

US[US-017]=$(create_us "US-017 — Organismos: layout (SidebarMenu, NotificationCenter, UserMenu)" \
  "user-story,frontend,design-system,storybook" \
"## Tareas\n- TS-060 SidebarMenu plegable (4h)\n- TS-061 NotificationCenter (3h)\n- TS-062 UserMenu (2h)")
US_PARENT[US-017]=FT-005

US[US-018]=$(create_us "US-018 — Layout helpers (SafeAreaView, KeyboardAwareView, PublicHeader, Footer, OrientationGate)" \
  "user-story,frontend,design-system,responsive" \
"## Tareas\n- TS-063 SafeAreaView (1h)\n- TS-064 KeyboardAwareView (2h)\n- TS-065 PublicHeader (2h)\n- TS-066 Footer (2h)\n- TS-067 OrientationGate (2h)")
US_PARENT[US-018]=FT-005

# ---- FT-006 -------------------------------------------------------------
US[US-019]=$(create_us "US-019 — AppShell (TopBar + Sidebar + Workspace)" \
  "user-story,frontend,responsive" \
"## Objetivo\nLayout obligatorio para vistas autenticadas: TopBar informativa, Sidebar plegable con persistencia, Workspace con scroll propio.\n\n## Tareas\n- TS-068 AppShell con grid (4h)\n- TS-069 TopBar (3h)\n- TS-070 Sidebar persistente (3h)\n- TS-071 Workspace (2h)")
US_PARENT[US-019]=FT-006

US[US-020]=$(create_us "US-020 — React Router v6 + lazy + paths" \
  "user-story,frontend" \
"## Tareas\n- TS-072 createBrowserRouter + lazyViews (3h)\n- TS-073 paths.ts (1h)\n- TS-074 routes.config.ts con metadata de orientación (2h)")
US_PARENT[US-020]=FT-006

US[US-021]=$(create_us "US-021 — Guards (Public/Protected/Role/Onboarding)" \
  "user-story,frontend" \
"## Tareas\n- TS-075 PublicRoute (1h)\n- TS-076 ProtectedRoute (2h)\n- TS-077 RoleRoute (2h)\n- TS-078 OnboardingRoute (2h)")
US_PARENT[US-021]=FT-006

US[US-022]=$(create_us "US-022 — Detección de viewport, orientación y dispositivo" \
  "user-story,frontend,responsive" \
"## Objetivo\nHooks compartidos: useViewport, useOrientation, useDeviceClass, useKeyboardInset, useSafeAreaInsets.\n\n## Tareas\n- TS-079 useViewport (3h)\n- TS-080 useOrientation (1h)\n- TS-081 useDeviceClass (1h)\n- TS-082 useKeyboardInset (2h)\n- TS-083 useSafeAreaInsets (1h)")
US_PARENT[US-022]=FT-006

US[US-023]=$(create_us "US-023 — Cliente HTTP con interceptores JWT + refresh" \
  "user-story,frontend" \
"## Objetivo\nhttp.ts único con interceptor de request (JWT), response (refresh automático ante 401) y mapeo de códigos de error a i18n.\n\n## Tareas\n- TS-084 http.ts con Axios (2h)\n- TS-085 Interceptor request (2h)\n- TS-086 Interceptor response con refresh (4h)\n- TS-087 httpStatus.ts con mapeo a i18n (2h)\n- TS-088 tokenStorage (2h)")
US_PARENT[US-023]=FT-006

# ---- FT-007 (InitPage) --------------------------------------------------
US[US-024]=$(create_us "US-024 — InitPage horizontal (presentación del proyecto)" \
  "user-story,frontend,public-page,responsive" \
"## Objetivo\nVista pública pre-login para PC, tablet apaisada y Smart TV.\n\n## Estructura obligatoria\n- TopBar pública: logo + menú **Contáctenos**, **Login**, **Registrar**\n- Hero: qué hace el producto, qué problema resuelve, CTA principal\n- Sección Beneficios / Cómo funciona\n- Sección Partners + Casos de éxito\n- Footer con legales, idioma y redes\n\n## Redirecciones\n- **Contáctenos** → /contact\n- **Login** → /login\n- **Registrar** → /register\n\n## Tareas\n- TS-089 Hero (3h)\n- TS-090 Beneficios / Cómo funciona (3h)\n- TS-091 Partners + Casos de éxito (2h)\n- TS-092 TopBar pública con CTA (2h)\n- TS-093 Footer con legales (2h)")
US_PARENT[US-024]=FT-007

US[US-025]=$(create_us "US-025 — InitPage vertical (móvil y tablet retrato)" \
  "user-story,frontend,public-page,responsive" \
"## Objetivo\nMisma InitPage con composición vertical, 100dvh, safe-area-inset y teclado virtual.\n\n## Tareas\n- TS-094 Maquetar InitPage vertical (4h)\n- TS-095 Ajustes 100dvh y safe-area (2h)")
US_PARENT[US-025]=FT-007

US[US-026]=$(create_us "US-026 — Contáctenos y páginas legales" \
  "user-story,frontend,public-page" \
"## Objetivo\nVista /contact (formulario o datos de contacto) y vistas /terms, /privacy.\n\n## Tareas\n- TS-096 ContactView horizontal + vertical (3h)\n- TS-097 TermsView + PrivacyView (3h)")
US_PARENT[US-026]=FT-007

# ---- FT-008 -------------------------------------------------------------
US[US-027]=$(create_us "US-027 — LoginView horizontal + vertical" \
  "user-story,frontend,responsive" \
"## Objetivo\nVista de Login en ambas orientaciones. Consume POST /api/auth/login (solo retorna {token, refreshToken}).\n\n## Códigos de error a manejar\n- AUTH-001 credenciales inválidas (401)\n- AUTH-002 cuenta bloqueada (423)\n- AUTH-005 / AUTH-006 token inválido/expirado (401)\n- RATE-001 demasiadas peticiones\n\n## Tareas\n- TS-098 LoginView horizontal (3h)\n- TS-099 LoginView vertical (2h)\n- TS-100 Conectar POST /api/auth/login (3h)\n- TS-101 Mapeo de errores a i18n (3h)\n- TS-102 Enlaces a /register y /recovery (1h)")
US_PARENT[US-027]=FT-008

US[US-028]=$(create_us "US-028 — AuthContext + useRefreshToken + tokenStorage" \
  "user-story,frontend" \
"## Tareas\n- TS-103 AuthContext con login/logout/refreshProfile (3h)\n- TS-104 useRefreshToken (sesión deslizante) (3h)\n- TS-105 Persistencia segura de tokens (2h)")
US_PARENT[US-028]=FT-008

US[US-029]=$(create_us "US-029 — Logout y cierre de sesión" \
  "user-story,frontend" \
"## Objetivo\nLlama a POST /api/auth/logout, limpia tokens, query cache y navega a /login.\n\n## Tareas\n- TS-106 LogoutButton (2h)\n- TS-107 Limpieza y redirección (2h)")
US_PARENT[US-029]=FT-008

US[US-030]=$(create_us "US-030 — Registro paso 1: POST /api/auth/register/request" \
  "user-story,frontend,responsive" \
"## Objetivo\nFormulario de solicitud de registro (username, email, nombreCompleto, password, repeatPassword, celular, paisId, plan). Envía token de 6 dígitos por email.\n\n## Códigos de error\n- REG-001 username existe\n- REG-002 email existe\n- REG-003 (paisId, celular) existe\n- REG-007 país no encontrado\n\n## Tareas\n- TS-108 RegisterRequestView horizontal + vertical (4h)\n- TS-109 Conectar POST /api/auth/register/request (3h)\n- TS-110 Mapeo REG-001/002/003/007 (3h)")
US_PARENT[US-030]=FT-008

US[US-031]=$(create_us "US-031 — Registro paso 2: POST /api/auth/register/confirm" \
  "user-story,frontend,responsive" \
"## Objetivo\nVista de verificación de token de 6 dígitos y auto-login tras confirmación.\n\n## Tareas\n- TS-111 Vista de verificación (4h)\n- TS-112 Conectar POST /api/auth/register/confirm (3h)\n- TS-113 Auto-login tras confirmación (2h)")
US_PARENT[US-031]=FT-008

US[US-032]=$(create_us "US-032 — Recuperación paso 1: POST /api/auth/recovery/request" \
  "user-story,frontend,responsive" \
"## Tareas\n- TS-114 RecoveryRequestView horizontal + vertical (3h)\n- TS-115 Conectar POST /api/auth/recovery/request (2h)")
US_PARENT[US-032]=FT-008

US[US-033]=$(create_us "US-033 — Recuperación paso 2: POST /api/auth/recovery/verify" \
  "user-story,frontend,responsive" \
"## Códigos de error\n- REC-001 intentos excedidos\n- REC-004 usuario no coincide\n- PWD-001/002/003 contraseña\n\n## Tareas\n- TS-116 Vista token + nueva contraseña (3h)\n- TS-117 Conectar POST /api/auth/recovery/verify (3h)\n- TS-118 Mapeo REC-001/004 (2h)")
US_PARENT[US-033]=FT-008

US[US-034]=$(create_us "US-034 — Cambio de contraseña propia: POST /api/auth/change-my-pass" \
  "user-story,frontend,responsive" \
"## Objetivo\nFormulario con actualPassword, nuevoPassword, repetirNuevoPassword.\n\n## Códigos de error\n- PWD-001 no coinciden\n- PWD-002 no cumple criterios\n- PWD-003 actual incorrecta\n\n## Tareas\n- TS-119 ChangeMyPassView horizontal + vertical (3h)\n- TS-120 Conectar POST /api/auth/change-my-pass (3h)\n- TS-121 Mapeo PWD-001/002/003 (2h)")
US_PARENT[US-034]=FT-008

# ---- FT-009 -------------------------------------------------------------
US[US-035]=$(create_us "US-035 — HomeView horizontal + vertical" \
  "user-story,frontend,responsive" \
"## Objetivo\nDashboard con widgets de resumen, health check y placeholders de negocio.\n\n## Tareas\n- TS-122 HomeView horizontal (4h)\n- TS-123 HomeView vertical (3h)\n- TS-124 Consumir GET /api/test/health (1h)\n- TS-125 Placeholder dashboard/resumen (2h)")
US_PARENT[US-035]=FT-009

US[US-036]=$(create_us "US-036 — Widget de perfil resumido en Home" \
  "user-story,frontend" \
"## Tareas\n- TS-126 Widget con GET /api/auth/get-my-profile (3h)")
US_PARENT[US-036]=FT-009

US[US-037]=$(create_us "US-037 — ProfileView horizontal + vertical" \
  "user-story,frontend,responsive" \
"## Objetivo\nConsulta del perfil propio. GET /api/auth/get-my-profile (OWN_DATA_PATHS → datos reales sin ofuscar).\n\n## Tareas\n- TS-127 ProfileView horizontal (3h)\n- TS-128 ProfileView vertical (2h)\n- TS-129 Consumir GET /api/auth/get-my-profile (2h)")
US_PARENT[US-037]=FT-009

US[US-038]=$(create_us "US-038 — EditProfileView horizontal + vertical" \
  "user-story,frontend,responsive" \
"## Objetivo\nEdición del perfil propio contra POST /api/auth/update-my-profile.\n\n## Request (UpdateMyProfileRequest)\nid, username, email, nombreCompleto, paisId, celular (todos obligatorios).\n\n## Códigos\n- UPT-0001 éxito\n- REG-002 email ya registrado\n- REG-003 (paisId, celular) ya registrado\n- REG-007 país inactivo\n- AUTH-007 username/id ajenos\n- SYS-03 @Valid (500, sin detalle)\n\n## Reglas\n- SYS-* → mensaje genérico de comun:error.sysGenerico\n- Preservar case de email/nombreCompleto (solo trim)\n\n## Tareas\n- TS-130 EditProfileView horizontal + vertical (4h)\n- TS-131 Formulario RHF + Zod (3h)\n- TS-132 Conectar POST /api/auth/update-my-profile (4h)\n- TS-133 Mapeo UPT-0001 + errores (3h)\n- TS-134 Refetch tras éxito (2h)")
US_PARENT[US-038]=FT-009

US[US-039]=$(create_us "US-039 — Eliminación lógica de cuenta" \
  "user-story,frontend" \
"## Objetivo\nModal de confirmación y llamada a POST /api/auth/delete-account.\n\n## Tareas\n- TS-135 Modal de confirmación (3h)\n- TS-136 Conectar + limpiar sesión + redirigir (2h)")
US_PARENT[US-039]=FT-009

US[US-040]=$(create_us "US-040 — Vistas de error 404/403/500 (horizontal + vertical)" \
  "user-story,frontend,responsive" \
"## Tareas\n- TS-137 NotFound horizontal + vertical (2h)\n- TS-138 Forbidden horizontal + vertical (2h)\n- TS-139 ServerError horizontal + vertical (2h)")
US_PARENT[US-040]=FT-009

US[US-041]=$(create_us "US-041 — Calidad transversal (a11y, performance, E2E)" \
  "user-story,frontend,a11y,performance,e2e" \
"## Objetivo\nCerrar la CAP-01 con auditoría a11y completa, presupuesto de performance y E2E en 5 configs.\n\n## Tareas\n- TS-140 @axe-core/playwright en todas las vistas (3h)\n- TS-141 Lighthouse >= 90 (3h)\n- TS-142 E2E Playwright 5 configs (5h)\n- TS-143 bundle-analyze.mjs (2h)")
US_PARENT[US-041]=FT-009

echo "   US creadas: 001..041"

# ---------------------------------------------------------
# 6) TASKS (tabla compacta)
# ---------------------------------------------------------
echo "==> [5/7] Creando Tasks..."
declare -a ALL_TS_IDS=()
declare -A TS_BY_US

while IFS='|' read -r title us hours desc; do
  [ -z "$title" ] && continue
  id=$(create_task "$title" "$us" "$hours" "$desc")
  ALL_TS_IDS+=("$id")
  TS_BY_US[$us]="$id ${TS_BY_US[$us]:-}"
done <<'TASKS'
TS-001 — Inicializar Vite + React 18 + TS|US-001|2h|npm create vite@latest frontend -- --template react-ts
TS-002 — ESLint + Prettier + tsconfig estricto|US-001|2h|Configurar reglas y modo strict.
TS-003 — Stylelint para CSS Modules|US-001|1h|Reglas para CSS Modules y tokens.
TS-004 — Eliminar frontend/ actual|US-001|1h|Verificar Dockerfile.frontend y docker-compose.yml.
TS-005 — Estructura de carpetas src/|US-002|2h|app/, components/, views/, shared/, i18n/, styles/, types/.
TS-006 — Alias de imports (@app, @components, @views, @shared, @i18n, @styles)|US-002|1h|tsconfig + vite.config.
TS-007 — Documentar convenciones en frontend/README.md|US-002|1h|Nombres, exports, orden de imports.
TS-008 — Instalar y configurar Storybook|US-003|2h|@storybook/react-vite + autodocs.
TS-009 — Decoradores globales de Storybook|US-003|2h|ThemeProvider + I18nextProvider + Router.
TS-010 — Story DesignTokens/Overview|US-003|2h|Mostrar tokens y temas.
TS-011 — Build estático de Storybook|US-003|1h|storybook-static/.
TS-012 — Vitest + Testing Library + setup.ts|US-004|2h|Configuración y cobertura 80%.
TS-013 — Playwright 5 proyectos|US-004|3h|mobile-chrome, mobile-safari, tablet, desktop, tv.
TS-014 — @axe-core/playwright|US-004|2h|Test a11y base reusable.
TS-015 — Scripts npm de test|US-004|1h|test, test:unit, test:e2e, test:a11y.
TS-016 — Husky + pre-commit (lint-staged)|US-005|2h|Ejecuta ESLint y Prettier sobre staged.
TS-017 — commitlint + commit-msg|US-005|1h|Conventional Commits.
TS-018 — pre-push (unit tests)|US-005|1h|Evita push con tests rotos.
TS-019 — .env.example + .env.development/staging/production|US-006|1h|VITE_API_URL, VITE_APP_ENV.
TS-020 — vite.config.ts con proxy /api|US-006|2h|Proxy hacia http://localhost:7700.
TS-021 — env.d.ts tipado|US-006|1h|import.meta.env con tipos.
TS-022 — tokens.css|US-007|3h|color, spacing, radius, typography, z-index.
TS-023 — themes/light.css, dark.css, high-contrast.css|US-007|3h|data-theme en <html>.
TS-024 — ThemeProvider con persistencia|US-007|2h|localStorage + prefers-color-scheme.
TS-025 — Estructura i18n/<locale>/<componente>/|US-008|3h|common, initPage, login, register, recovery, home, perfil, servicioA, admin, errors.
TS-026 — i18next + LanguageDetector|US-008|2h|Fallback es, persistencia en localStorage.
TS-027 — Namespaces + common/errors/validations|US-008|2h|common/errors.json con claves AUTH-*, REG-*, REC-*, PWD-*, RATE-*, SYS-*.
TS-028 — check-i18n.mjs y gen-i18n-types.mjs|US-008|3h|Detecta claves faltantes y genera types.
TS-029 — public/assets/ con placeholders|US-009|2h|logos/, images/, icons/, fonts/.
TS-030 — manifest.json + gen-assets-manifest.mjs|US-009|2h|Mapa clave lógica → ruta física.
TS-031 — useAsset hook|US-009|1h|Resuelve clave desde manifest.json.
TS-032 — fonts.css con @font-face swap|US-009|1h|Inter self-hosted en woff2.
TS-033 — Button con variantes|US-010|3h|primary, secondary, ghost, danger + loading/disabled.
TS-034 — Input y Textarea|US-010|2h|Estados default/error/disabled.
TS-035 — Select, Checkbox, Radio, Switch|US-010|3h|Accesibles con label y error.
TS-036 — Icon, Badge, Tag, Avatar|US-011|3h|SVG tokenizados.
TS-037 — Tooltip, Spinner, Divider, Skeleton|US-011|3h|Accesibles y con stories.
TS-038 — Modal base + focus trap|US-012|4h|Overlay, Escape, focus trap, aria-modal.
TS-039 — Variantes Info/Warning/Error/Success/Confirm|US-012|3h|Con iconos y colores tokenizados.
TS-040 — Toast + ToastProvider + aria-live|US-012|3h|Auto-cierre 4s, cola de toasts.
TS-041 — Popover|US-012|3h|Anclaje y teclado.
TS-042 — Dropdown|US-013|3h|Con teclado y aria.
TS-043 — Tabs|US-013|3h|WAI-ARIA tabs.
TS-044 — Accordion|US-013|2h|Colapsable accesible.
TS-045 — Breadcrumbs|US-013|2h|Con aria-label.
TS-046 — Pagination|US-013|2h|Con navegación y rango.
TS-047 — FormField con error i18n|US-014|2h|Wrapper de label + control + error.
TS-048 — SearchBar con debounce|US-014|2h|Debounce 300ms.
TS-049 — LanguageSwitcher|US-014|2h|Persistencia en i18nextLng.
TS-050 — ThemeSwitcher|US-014|2h|Persistencia en localStorage.
TS-051 — DataTable|US-015|5h|Paginación, sorting, filtros, virtualización >100 filas.
TS-052 — Estado vacío + skeleton loader|US-015|2h|Placeholder y skeleton.
TS-053 — ChartContainer con Recharts|US-015|3h|Container responsive.
TS-054 — FullscreenChartModal|US-015|3h|Botón ampliar a pantalla completa.
TS-055 — MediaPlayer con fullscreen y PiP|US-016|4h|Controles accesibles.
TS-056 — FileUploader drag & drop|US-016|4h|Validación de tipos y tamaños.
TS-057 — Wizard multi-paso|US-016|4h|Con validación por paso.
TS-058 — SidebarMenu plegable|US-017|4h|Secciones expandibles y persistencia.
TS-059 — NotificationCenter|US-017|3h|Lista y badge.
TS-060 — UserMenu|US-017|2h|Perfil, idioma, logout.
TS-061 — SafeAreaView|US-018|1h|env(safe-area-inset-*).
TS-062 — KeyboardAwareView|US-018|2h|visualViewport + padding-bottom dinámico.
TS-063 — PublicHeader|US-018|2h|Header para InitPage/login.
TS-064 — Footer|US-018|2h|Legales, idioma, redes.
TS-065 — OrientationGate|US-018|2h|Decide rama horizontal o vertical.
TS-066 — AppShell con grid|US-019|4h|TopBar + Sidebar + Workspace.
TS-067 — TopBar|US-019|3h|Perfil, idioma, notificaciones, logout.
TS-068 — Sidebar persistente|US-019|3h|Plegado persistido en localStorage.
TS-069 — Workspace|US-019|2h|Overflow auto y scroll propio.
TS-070 — createBrowserRouter + lazyViews|US-020|3h|React.lazy + Suspense.
TS-071 — paths.ts|US-020|1h|Constantes ROUTES.*
TS-072 — routes.config.ts|US-020|2h|Metadata de orientación y guards.
TS-073 — PublicRoute|US-021|1h|Solo sin sesión.
TS-074 — ProtectedRoute|US-021|2h|Requiere sesión.
TS-075 — RoleRoute|US-021|2h|ADMIN, USER, PREMIUM.
TS-076 — OnboardingRoute|US-021|2h|Redirige si perfil incompleto.
TS-077 — useViewport|US-022|3h|width, height, orientation, deviceClass, insets, keyboardInset.
TS-078 — useOrientation|US-022|1h|portrait | landscape.
TS-079 — useDeviceClass|US-022|1h|mobile/tablet/desktop/tv.
TS-080 — useKeyboardInset|US-022|2h|visualViewport.
TS-081 — useSafeAreaInsets|US-022|1h|Insets del dispositivo.
TS-082 — http.ts con Axios|US-023|2h|Base URL desde env.
TS-083 — Interceptor de request|US-023|2h|Adjunta Bearer JWT.
TS-084 — Interceptor de response con refresh|US-023|4h|401 → refresh-token → reintentar.
TS-085 — httpStatus.ts con mapeo a i18n|US-023|2h|AUTH-*, REG-*, REC-*, PWD-*, RATE-*, SYS-*.
TS-086 — tokenStorage|US-023|2h|localStorage versionado.
TS-087 — Hero InitPage horizontal|US-024|3h|Copy, CTA, ilustración.
TS-088 — Beneficios / Cómo funciona|US-024|3h|Secciones explicativas.
TS-089 — Partners + Casos de éxito|US-024|2h|Logos y testimonios.
TS-090 — TopBar pública con CTA|US-024|2h|Botones Contáctenos, Login, Registrar → /contact, /login, /register.
TS-091 — Footer con legales|US-024|2h|Términos, privacidad, idioma, redes.
TS-092 — Maquetar InitPage vertical|US-025|4h|Cards apiladas y 100dvh.
TS-093 — Ajustes 100dvh y safe-area en vertical|US-025|2h|visualViewport.resize.
TS-094 — ContactView horizontal + vertical|US-026|3h|Formulario o datos de contacto.
TS-095 — TermsView + PrivacyView|US-026|3h|Legales en ambas orientaciones.
TS-096 — LoginView horizontal|US-027|3h|Formulario responsive.
TS-097 — LoginView vertical|US-027|2h|Sticky CTA.
TS-098 — Conectar POST /api/auth/login|US-027|3h|Solo espera {token, refreshToken}.
TS-099 — Mapeo de errores a i18n|US-027|3h|AUTH-001, AUTH-002, AUTH-005, AUTH-006, RATE-001.
TS-100 — Enlaces a /register y /recovery|US-027|1h|Navegación con replace.
TS-101 — AuthContext|US-028|3h|Estado, login, logout, refreshProfile.
TS-102 — useRefreshToken|US-028|3h|Sesión deslizante.
TS-103 — Persistencia segura de tokens|US-028|2h|Versionado y limpieza.
TS-104 — LogoutButton|US-029|2h|POST /api/auth/logout.
TS-105 — Limpieza y redirección|US-029|2h|tokenStorage + query cache + navigate replace.
TS-106 — RegisterRequestView horizontal + vertical|US-030|4h|8 campos + validación.
TS-107 — Conectar POST /api/auth/register/request|US-030|3h|Envío de token por email.
TS-108 — Mapeo REG-001/002/003/007|US-030|3h|Mensajes específicos por campo.
TS-109 — Vista de verificación de token|US-031|4h|6 dígitos + TTL 5 min.
TS-110 — Conectar POST /api/auth/register/confirm|US-031|3h|Manejo de token expirado.
TS-111 — Auto-login tras confirmación|US-031|2h|Redirige a Home con sesión activa.
TS-112 — RecoveryRequestView horizontal + vertical|US-032|3h|username + email.
TS-113 — Conectar POST /api/auth/recovery/request|US-032|2h|Envío de token.
TS-114 — Vista token + nueva contraseña|US-033|3h|6 dígitos + nueva + repetir.
TS-115 — Conectar POST /api/auth/recovery/verify|US-033|3h|Actualiza contraseña.
TS-116 — Mapeo REC-001/004|US-033|2h|Intentos excedidos, usuario no coincide.
TS-117 — ChangeMyPassView horizontal + vertical|US-034|3h|Actual, nueva, repetir.
TS-118 — Conectar POST /api/auth/change-my-pass|US-034|3h|Con JWT.
TS-119 — Mapeo PWD-001/002/003|US-034|2h|Mensajes específicos.
TS-120 — HomeView horizontal|US-035|4h|Widgets de resumen.
TS-121 — HomeView vertical|US-035|3h|Bottom sheet y cards apiladas.
TS-122 — Consumir GET /api/test/health|US-035|1h|Estado del sistema.
TS-123 — Placeholder dashboard/resumen|US-035|2h|Preparar para endpoints futuros.
TS-124 — Widget de perfil resumido|US-036|3h|GET /api/auth/get-my-profile.
TS-125 — ProfileView horizontal|US-037|3h|Datos reales sin ofuscar.
TS-126 — ProfileView vertical|US-037|2h|Composición vertical.
TS-127 — Consumir GET /api/auth/get-my-profile|US-037|2h|OWN_DATA_PATHS.
TS-128 — EditProfileView horizontal + vertical|US-038|4h|Formulario precargado.
TS-129 — Formulario RHF + Zod (UpdateMyProfileRequest)|US-038|3h|id, username, email, nombreCompleto, paisId, celular.
TS-130 — Conectar POST /api/auth/update-my-profile|US-038|4h|Validar id/username contra JWT.
TS-131 — Mapeo UPT-0001 + errores|US-038|3h|UPT-0001, REG-002/003/007, AUTH-007, SYS-03 (genérico).
TS-132 — Refetch tras éxito|US-038|2h|Actualizar AuthContext + get-my-profile.
TS-133 — Modal de confirmación (delete account)|US-039|3h|POST /api/auth/delete-account.
TS-134 — Conectar + limpiar sesión + redirigir|US-039|2h|Tras borrado lógico → /login.
TS-135 — NotFound horizontal + vertical|US-040|2h|404.
TS-136 — Forbidden horizontal + vertical|US-040|2h|403.
TS-137 — ServerError horizontal + vertical|US-040|2h|500.
TS-138 — @axe-core/playwright en todas las vistas|US-041|3h|Sin violaciones críticas.
TS-139 — Lighthouse >= 90|US-041|3h|Performance, A11y, Best Practices, SEO.
TS-140 — E2E Playwright 5 configs|US-041|5h|mobile-chrome, mobile-safari, tablet, desktop, tv.
TS-141 — bundle-analyze.mjs + presupuesto|US-041|2h|Reporte de tamaño.
TASKS

echo "   Tasks creadas: ${#ALL_TS_IDS[@]}"

# ---------------------------------------------------------
# 7) AGREGAR AL PROJECT
# ---------------------------------------------------------
echo "==> [6/7] Agregando al Project #$PROJECT_NUMBER..."

ALL_ISSUES="$CAP"
for k in "${!FT[@]}"; do ALL_ISSUES="$ALL_ISSUES ${FT[$k]}"; done
for k in "${!US[@]}"; do ALL_ISSUES="$ALL_ISSUES ${US[$k]}"; done
for id in "${ALL_TS_IDS[@]}"; do ALL_ISSUES="$ALL_ISSUES $id"; done

ADDED=0
for iss in $ALL_ISSUES; do
  if gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" \
    --url "https://github.com/$REPO/issues/$iss" >/dev/null 2>&1; then
    ADDED=$((ADDED + 1))
  fi
done
echo "   $ADDED issues agregados al Project #$PROJECT_NUMBER"

# ---------------------------------------------------------
# 8) VINCULAR JERARQUÍA (sub-issues)
# ---------------------------------------------------------
echo "==> [7/7] Vinculando jerarquía (sub-issues)..."

LINKED=0
FAILED=0

link_sub() {
  local parent=$1; local child=$2
  local attempt=1 max_attempts=3 pid cid

  pid=$(gh issue view "$parent" --repo "$REPO" --json id --jq '.id' 2>/dev/null || echo "")
  cid=$(gh issue view "$child"  --repo "$REPO" --json id --jq '.id' 2>/dev/null || echo "")

  if [ -z "$pid" ] || [ -z "$cid" ]; then
    echo "   ⚠ No se obtuvieron IDs: #$parent → #$child"
    FAILED=$((FAILED + 1)); return 1
  fi

  while [ "$attempt" -le "$max_attempts" ]; do
    if gh api graphql -f query='
      mutation($p:ID!, $c:ID!) {
        addSubIssue(input:{issueId:$p, subIssueId:$c}) { issue { id } }
      }' -f p="$pid" -f c="$cid" >/dev/null 2>&1; then
      LINKED=$((LINKED + 1)); sleep 0.2; return 0
    fi
    sleep 1; attempt=$((attempt + 1))
  done

  echo "   ❌ Falló: #$parent ← #$child"
  FAILED=$((FAILED + 1)); return 1
}

# CAP -> FT
for k in "${!FT[@]}"; do link_sub "$CAP" "${FT[$k]}"; done

# FT -> US
for us_key in "${!US[@]}"; do
  ft_key="${US_PARENT[$us_key]}"
  link_sub "${FT[$ft_key]}" "${US[$us_key]}"
done

# US -> TS
for us_key in "${!TS_BY_US[@]}"; do
  for ts in ${TS_BY_US[$us_key]}; do
    link_sub "${US[$us_key]}" "$ts"
  done
done

echo "   Links OK: $LINKED | Fallidos: $FAILED"

# ---------------------------------------------------------
# 9) Guardar IDs
# ---------------------------------------------------------
cat > "$KANBAN_DIR/kanban-ids.env" <<ENV
CAP=$CAP
ENV
for k in "${!FT[@]}"; do echo "${k//-/_}=${FT[$k]}" >> "$KANBAN_DIR/kanban-ids.env"; done
for k in "${!US[@]}"; do echo "${k//-/_}=${US[$k]}" >> "$KANBAN_DIR/kanban-ids.env"; done
for i in "${!ALL_TS_IDS[@]}"; do echo "TS_$(printf '%03d' $((i+1)))=${ALL_TS_IDS[$i]}" >> "$KANBAN_DIR/kanban-ids.env"; done

echo ""
echo "══════════════════════════════════════════════════════"
echo "  ✅ CAP-01 creada exitosamente"
echo "  - 1 Capability"
echo "  - 9 Features"
echo "  - 41 User Stories"
echo "  - ${#ALL_TS_IDS[@]} Tasks"
echo "  - Sub-issues vinculados: $LINKED (fallidos: $FAILED)"
echo "  IDs guardados en: $KANBAN_DIR/kanban-ids.env"
echo "══════════════════════════════════════════════════════"

if [ "$FAILED" -gt 0 ]; then
  echo ""
  echo "⚠️  $FAILED vinculaciones fallaron. Ejecuta retry-links.sh o vuelve a correr."
  exit 1
fi