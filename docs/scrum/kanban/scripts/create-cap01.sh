#!/usr/bin/env bash
# =========================================================
# create-cap01.sh — Crea CAP-01 + 9 FT + 41 US + 141 TS
# Cada issue incluye: Contexto, Alcance/Entregable,
# Criterios de aceptación (checkboxes) y Dependencias.
# =========================================================
set -euo pipefail

REPO="42mrnobody42-alt/investment-tracker"
PROJECT_OWNER="42mrnobody42-alt"
PROJECT_NUMBER=2
KANBAN_DIR="/prog/datos/investment-tracker/docs/scrum/kanban"

echo "══════════════════════════════════════════════════════"
echo "  Creando CAP-01 (con contexto + criterios)"
echo "══════════════════════════════════════════════════════"

# ---------------------------------------------------------
# 1) LABELS
# ---------------------------------------------------------
echo "==> [1/6] Creando labels..."
for lbl in \
  "capability:6f42c1:Capability del proyecto" \
  "feature:0e8a16:Feature dentro de una capability" \
  "user-story:1d76db:User Story dentro de una feature" \
  "task:fbca04:Tarea técnica (<=4h)" \
  "frontend:5319e7:Relacionado con frontend React" \
  "i18n:c5def5:Internacionalización" \
  "responsive:bfd4f2:Diseño responsive" \
  "design-system:d4c5f9:Componentes del Design System" \
  "storybook:ff8c00:History Book / Storybook" \
  "tokens:c2e0c6:Design tokens y theming" \
  "runtime-assets:f9d0c4:Assets editables post-deploy" \
  "testing:0e8a16:Tests unitarios / integración / E2E" \
  "a11y:1d76db:Accesibilidad WCAG 2.2 AA" \
  "performance:fbca04:Performance y presupuesto" \
  "e2e:5319e7:End-to-end Playwright" \
  "public-page:c5def5:Vista pública pre-login"; do
  IFS=':' read -r name color desc <<< "$lbl"
  gh label create "$name" --repo "$REPO" --color "$color" --description "$desc" --force
done

# ---------------------------------------------------------
# 2) HELPERS
# ---------------------------------------------------------
create_ft() {
  local title="$1" body="$2"
  gh issue create --repo "$REPO" --title "$title" --label "feature,frontend" \
    --body "$body" | grep -oE '[0-9]+$'
}

create_us() {
  local title="$1" labels="$2" body="$3"
  gh issue create --repo "$REPO" --title "$title" --label "$labels" \
    --body "$body" | grep -oE '[0-9]+$'
}

create_ts() {
  # args: title, us_ref, hours, contexto, entregable, criterios (| separated)
  local title="$1" us="$2" hours="$3" ctx="$4" ent="$5" crit="$6"
  local crit_md=""
  IFS='|' read -ra ITEMS <<< "$crit"
  for c in "${ITEMS[@]}"; do
    crit_md+="- [ ] $c"$'\n'
  done
  local body
  body=$(cat <<EOF
## Contexto
$ctx

## Entregable
$ent

## Criterios de aceptación
$crit_md
## Estimación
$hours

## US padre
$us
EOF
)
  gh issue create --repo "$REPO" --title "$title" --label "task,frontend" \
    --body "$body" | grep -oE '[0-9]+$'
}

# ---------------------------------------------------------
# 3) CAPABILITY
# ---------------------------------------------------------
echo "==> [2/6] Creando Capability CAP-01..."
CAP=$(gh issue create --repo "$REPO" \
  --title "CAP-01 — Frontend React: infraestructura, design system, InitPage, autenticación y perfil" \
  --label "capability,frontend" \
  --body "$(cat <<'BODY'
## Contexto
El proyecto Investment Tracker necesita su interfaz de usuario completa. Hoy no
existe frontend: esta capability construye desde cero la SPA React 18 + TypeScript
que consumirá los endpoints del backend (`README.md`, sección Servicios Publicados).

## Alcance
- Setup Vite + React 18 + TS estricto + ESLint/Prettier/Stylelint/Husky/commitlint.
- Storybook (History Book) con stories obligatorias por componente.
- Design System completo (átomos, moléculas, organismos, layout).
- Design tokens + theming (light/dark/high-contrast).
- i18n con namespaces por componente (es/en).
- Assets editables en runtime vía manifest.json + useAsset().
- AppShell (TopBar + Sidebar plegable + Workspace) con OrientationGate.
- Vistas por orientación: `views/horizontal/` y `views/vertical/`.
- Guards (PublicRoute, ProtectedRoute, RoleRoute, OnboardingRoute).
- InitPage público con botones **Contáctenos**, **Login**, **Registrar**.
- Login, logout, registro (2 pasos), recuperación (2 pasos), change-my-pass.
- Home/Dashboard, Perfil (consulta, edición, borrado lógico).
- Vistas de error 404/403/500.
- Testing: Vitest + Testing Library + Playwright (5 configs) + axe-core.
- Calidad: Lighthouse ≥ 90, WCAG 2.2 AA, presupuesto de bundle.

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
- [ ] Edición de perfil contra `POST /api/auth/update-my-profile` (UPT-0001, REG-002/003/007, AUTH-007, SYS-03).
- [ ] Eliminación lógica contra `POST /api/auth/delete-account`.
- [ ] i18n operativo (es/en sin recargar).
- [ ] Responsive horizontal (PC/tablet apaisada/TV) y vertical (móvil/tablet retrato).
- [ ] Storybook con stories de todos los componentes.
- [ ] Playwright 5 configs verdes + a11y sin violaciones críticas.
- [ ] Lighthouse ≥ 90 en Performance, A11y, Best Practices, SEO.

## Dependencias
Backend v0.1.3 desplegado con endpoints `/api/auth/*` y `/api/test/health` funcionando.

**Rama base:** developer
**Rama de trabajo:** feature/CAP-01-frontend-base
BODY
)" | grep -oE '[0-9]+$')
echo "   CAP-01 = #$CAP"

# ---------------------------------------------------------
# 4) FEATURES
# ---------------------------------------------------------
echo "==> [3/6] Creando Features..."
declare -A FT

FT[FT-001]=$(create_ft "FT-001 — Setup e infraestructura base" \
"## Contexto
Sin un proyecto bien configurado no se puede construir nada. Esta feature deja
el frontend listo para trabajar: Vite, TS estricto, linting, Storybook, tests
y variables de entorno.

## Alcance
- Proyecto Vite + React 18 + TS estricto.
- ESLint + Prettier + Stylelint + Husky + commitlint.
- Storybook con decoradores globales.
- Vitest + Playwright (5 configs) + axe-core.
- Estructura src/ y alias de imports.
- Variables de entorno tipadas y proxy /api.

## User Stories
- US-001 — Inicializar proyecto Vite + React 18 + TS
- US-002 — Estructura de carpetas, alias y convenciones
- US-003 — Configurar Storybook
- US-004 — Testing setup (Vitest + Playwright + axe)
- US-005 — Husky + lint-staged + commitlint
- US-006 — Variables de entorno y proxy /api

## Criterios de aceptación
- [ ] \`npm run dev\` levanta sin errores.
- [ ] \`npm run build\` sin warnings.
- [ ] ESLint/Prettier/Stylelint pasan limpios.
- [ ] Storybook arranca con \`npm run storybook\`.
- [ ] \`npx playwright test --list\` muestra 5 proyectos.

## Dependencias
Ninguna. Base para todas las demás features.")

FT[FT-002]=$(create_ft "FT-002 — Design tokens, i18n y assets runtime" \
"## Contexto
Define el lenguaje visual y las bases transversales (tokens, temas, i18n, assets
editables) que el resto de features consumirá sin duplicar valores.

## Alcance
- Design tokens (color, spacing, radius, typography, z-index).
- Temas light/dark/high-contrast con data-theme.
- i18n con namespaces por componente (es/en) + scripts de validación.
- public/assets/ + manifest.json + useAsset().

## User Stories
- US-007 — Design tokens y theming
- US-008 — i18n con namespaces por componente
- US-009 — Assets runtime y useAsset()

## Criterios de aceptación
- [ ] Cambio de tema sin recargar; preferencia persistida.
- [ ] Cambio es↔en sin recargar; persistencia en localStorage.
- [ ] \`node scripts/check-i18n.mjs\` sin claves faltantes.
- [ ] \`useAsset('logo.primary')\` resuelve la ruta desde manifest.json.

## Dependencias
FT-001.")

FT[FT-003]=$(create_ft "FT-003 — Design System: átomos" \
"## Contexto
Átomos reutilizables que componen cualquier vista. Sin ellos, cada vista
reinventaría botones e inputs.

## Alcance
- Botones y controles: Button, Input, Textarea, Select, Checkbox, Radio, Switch.
- Presentación: Icon, Badge, Tag, Avatar, Tooltip, Spinner, Divider, Skeleton.
- Cada uno con .tsx, .module.css, .types.ts, .test.tsx, .stories.tsx, index.ts.

## User Stories
- US-010 — Botones y controles de formulario
- US-011 — Átomos de presentación

## Criterios de aceptación
- [ ] Cada componente tiene story Default + Variants + States + DarkMode.
- [ ] Cobertura de tests ≥ 80%.
- [ ] Accesibilidad: foco visible, roles ARIA correctos.

## Dependencias
FT-001, FT-002.")

FT[FT-004]=$(create_ft "FT-004 — Design System: moléculas" \
"## Contexto
Moléculas que combinan átomos para resolver patrones recurrentes (feedback,
navegación, formularios).

## Alcance
- Feedback: Modal (info/warning/error/success/confirm), Toast, Popover.
- Navegación: Dropdown, Tabs, Accordion, Breadcrumbs, Pagination.
- Formularios: FormField, SearchBar, LanguageSwitcher, ThemeSwitcher.

## User Stories
- US-012 — Feedback (Modal, Toast, Popover)
- US-013 — Navegación (Dropdown, Tabs, Accordion, Breadcrumbs, Pagination)
- US-014 — Formularios (FormField, SearchBar, LanguageSwitcher, ThemeSwitcher)

## Criterios de aceptación
- [ ] Modal base con focus trap y cierre con Escape.
- [ ] Toast con aria-live y auto-cierre 4s.
- [ ] Todos con story y tests.

## Dependencias
FT-003.")

FT[FT-005]=$(create_ft "FT-005 — Design System: organismos y layout" \
"## Contexto
Organismos y componentes de layout que estructuran las vistas de negocio y
resuelven patrones de datos, contenido y estructura.

## Alcance
- Organismos: DataTable, ChartPanel, MediaPlayer, FileUploader, Wizard,
  SidebarMenu, NotificationCenter, UserMenu.
- Layout: SafeAreaView, KeyboardAwareView, PublicHeader, Footer, OrientationGate.

## User Stories
- US-015 — Datos (DataTable, ChartPanel)
- US-016 — Contenido (MediaPlayer, FileUploader, Wizard)
- US-017 — Layout (SidebarMenu, NotificationCenter, UserMenu)
- US-018 — Layout helpers (SafeAreaView, KeyboardAwareView, PublicHeader, Footer, OrientationGate)

## Criterios de aceptación
- [ ] DataTable con paginación, sorting, filtros y virtualización >100 filas.
- [ ] ChartPanel con botón de pantalla completa.
- [ ] OrientationGate decide horizontal vs vertical.

## Dependencias
FT-004.")

FT[FT-006]=$(create_ft "FT-006 — AppShell, routing y guards" \
"## Contexto
Estructura la navegación y la protección de rutas. Define el layout de la
aplicación autenticada y la detección de viewport/orientación.

## Alcance
- AppShell (TopBar + Sidebar plegable + Workspace).
- React Router v6 + lazy + paths + guards.
- Hooks de viewport/orientación/dispositivo.
- Cliente HTTP con interceptores JWT + refresh y mapeo de códigos a i18n.

## User Stories
- US-019 — AppShell
- US-020 — React Router v6 + lazy + paths
- US-021 — Guards
- US-022 — Detección de viewport/orientación/dispositivo
- US-023 — Cliente HTTP con interceptores JWT + refresh

## Criterios de aceptación
- [ ] Vistas autenticadas montan dentro de AppShell.
- [ ] Guards redirigen según sesión y rol.
- [ ] Interceptor refresca token ante 401 y reintenta.

## Dependencias
FT-002, FT-004, FT-005.")

FT[FT-007]=$(create_ft "FT-007 — InitPage público (presentación del proyecto)" \
"## Contexto
Es la primera impresión del producto. Debe explicar qué hace el sistema y llevar
al visitante a Login, Registro o Contacto. Es la única superficie pública
pre-login junto con Login/Registro/Recuperación.

## Alcance
- InitPage horizontal (PC, tablet apaisada, TV): hero, beneficios, cómo funciona,
  partners, casos de éxito, footer.
- InitPage vertical (móvil, tablet retrato) con 100dvh y safe-area.
- TopBar pública con CTA: **Contáctenos**, **Login**, **Registrar**.
- Vistas /contact, /terms, /privacy.

## User Stories
- US-024 — InitPage horizontal
- US-025 — InitPage vertical
- US-026 — Contáctenos y páginas legales

## Criterios de aceptación
- [ ] CTA Contáctenos → /contact.
- [ ] CTA Login → /login.
- [ ] CTA Registrar → /register.
- [ ] Responsive sin scroll horizontal.
- [ ] Lighthouse ≥ 90 en la ruta /.

## Dependencias
FT-002, FT-005, FT-006.")

FT[FT-008]=$(create_ft "FT-008 — Autenticación, registro y recuperación" \
"## Contexto
Cubre todos los flujos de identidad del usuario contra los endpoints reales del
backend. Sin esto, no hay forma de entrar al sistema.

## Alcance
- Login (POST /api/auth/login → solo token + refreshToken).
- AuthContext + useRefreshToken + logout.
- Registro en 2 pasos: register/request + register/confirm.
- Recuperación en 2 pasos: recovery/request + recovery/verify.
- Change-my-pass.

## User Stories
- US-027 — LoginView horizontal + vertical
- US-028 — AuthContext + useRefreshToken + tokenStorage
- US-029 — Logout
- US-030 — Registro paso 1
- US-031 — Registro paso 2
- US-032 — Recuperación paso 1
- US-033 — Recuperación paso 2
- US-034 — Change-my-pass

## Criterios de aceptación
- [ ] Login exitoso guarda tokens y navega a /home.
- [ ] Login fallido muestra mensaje i18n según código (AUTH-001/002, RATE-001).
- [ ] Logout limpia tokens, query cache y navega a /login.
- [ ] Registro en 2 pasos completo.
- [ ] Recuperación en 2 pasos completo.

## Dependencias
FT-002, FT-006.")

FT[FT-009]=$(create_ft "FT-009 — Home, perfil y calidad transversal" \
"## Contexto
Cierra la CAP-01 con las vistas principales del usuario autenticado y el
aseguramiento de calidad (a11y, performance, E2E).

## Alcance
- HomeView (widgets de resumen, health check, perfil resumido).
- ProfileView (consulta).
- EditProfileView (edición).
- Eliminación lógica de cuenta.
- Vistas 404/403/500.
- a11y completa, Lighthouse ≥ 90, E2E Playwright 5 configs.

## User Stories
- US-035 — HomeView
- US-036 — Widget de perfil resumido
- US-037 — ProfileView
- US-038 — EditProfileView
- US-039 — Eliminación lógica de cuenta
- US-040 — Vistas de error 404/403/500
- US-041 — Calidad transversal

## Criterios de aceptación
- [ ] Home muestra salud del sistema y perfil resumido.
- [ ] Edición de perfil con UPT-0001 y manejo de REG-002/003/007.
- [ ] axe-core sin violaciones críticas en todas las vistas.
- [ ] Lighthouse ≥ 90 en Home, Perfil y EditProfile.

## Dependencias
FT-006, FT-008.")

echo "   FT creadas: 001..009"

# ---------------------------------------------------------
# 5) USER STORIES
# ---------------------------------------------------------
echo "==> [4/6] Creando User Stories..."
declare -A US
declare -A US_PARENT

# ---- FT-001 ----
US[US-001]=$(create_us "US-001 — Inicializar proyecto Vite + React 18 + TypeScript estricto" \
  "user-story,frontend" \
"## Contexto
El frontend actual se descarta. Se parte de cero con Vite + React 18 + TS
estricto para asegurar tipado fuerte desde el día uno.

## Alcance
- Inicialización con Vite.
- Configuración TS estricta.
- ESLint + Prettier + Stylelint.

## Tareas
- TS-001 — Inicializar Vite + React 18 + TS (2h)
- TS-002 — ESLint + Prettier + tsconfig estricto (2h)
- TS-003 — Stylelint para CSS Modules (1h)
- TS-004 — Eliminar frontend/ actual (1h)

## Criterios de aceptación
- [ ] \`npm run dev\` levanta sin errores.
- [ ] \`npm run build\` sin warnings.
- [ ] ESLint/Prettier/Stylelint limpios.
- [ ] \`tsconfig.json\` con \`strict: true\`.

## Dependencias
Ninguna.")
US_PARENT[US-001]=FT-001

US[US-002]=$(create_us "US-002 — Estructura de carpetas, alias y convenciones" \
  "user-story,frontend" \
"## Contexto
Sin una estructura clara, cualquier dev o agente pierde tiempo buscando dónde
va cada archivo. Esta US fija la convención.

## Alcance
- Estructura \`src/\` (app, components, views, shared, i18n, styles, types).
- Alias \`@app\`, \`@components\`, \`@views\`, \`@shared\`, \`@i18n\`, \`@styles\`.
- Documentación de convenciones.

## Tareas
- TS-005 — Estructura de carpetas (2h)
- TS-006 — Alias en tsconfig + vite (1h)
- TS-007 — Documentar convenciones en frontend/README.md (1h)

## Criterios de aceptación
- [ ] Carpetas creadas con .gitkeep.
- [ ] Imports con alias funcionan en dev y build.
- [ ] frontend/README.md describe convenciones.

## Dependencias
US-001.")
US_PARENT[US-002]=FT-001

US[US-003]=$(create_us "US-003 — Configurar Storybook (History Book)" \
  "user-story,frontend,storybook" \
"## Contexto
Storybook es la fuente de verdad de los componentes. Sin él, la revisión visual
depende del navegador y de casos manuales.

## Alcance
- Storybook con autodocs.
- Decoradores globales (ThemeProvider, I18nextProvider, Router).
- Story DesignTokens/Overview.
- Build estático versionado en storybook-static/.

## Tareas
- TS-008 — Instalar y configurar Storybook (2h)
- TS-009 — Decoradores globales (2h)
- TS-010 — Story DesignTokens/Overview (2h)
- TS-011 — Build estático (1h)

## Criterios de aceptación
- [ ] \`npm run storybook\` arranca en 6006.
- [ ] Decoradores aplican tema, i18n y router.
- [ ] \`npm run build-storybook\` genera storybook-static/.

## Dependencias
US-001, US-002.")
US_PARENT[US-003]=FT-001

US[US-004]=$(create_us "US-004 — Testing setup (Vitest + Playwright + axe)" \
  "user-story,frontend,testing" \
"## Contexto
Sin infraestructura de tests, la calidad se degrada. Esta US deja todo listo
para escribir tests desde el primer componente.

## Alcance
- Vitest + Testing Library + setup.ts.
- Playwright con 5 proyectos.
- @axe-core/playwright.

## Tareas
- TS-012 — Vitest + Testing Library + setup.ts (2h)
- TS-013 — Playwright 5 proyectos (3h)
- TS-014 — @axe-core/playwright (2h)
- TS-015 — Scripts npm (1h)

## Criterios de aceptación
- [ ] \`npm test\` corre Vitest.
- [ ] \`npx playwright test --list\` lista 5 proyectos.
- [ ] Test a11y base funcional.

## Dependencias
US-001.")
US_PARENT[US-004]=FT-001

US[US-005]=$(create_us "US-005 — Husky + lint-staged + commitlint" \
  "user-story,frontend" \
"## Contexto
Garantiza que los commits cumplen formato y que no se sube código sin lint.
Previene pushes que rompan la DoD.

## Alcance
- pre-commit con lint-staged.
- commit-msg con commitlint.
- pre-push con tests unitarios.

## Tareas
- TS-016 — Husky + pre-commit (2h)
- TS-017 — commitlint + commit-msg (1h)
- TS-018 — pre-push (1h)

## Criterios de aceptación
- [ ] Commit con formato inválido es rechazado.
- [ ] Commit con ESLint fallido es rechazado.
- [ ] Push con tests rotos es rechazado.

## Dependencias
US-001, US-004.")
US_PARENT[US-005]=FT-001

US[US-006]=$(create_us "US-006 — Variables de entorno y proxy /api" \
  "user-story,frontend" \
"## Contexto
El frontend debe apuntar al backend correcto según entorno. En dev, el proxy /api
evita CORS.

## Alcance
- .env.example + .env.development/staging/production.
- vite.config.ts con proxy /api → http://localhost:7700.
- env.d.ts tipado.

## Tareas
- TS-019 — .env.example + .env.* (1h)
- TS-020 — vite.config.ts con proxy /api (2h)
- TS-021 — env.d.ts tipado (1h)

## Criterios de aceptación
- [ ] \`import.meta.env.VITE_API_URL\` tipado.
- [ ] \`fetch('/api/test/health')\` en dev proxya al backend.
- [ ] Build de producción usa VITE_API_URL del .env.production.

## Dependencias
US-001.")
US_PARENT[US-006]=FT-001

# ---- FT-002 ----
US[US-007]=$(create_us "US-007 — Design tokens y theming (light/dark/high-contrast)" \
  "user-story,frontend,tokens" \
"## Contexto
Los tokens son el único lugar donde viven los valores visuales. Sin ellos, el
código se llena de colores hardcodeados y el theming se vuelve imposible.

## Alcance
- tokens.css con color, spacing, radius, typography, z-index.
- themes/light.css, dark.css, high-contrast.css con data-theme.
- ThemeProvider con persistencia.

## Tareas
- TS-022 — tokens.css (3h)
- TS-023 — themes/*.css (3h)
- TS-024 — ThemeProvider con persistencia (2h)

## Criterios de aceptación
- [ ] Cambio de tema sin recargar.
- [ ] Preferencia persistida en localStorage.
- [ ] Tema respeta prefers-color-scheme por defecto.
- [ ] Alto contraste cumple ratio ≥ 7:1.

## Dependencias
FT-001.")
US_PARENT[US-007]=FT-002

US[US-008]=$(create_us "US-008 — i18n con namespaces por componente" \
  "user-story,frontend,i18n" \
"## Contexto
Cero textos hardcodeados. Toda cadena va por i18n con namespaces por componente
para mantener los JSONs ordenados y evitar colisiones de claves.

## Alcance
- react-i18next + LanguageDetector.
- Estructura \`i18n/<locale>/<componente>/\`.
- Scripts check-i18n.mjs y gen-i18n-types.mjs.

## Tareas
- TS-025 — Estructura i18n/<locale>/<componente>/ (3h)
- TS-026 — i18next + LanguageDetector (2h)
- TS-027 — Namespaces + common/errors/validations (2h)
- TS-028 — check-i18n.mjs y gen-i18n-types.mjs (3h)

## Criterios de aceptación
- [ ] Cambio es↔en sin recargar.
- [ ] \`check-i18n.mjs\` falla si falta una clave.
- [ ] common/errors.json incluye claves AUTH-*, REG-*, REC-*, PWD-*, RATE-*, SYS-*.

## Dependencias
FT-001.")
US_PARENT[US-008]=FT-002

US[US-009]=$(create_us "US-009 — Assets runtime y useAsset()" \
  "user-story,frontend,runtime-assets" \
"## Contexto
Logos e imágenes corporativas deben poder reemplazarse sin recompilar el
bundle. Esto exige servir assets desde public/ y resolverlos por manifest.

## Alcance
- public/assets/ con logos, imágenes por dominio, iconos, fuentes.
- manifest.json + gen-assets-manifest.mjs.
- useAsset('clave').

## Tareas
- TS-029 — public/assets/ estructura + placeholders (2h)
- TS-030 — manifest.json + gen-assets-manifest.mjs (2h)
- TS-031 — useAsset hook (1h)
- TS-032 — fonts.css con @font-face swap (1h)

## Criterios de aceptación
- [ ] \`useAsset('logo.primary')\` devuelve la ruta correcta.
- [ ] Reemplazar un logo en public/assets/ se refleja sin rebuild.
- [ ] Inter self-hosted con font-display: swap.

## Dependencias
FT-001.")
US_PARENT[US-009]=FT-002

# ---- FT-003 ----
US[US-010]=$(create_us "US-010 — Átomos: botones y controles de formulario" \
  "user-story,frontend,design-system,storybook" \
"## Contexto
Los controles de formulario son el punto de contacto principal con el usuario.
Deben ser accesibles, tipados y reutilizables.

## Alcance
- Button (primary/secondary/ghost/danger, loading, disabled).
- Input, Textarea, Select, Checkbox, Radio, Switch.

## Tareas
- TS-033 — Button con variantes (3h)
- TS-034 — Input y Textarea (2h)
- TS-035 — Select, Checkbox, Radio, Switch (3h)

## Criterios de aceptación
- [ ] Cada componente tiene .tsx, .module.css, .types.ts, .test.tsx, .stories.tsx, index.ts.
- [ ] Accesibles con label, error y estado disabled.
- [ ] Cobertura ≥ 80% en cada uno.

## Dependencias
FT-002.")
US_PARENT[US-010]=FT-003

US[US-011]=$(create_us "US-011 — Átomos: presentación (Icon, Badge, Tag, Avatar, Tooltip, Spinner, Divider, Skeleton)" \
  "user-story,frontend,design-system,storybook" \
"## Contexto
Átomos de presentación usados en todas las vistas para indicar estados, iconos
y placeholders.

## Alcance
- Icon, Badge, Tag, Avatar, Tooltip, Spinner, Divider, Skeleton.

## Tareas
- TS-036 — Icon, Badge, Tag, Avatar (3h)
- TS-037 — Tooltip, Spinner, Divider, Skeleton (3h)

## Criterios de aceptación
- [ ] Tooltip accesible por teclado.
- [ ] Spinner con aria-label.
- [ ] Todos con story DarkMode.

## Dependencias
FT-002.")
US_PARENT[US-011]=FT-003

# ---- FT-004 ----
US[US-012]=$(create_us "US-012 — Moléculas: feedback (Modal, Toast, Popover)" \
  "user-story,frontend,design-system,storybook,a11y" \
"## Contexto
Los feedbacks informan al usuario de resultados y errores. Deben ser accesibles
y no bloquear la interacción más de lo necesario.

## Alcance
- Modal con variantes info/warning/error/success/confirm.
- Toast con aria-live y auto-cierre.
- Popover anclado.

## Tareas
- TS-038 — Modal base + focus trap (4h)
- TS-039 — Variantes Info/Warning/Error/Success/Confirm (3h)
- TS-040 — Toast + ToastProvider + aria-live (3h)
- TS-041 — Popover (3h)

## Criterios de aceptación
- [ ] Modal cierra con Escape y atrapa el foco.
- [ ] Toast se anuncia con aria-live.
- [ ] Popover reposiciona en resize.

## Dependencias
FT-003.")
US_PARENT[US-012]=FT-004

US[US-013]=$(create_us "US-013 — Moléculas: navegación (Dropdown, Tabs, Accordion, Breadcrumbs, Pagination)" \
  "user-story,frontend,design-system,storybook" \
"## Contexto
Patrones de navegación reutilizables entre vistas.

## Alcance
- Dropdown, Tabs, Accordion, Breadcrumbs, Pagination.

## Tareas
- TS-042 — Dropdown (3h)
- TS-043 — Tabs (3h)
- TS-044 — Accordion (2h)
- TS-045 — Breadcrumbs (2h)
- TS-046 — Pagination (2h)

## Criterios de aceptación
- [ ] Tabs con WAI-ARIA roles.
- [ ] Pagination con navegación por teclado.
- [ ] Todos con story y tests.

## Dependencias
FT-003.")
US_PARENT[US-013]=FT-004

US[US-014]=$(create_us "US-014 — Moléculas: formularios (FormField, SearchBar, LanguageSwitcher, ThemeSwitcher)" \
  "user-story,frontend,design-system,storybook,i18n" \
"## Contexto
Componentes específicos para formularios y preferencias del usuario.

## Alcance
- FormField (label + control + error i18n).
- SearchBar con debounce.
- LanguageSwitcher (persistencia).
- ThemeSwitcher (persistencia).

## Tareas
- TS-047 — FormField con error i18n (2h)
- TS-048 — SearchBar con debounce (2h)
- TS-049 — LanguageSwitcher (2h)
- TS-050 — ThemeSwitcher (2h)

## Criterios de aceptación
- [ ] FormField traduce el error vía i18n.
- [ ] SearchBar con debounce 300ms.
- [ ] Switchers persisten preferencia.

## Dependencias
FT-003.")
US_PARENT[US-014]=FT-004

# ---- FT-005 ----
US[US-015]=$(create_us "US-015 — Organismos: datos (DataTable, ChartPanel)" \
  "user-story,frontend,design-system,storybook" \
"## Contexto
Tablas y gráficos son la superficie principal del negocio. Deben manejar
grandes volúmenes y estados de carga.

## Alcance
- DataTable con paginación, sorting, filtros, virtualización >100 filas.
- ChartPanel con Recharts y modal fullscreen.

## Tareas
- TS-051 — DataTable (5h)
- TS-052 — Estado vacío + skeleton (2h)
- TS-053 — ChartContainer con Recharts (3h)
- TS-054 — FullscreenChartModal (3h)

## Criterios de aceptación
- [ ] DataTable virtualiza >100 filas sin lag.
- [ ] Estados loading, empty y error.
- [ ] ChartPanel expone botón fullscreen.

## Dependencias
FT-004.")
US_PARENT[US-015]=FT-005

US[US-016]=$(create_us "US-016 — Organismos: contenido (MediaPlayer, FileUploader, Wizard)" \
  "user-story,frontend,design-system,storybook" \
"## Contexto
Componentes para reproducir contenido, subir archivos y guiar al usuario en
procesos multi-paso.

## Alcance
- MediaPlayer con fullscreen y PiP.
- FileUploader con drag & drop y validación.
- Wizard con validación por paso.

## Tareas
- TS-055 — MediaPlayer (4h)
- TS-056 — FileUploader (4h)
- TS-057 — Wizard multi-paso (4h)

## Criterios de aceptación
- [ ] MediaPlayer reproduce con controles accesibles.
- [ ] FileUploader valida tipos y tamaños.
- [ ] Wizard bloquea paso siguiente si hay error.

## Dependencias
FT-004.")
US_PARENT[US-016]=FT-005

US[US-017]=$(create_us "US-017 — Organismos: layout (SidebarMenu, NotificationCenter, UserMenu)" \
  "user-story,frontend,design-system,storybook" \
"## Contexto
Estructuran la navegación y las acciones del usuario en la aplicación autenticada.

## Alcance
- SidebarMenu plegable con persistencia.
- NotificationCenter con badge.
- UserMenu con perfil, idioma y logout.

## Tareas
- TS-058 — SidebarMenu plegable (4h)
- TS-059 — NotificationCenter (3h)
- TS-060 — UserMenu (2h)

## Criterios de aceptación
- [ ] SidebarMenu persiste estado plegado.
- [ ] NotificationCenter muestra badge de no leídas.
- [ ] UserMenu con logout que limpia sesión.

## Dependencias
FT-004.")
US_PARENT[US-017]=FT-005

US[US-018]=$(create_us "US-018 — Layout helpers (SafeAreaView, KeyboardAwareView, PublicHeader, Footer, OrientationGate)" \
  "user-story,frontend,design-system,responsive" \
"## Contexto
Componentes que resuelven problemas específicos de móvil (notch, teclado),
estructura pública (header/footer) y detección de orientación.

## Alcance
- SafeAreaView, KeyboardAwareView.
- PublicHeader, Footer.
- OrientationGate.

## Tareas
- TS-061 — SafeAreaView (1h)
- TS-062 — KeyboardAwareView (2h)
- TS-063 — PublicHeader (2h)
- TS-064 — Footer (2h)
- TS-065 — OrientationGate (2h)

## Criterios de aceptación
- [ ] KeyboardAwareView ajusta padding al abrir teclado virtual.
- [ ] OrientationGate decide horizontal vs vertical según useViewport.
- [ ] PublicHeader con CTA a /contact, /login, /register.

## Dependencias
FT-004.")
US_PARENT[US-018]=FT-005

# ---- FT-006 ----
US[US-019]=$(create_us "US-019 — AppShell (TopBar + Sidebar + Workspace)" \
  "user-story,frontend,responsive" \
"## Contexto
Toda vista autenticada se monta dentro de AppShell. Es el layout obligatorio
según agente-frontend.md §3.2.

## Alcance
- AppShell con grid responsive.
- TopBar informativa.
- Sidebar plegable con persistencia.
- Workspace con scroll propio.

## Tareas
- TS-066 — AppShell con grid (4h)
- TS-067 — TopBar (3h)
- TS-068 — Sidebar persistente (3h)
- TS-069 — Workspace (2h)

## Criterios de aceptación
- [ ] 100dvh sin scroll del body.
- [ ] Sidebar persiste estado plegado.
- [ ] Workspace tiene scroll propio.

## Dependencias
FT-002, FT-005.")
US_PARENT[US-019]=FT-006

US[US-020]=$(create_us "US-020 — React Router v6 + lazy + paths" \
  "user-story,frontend" \
"## Contexto
Define la navegación y el code splitting por ruta.

## Alcance
- createBrowserRouter con lazy loading.
- paths.ts con constantes ROUTES.*.
- routes.config.ts con metadata de orientación.

## Tareas
- TS-070 — createBrowserRouter + lazyViews (3h)
- TS-071 — paths.ts (1h)
- TS-072 — routes.config.ts (2h)

## Criterios de aceptación
- [ ] Cada vista se carga con React.lazy.
- [ ] Suspense muestra skeleton.
- [ ] routes.config.ts declara orientación por ruta.

## Dependencias
FT-005.")
US_PARENT[US-020]=FT-006

US[US-021]=$(create_us "US-021 — Guards (Public/Protected/Role/Onboarding)" \
  "user-story,frontend" \
"## Contexto
Protegen las rutas según sesión, rol y estado de perfil.

## Alcance
- PublicRoute, ProtectedRoute, RoleRoute, OnboardingRoute.

## Tareas
- TS-073 — PublicRoute (1h)
- TS-074 — ProtectedRoute (2h)
- TS-075 — RoleRoute (2h)
- TS-076 — OnboardingRoute (2h)

## Criterios de aceptación
- [ ] PublicRoute redirige a /home si hay sesión.
- [ ] ProtectedRoute redirige a /login si no hay sesión.
- [ ] RoleRoute bloquea según ADMIN/USER/PREMIUM.

## Dependencias
US-020.")
US_PARENT[US-021]=FT-006

US[US-022]=$(create_us "US-022 — Detección de viewport, orientación y dispositivo" \
  "user-story,frontend,responsive" \
"## Contexto
Centraliza la detección de tamaño y orientación. Base para la lógica
horizontal/vertical.

## Alcance
- useViewport, useOrientation, useDeviceClass.
- useKeyboardInset, useSafeAreaInsets.

## Tareas
- TS-077 — useViewport (3h)
- TS-078 — useOrientation (1h)
- TS-079 — useDeviceClass (1h)
- TS-080 — useKeyboardInset (2h)
- TS-081 — useSafeAreaInsets (1h)

## Criterios de aceptación
- [ ] useViewport expone width, height, orientation, deviceClass.
- [ ] useKeyboardInset actualiza en visualViewport.resize.
- [ ] Todos los hooks son SSR-safe.

## Dependencias
FT-005.")
US_PARENT[US-022]=FT-006

US[US-023]=$(create_us "US-023 — Cliente HTTP con interceptores JWT + refresh" \
  "user-story,frontend" \
"## Contexto
Un único cliente HTTP evita duplicación y garantiza que todas las llamadas
lleven JWT y refresquen token automáticamente.

## Alcance
- http.ts con Axios.
- Interceptor de request (adjunta Bearer JWT).
- Interceptor de response (401 → refresh → reintentar).
- httpStatus.ts con mapeo de códigos a i18n.
- tokenStorage.

## Tareas
- TS-082 — http.ts con Axios (2h)
- TS-083 — Interceptor de request (2h)
- TS-084 — Interceptor de response con refresh (4h)
- TS-085 — httpStatus.ts con mapeo a i18n (2h)
- TS-086 — tokenStorage (2h)

## Criterios de aceptación
- [ ] Ante 401, refresca token y reintenta una vez.
- [ ] Si el refresh falla, limpia sesión y redirige a /login.
- [ ] Códigos AUTH-*, REG-*, etc. mapean a claves i18n.

## Dependencias
US-021.")
US_PARENT[US-023]=FT-006

# ---- FT-007 ----
US[US-024]=$(create_us "US-024 — InitPage horizontal (presentación del proyecto)" \
  "user-story,frontend,public-page,responsive" \
"## Contexto
Es la primera impresión del producto para visitantes pre-login. Explica qué
hace el sistema y lleva al visitante a las acciones clave.

## Alcance
- Hero, Beneficios, Cómo funciona, Partners, Casos de éxito.
- TopBar pública con CTA: **Contáctenos**, **Login**, **Registrar**.
- Footer con legales, idioma y redes.

## Tareas
- TS-087 — Hero InitPage horizontal (3h)
- TS-088 — Beneficios / Cómo funciona (3h)
- TS-089 — Partners + Casos de éxito (2h)
- TS-090 — TopBar pública con CTA (2h)
- TS-091 — Footer con legales (2h)

## Criterios de aceptación
- [ ] CTA **Contáctenos** → /contact.
- [ ] CTA **Login** → /login.
- [ ] CTA **Registrar** → /register.
- [ ] Sin scroll horizontal en 1920x1080 y 1280x800.

## Dependencias
FT-005, FT-006.")
US_PARENT[US-024]=FT-007

US[US-025]=$(create_us "US-025 — InitPage vertical (móvil y tablet retrato)" \
  "user-story,frontend,public-page,responsive" \
"## Contexto
La versión móvil de InitPage debe caber en 100dvh, respetar notch y evitar
scroll innecesario.

## Alcance
- Composición vertical con cards apiladas.
- 100dvh y safe-area.
- Teclado virtual.

## Tareas
- TS-092 — Maquetar InitPage vertical (4h)
- TS-093 — Ajustes 100dvh y safe-area en vertical (2h)

## Criterios de aceptación
- [ ] Sin scroll horizontal en 375x667 y 414x896.
- [ ] Respeta env(safe-area-inset-*).
- [ ] CTA accesibles a una mano.

## Dependencias
US-024.")
US_PARENT[US-025]=FT-007

US[US-026]=$(create_us "US-026 — Contáctenos y páginas legales" \
  "user-story,frontend,public-page" \
"## Contexto
Los CTA de InitPage apuntan a páginas que deben existir. Esta US las crea.

## Alcance
- /contact (formulario o datos de contacto).
- /terms, /privacy.

## Tareas
- TS-094 — ContactView horizontal + vertical (3h)
- TS-095 — TermsView + PrivacyView (3h)

## Criterios de aceptación
- [ ] /contact renderiza en ambas orientaciones.
- [ ] /terms y /privacy con contenido de ejemplo.
- [ ] Enlaces desde Footer funcionan.

## Dependencias
US-024.")
US_PARENT[US-026]=FT-007

# ---- FT-008 ----
US[US-027]=$(create_us "US-027 — LoginView horizontal + vertical" \
  "user-story,frontend,responsive" \
"## Contexto
Es la puerta de entrada al sistema. Debe funcionar contra el endpoint real y
manejar todos los códigos de error del backend.

## Alcance
- Vista de Login horizontal + vertical.
- Consumo de POST /api/auth/login (solo token + refreshToken).
- Manejo de errores AUTH-001, AUTH-002, AUTH-005, AUTH-006, RATE-001.
- Enlaces a /register y /recovery.

## Tareas
- TS-096 — LoginView horizontal (3h)
- TS-097 — LoginView vertical (2h)
- TS-098 — Conectar POST /api/auth/login (3h)
- TS-099 — Mapeo de errores a i18n (3h)
- TS-100 — Enlaces a /register y /recovery (1h)

## Criterios de aceptación
- [ ] Login exitoso guarda tokens y navega a /home.
- [ ] AUTH-001 muestra "Credenciales inválidas" en el idioma activo.
- [ ] AUTH-002 muestra "Cuenta bloqueada".
- [ ] RATE-001 muestra "Demasiadas peticiones".

## Dependencias
FT-006.")
US_PARENT[US-027]=FT-008

US[US-028]=$(create_us "US-028 — AuthContext + useRefreshToken + tokenStorage" \
  "user-story,frontend" \
"## Contexto
Centraliza el estado de sesión. Todos los componentes consumen AuthContext,
no leen tokens directamente.

## Alcance
- AuthContext con login/logout/refreshProfile.
- useRefreshToken (sesión deslizante).
- Persistencia segura de tokens.

## Tareas
- TS-101 — AuthContext (3h)
- TS-102 — useRefreshToken (3h)
- TS-103 — Persistencia segura de tokens (2h)

## Criterios de aceptación
- [ ] AuthContext expone user, token, login, logout, refreshProfile.
- [ ] useRefreshToken renueva antes de expirar.
- [ ] Tokens persistidos con versionado.

## Dependencias
US-027.")
US_PARENT[US-028]=FT-008

US[US-029]=$(create_us "US-029 — Logout y cierre de sesión" \
  "user-story,frontend" \
"## Contexto
Cierra sesión limpiando todos los rastros locales y notificando al backend.

## Alcance
- LogoutButton.
- Limpieza de tokens, query cache y navegación a /login.

## Tareas
- TS-104 — LogoutButton (2h)
- TS-105 — Limpieza y redirección (2h)

## Criterios de aceptación
- [ ] Llama a POST /api/auth/logout.
- [ ] Limpia tokens y query cache.
- [ ] Redirige a /login con replace (sin atrás).

## Dependencias
US-028.")
US_PARENT[US-029]=FT-008

US[US-030]=$(create_us "US-030 — Registro paso 1: POST /api/auth/register/request" \
  "user-story,frontend,responsive" \
"## Contexto
Registro en dos pasos con confirmación por email. El primer paso captura los
datos y dispara el envío del token de 6 dígitos.

## Alcance
- Formulario con: username, email, nombreCompleto, password, repeatPassword,
  celular, paisId, plan.
- Manejo de REG-001, REG-002, REG-003, REG-007.

## Tareas
- TS-106 — RegisterRequestView horizontal + vertical (4h)
- TS-107 — Conectar POST /api/auth/register/request (3h)
- TS-108 — Mapeo REG-001/002/003/007 (3h)

## Criterios de aceptación
- [ ] Envío exitoso navega al paso 2.
- [ ] REG-001 marca el username en rojo con mensaje i18n.
- [ ] REG-002 marca el email en rojo con mensaje i18n.
- [ ] REG-003 marca el celular en rojo con mensaje i18n.
- [ ] REG-007 muestra "País no válido".

## Dependencias
US-027.")
US_PARENT[US-030]=FT-008

US[US-031]=$(create_us "US-031 — Registro paso 2: POST /api/auth/register/confirm" \
  "user-story,frontend,responsive" \
"## Contexto
Segundo paso: verificación del token de 6 dígitos y creación efectiva del usuario.

## Alcance
- Vista de verificación con input de 6 dígitos.
- Consumo de POST /api/auth/register/confirm.
- Auto-login tras confirmación.

## Tareas
- TS-109 — Vista de verificación de token (4h)
- TS-110 — Conectar POST /api/auth/register/confirm (3h)
- TS-111 — Auto-login tras confirmación (2h)

## Criterios de aceptación
- [ ] Token inválido muestra mensaje.
- [ ] Token expirado (TTL 5 min) muestra mensaje y ofrece reenviar.
- [ ] Tras confirmación, redirige a /home con sesión activa.

## Dependencias
US-030.")
US_PARENT[US-031]=FT-008

US[US-032]=$(create_us "US-032 — Recuperación paso 1: POST /api/auth/recovery/request" \
  "user-story,frontend,responsive" \
"## Contexto
Primer paso de recuperación: solicita el token de 6 dígitos.

## Alcance
- Formulario username + email.
- Consumo de POST /api/auth/recovery/request.

## Tareas
- TS-112 — RecoveryRequestView horizontal + vertical (3h)
- TS-113 — Conectar POST /api/auth/recovery/request (2h)

## Criterios de aceptación
- [ ] Envío exitoso navega al paso 2.
- [ ] Error de red muestra mensaje i18n.

## Dependencias
US-027.")
US_PARENT[US-032]=FT-008

US[US-033]=$(create_us "US-033 — Recuperación paso 2: POST /api/auth/recovery/verify" \
  "user-story,frontend,responsive" \
"## Contexto
Segundo paso: verifica el token y cambia la contraseña.

## Alcance
- Inputs: token (6 dígitos), nuevoPassword, repetir.
- Consumo de POST /api/auth/recovery/verify.
- Manejo de REC-001, REC-004, PWD-001/002/003.

## Tareas
- TS-114 — Vista token + nueva contraseña (3h)
- TS-115 — Conectar POST /api/auth/recovery/verify (3h)
- TS-116 — Mapeo REC-001/004 (2h)

## Criterios de aceptación
- [ ] REC-001 muestra "Demasiados intentos".
- [ ] REC-004 muestra "Usuario no coincide".
- [ ] PWD-001/002/003 con mensajes específicos.
- [ ] Éxito redirige a /login.

## Dependencias
US-032.")
US_PARENT[US-033]=FT-008

US[US-034]=$(create_us "US-034 — Cambio de contraseña propia: POST /api/auth/change-my-pass" \
  "user-story,frontend,responsive" \
"## Contexto
El usuario autenticado puede cambiar su contraseña validando la actual.

## Alcance
- Formulario: actualPassword, nuevoPassword, repetirNuevoPassword.
- Consumo de POST /api/auth/change-my-pass.
- Manejo de PWD-001/002/003.

## Tareas
- TS-117 — ChangeMyPassView horizontal + vertical (3h)
- TS-118 — Conectar POST /api/auth/change-my-pass (3h)
- TS-119 — Mapeo PWD-001/002/003 (2h)

## Criterios de aceptación
- [ ] PWD-003 muestra "Contraseña actual incorrecta".
- [ ] PWD-001 muestra "No coinciden".
- [ ] PWD-002 muestra criterios de la nueva.
- [ ] Éxito muestra toast de confirmación.

## Dependencias
US-028.")
US_PARENT[US-034]=FT-008

# ---- FT-009 ----
US[US-035]=$(create_us "US-035 — HomeView horizontal + vertical" \
  "user-story,frontend,responsive" \
"## Contexto
Es la pantalla principal post-login. Muestra widgets de resumen y estado del
sistema.

## Alcance
- HomeView horizontal + vertical.
- Consumo de GET /api/test/health.
- Placeholders para futuros endpoints de negocio.

## Tareas
- TS-120 — HomeView horizontal (4h)
- TS-121 — HomeView vertical (3h)
- TS-122 — Consumir GET /api/test/health (1h)
- TS-123 — Placeholder dashboard/resumen (2h)

## Criterios de aceptación
- [ ] Muestra estado del sistema (health check).
- [ ] Sin scroll horizontal en 375px.
- [ ] Placeholders listos para endpoints futuros.

## Dependencias
FT-006, FT-008.")
US_PARENT[US-035]=FT-009

US[US-036]=$(create_us "US-036 — Widget de perfil resumido en Home" \
  "user-story,frontend" \
"## Contexto
Muestra el perfil del usuario autenticado en la Home como acceso rápido.

## Alcance
- Widget con GET /api/auth/get-my-profile.

## Tareas
- TS-124 — Widget de perfil resumido (3h)

## Criterios de aceptación
- [ ] Consume GET /api/auth/get-my-profile.
- [ ] Muestra datos reales (OWN_DATA_PATHS).
- [ ] Enlace a /profile.

## Dependencias
US-035.")
US_PARENT[US-036]=FT-009

US[US-037]=$(create_us "US-037 — ProfileView horizontal + vertical" \
  "user-story,frontend,responsive" \
"## Contexto
Consulta de perfil del usuario autenticado. Datos reales sin ofuscar.

## Alcance
- ProfileView horizontal + vertical.
- GET /api/auth/get-my-profile.

## Tareas
- TS-125 — ProfileView horizontal (3h)
- TS-126 — ProfileView vertical (2h)
- TS-127 — Consumir GET /api/auth/get-my-profile (2h)

## Criterios de aceptación
- [ ] Muestra id, username, email, nombreCompleto, celular, pais, activo,
      ultimoLogin, createdAt.
- [ ] Sin ofuscar (OWN_DATA_PATHS).
- [ ] Botón de edición navega a /profile/edit.

## Dependencias
US-028.")
US_PARENT[US-037]=FT-009

US[US-038]=$(create_us "US-038 — EditProfileView horizontal + vertical" \
  "user-story,frontend,responsive" \
"## Contexto
Edición del perfil propio. Debe validar id/username contra el JWT y manejar
todos los códigos del backend.

## Alcance
- UpdateMyProfileRequest: id, username, email, nombreCompleto, paisId, celular.
- POST /api/auth/update-my-profile.
- UPT-0001 (éxito), REG-002/003/007, AUTH-007, SYS-03.

## Tareas
- TS-128 — EditProfileView horizontal + vertical (4h)
- TS-129 — Formulario RHF + Zod (3h)
- TS-130 — Conectar POST /api/auth/update-my-profile (4h)
- TS-131 — Mapeo UPT-0001 + errores (3h)
- TS-132 — Refetch tras éxito (2h)

## Criterios de aceptación
- [ ] UPT-0001 muestra toast de éxito y refetch del perfil.
- [ ] REG-002/003 con mensajes específicos.
- [ ] AUTH-007 al intentar editar otro usuario.
- [ ] SYS-03 muestra mensaje genérico (no detalle).
- [ ] Case de email/nombreCompleto preservado.

## Dependencias
US-037.")
US_PARENT[US-038]=FT-009

US[US-039]=$(create_us "US-039 — Eliminación lógica de cuenta" \
  "user-story,frontend" \
"## Contexto
El usuario puede darse de baja lógica (activo=false) desde su perfil.

## Alcance
- Modal de confirmación.
- POST /api/auth/delete-account.
- Limpieza y redirección.

## Tareas
- TS-133 — Modal de confirmación (3h)
- TS-134 — Conectar + limpiar sesión + redirigir (2h)

## Criterios de aceptación
- [ ] Modal advierte consecuencias.
- [ ] Tras borrado, limpia sesión y redirige a /login.
- [ ] No permite cancelar el borrado tras confirmarlo.

## Dependencias
US-037.")
US_PARENT[US-039]=FT-009

US[US-040]=$(create_us "US-040 — Vistas de error 404/403/500 (horizontal + vertical)" \
  "user-story,frontend,responsive" \
"## Contexto
Vistas de error consistentes para los estados más comunes.

## Alcance
- NotFound (404), Forbidden (403), ServerError (500).
- Ambas orientaciones.

## Tareas
- TS-135 — NotFound horizontal + vertical (2h)
- TS-136 — Forbidden horizontal + vertical (2h)
- TS-137 — ServerError horizontal + vertical (2h)

## Criterios de aceptación
- [ ] Cada vista con CTA contextual (Home, Login).
- [ ] i18n en es/en.
- [ ] Sin scroll horizontal en móvil.

## Dependencias
FT-006.")
US_PARENT[US-040]=FT-009

US[US-041]=$(create_us "US-041 — Calidad transversal (a11y, performance, E2E)" \
  "user-story,frontend,a11y,performance,e2e" \
"## Contexto
Cierra la CAP-01 con aseguramiento de calidad medible.

## Alcance
- Auditoría a11y con axe-core.
- Lighthouse ≥ 90.
- E2E Playwright 5 configs.

## Tareas
- TS-138 — @axe-core/playwright en todas las vistas (3h)
- TS-139 — Lighthouse ≥ 90 (3h)
- TS-140 — E2E Playwright 5 configs (5h)
- TS-141 — bundle-analyze.mjs + presupuesto (2h)

## Criterios de aceptación
- [ ] axe sin violaciones críticas en /, /login, /home, /profile.
- [ ] Lighthouse ≥ 90 en las 4 categorías.
- [ ] Playwright verde en las 5 configs.

## Dependencias
Todas las US anteriores.")
US_PARENT[US-041]=FT-009

echo "   US creadas: 001..041"

# ---------------------------------------------------------
# 6) TASKS
# ---------------------------------------------------------
echo "==> [5/6] Creando Tasks..."
declare -a ALL_TS_IDS=()
declare -A TS_BY_US

# Formato: "title|us|hours|contexto|entregable|criterio1|criterio2|criterio3"
while IFS='|' read -r title us hours ctx ent c1 c2 c3; do
  [ -z "$title" ] && continue
  crit="$c1|$c2|$c3"
  id=$(create_ts "$title" "$us" "$hours" "$ctx" "$ent" "$crit")
  ALL_TS_IDS+=("$id")
  TS_BY_US[$us]="$id ${TS_BY_US[$us]:-}"
done <<'TASKS'
TS-001 — Inicializar Vite + React 18 + TS|US-001|2h|Arranque del frontend desde cero.|frontend/ con Vite + React 18 + TS funcional.|npm create vite ejecutado|npm install sin errores|npm run dev levanta
TS-002 — ESLint + Prettier + tsconfig estricto|US-001|2h|Calidad de código desde el primer commit.|.eslintrc.cjs, .prettierrc, tsconfig.json.|ESLint limpio|Prettier configurado|TS strict true
TS-003 — Stylelint para CSS Modules|US-001|1h|Reglas CSS consistentes.|.stylelintrc.json + reglas para CSS Modules.|Stylelint corre sin errores|Reglas para CSS Modules|Integrado con npm script
TS-004 — Eliminar frontend/ actual|US-001|1h|Descartar código legacy sin afectar Docker.|frontend/ viejo eliminado y referencias verificadas.|rm -rf frontend ejecutado|Dockerfile.frontend verificado|docker-compose.yml verificado
TS-005 — Estructura de carpetas src/|US-002|2h|Base de la organización del código.|src/{app,components,views,shared,i18n,styles,types}/.|Carpetas creadas con .gitkeep|README.md con layout|Sin archivos huérfanos
TS-006 — Alias de imports|US-002|1h|Imports cortos y consistentes.|Alias en tsconfig.paths.json + vite.config.ts.|@app @components @views @shared @i18n @styles funcionan|En dev y build|Documentados
TS-007 — Documentar convenciones en frontend/README.md|US-002|1h|Guía para cualquier dev/agente.|frontend/README.md con convenciones.|Nombres, exports y orden documentados|Ejemplos por tipo|Referencia a agente-frontend.md
TS-008 — Instalar y configurar Storybook|US-003|2h|History Book operativo.|.storybook/main.ts + preview.ts.|@storybook/react-vite instalado|autodocs activo|npm run storybook levanta en 6006
TS-009 — Decoradores globales de Storybook|US-003|2h|Todas las stories heredan providers.|.storybook/preview.ts.|ThemeProvider|I18nextProvider|Router
TS-010 — Story DesignTokens/Overview|US-003|2h|Documentar tokens visuales.|Story DesignTokens/Overview.|Muestra tokens y temas|Con paletas|Con tipografía
TS-011 — Build estático de Storybook|US-003|1h|Publicar Storybook versionado.|storybook-static/ con build.|npm run build-storybook genera estático|Sin warnings|Versionable en git
TS-012 — Vitest + Testing Library + setup.ts|US-004|2h|Tests unitarios desde el inicio.|vitest.config.ts + setup.ts.|npm test corre Vitest|Testing Library integrada|Coverage mínimo 80%
TS-013 — Playwright 5 proyectos|US-004|3h|E2E en 5 configs.|playwright.config.ts con 5 proyectos.|mobile-chrome mobile-safari tablet desktop tv|Helpers comunes|Traces y screenshots activos
TS-014 — @axe-core/playwright|US-004|2h|Auditoría a11y automatizada.|Helper de axe reutilizable.|@axe-core/playwright instalado|Helper runA11y() disponible|Test base verde
TS-015 — Scripts npm de test|US-004|1h|Comandos unificados.|package.json scripts.|test test:unit test:e2e test:a11y|test:watch|test:coverage
TS-016 — Husky + pre-commit|US-005|2h|Bloquear commits rotos.|.husky/pre-commit con lint-staged.|Husky instalado|lint-staged configurado|Commit con lint roto rechazado
TS-017 — commitlint + commit-msg|US-005|1h|Formato de commit consistente.|.husky/commit-msg + commitlint.config.js.|Conventional Commits|tipo(#N): descripción válido|Commit inválido rechazado
TS-018 — pre-push|US-005|1h|Evitar push con tests rotos.|.husky/pre-push.|Corre npm test:unit|Push rechazado si falla|Rápido (<30s)
TS-019 — .env.example + .env.*|US-006|1h|Configuración por entorno.|.env.example + .env.development/staging/production.|VITE_API_URL definido|VITE_APP_ENV definido|.env.example sin secretos
TS-020 — vite.config.ts con proxy /api|US-006|2h|Evitar CORS en dev.|vite.config.ts con proxy.|/api → http://localhost:7700|Rewrite de path|Funciona en fetch
TS-021 — env.d.ts tipado|US-006|1h|Autocompletado de env.|src/vite-env.d.ts.|import.meta.env tipado|VITE_API_URL con tipo|VITE_APP_ENV union type
TS-022 — tokens.css|US-007|3h|Valores visuales centralizados.|styles/tokens.css.|Color spacing radius typography z-index|CSS Custom Properties|Sin valores hardcodeados fuera
TS-023 — themes/*.css|US-007|3h|3 temas conmutables.|themes/light.css dark.css high-contrast.css.|data-theme selector|High contrast con ratio 7:1|Transición suave
TS-024 — ThemeProvider con persistencia|US-007|2h|Cambio de tema en runtime.|app/providers/ThemeProvider.tsx.|data-theme en html|Persistencia en localStorage|Respeta prefers-color-scheme
TS-025 — Estructura i18n/<locale>/<componente>/|US-008|3h|JSONs por dominio.|i18n/{es,en}/<componente>/index.json.|Carpetas por componente|common/errors.json con AUTH-* REG-* REC-* PWD-* RATE-* SYS-*|Sin claves huérfanas
TS-026 — i18next + LanguageDetector|US-008|2h|Init de i18n.|i18n/index.ts.|Fallback es|LanguageDetector activo|Persistencia en i18nextLng
TS-027 — Namespaces + common/errors/validations|US-008|2h|Namespaces por componente.|common/index.json errors.json validations.json dates.json.|Namespaces cargados|Traducciones consistentes|Sin duplicados
TS-028 — check-i18n.mjs y gen-i18n-types.mjs|US-008|3h|Validación y tipos de claves.|scripts/check-i18n.mjs + gen-i18n-types.mjs.|check-i18n falla si hay claves faltantes|gen-i18n-types genera i18n.d.ts|npm scripts configurados
TS-029 — public/assets/ estructura + placeholders|US-009|2h|Carpetas para assets mutables.|public/assets/{logos,images,icons,fonts}/.|Placeholders SVG|Estructura por dominio|README.md con convenciones
TS-030 — manifest.json + gen-assets-manifest.mjs|US-009|2h|Mapa clave lógica → ruta.|public/assets/manifest.json + scripts/gen-assets-manifest.mjs.|Mapa con logo.primary etc|Script regenera desde filesystem|Versionado
TS-031 — useAsset hook|US-009|1h|Resolver assets por clave.|shared/hooks/useAsset.ts.|useAsset('logo.primary') devuelve ruta|Tipado|Fallback si no existe
TS-032 — fonts.css con @font-face swap|US-009|1h|Fuentes self-hosted.|public/assets/fonts/fonts.css.|@font-face Inter 400 500 600 700|font-display swap|Preload del subset crítico
TS-033 — Button con variantes|US-010|3h|Botón base del DS.|components/atoms/Button/ (6 archivos).|Variantes primary secondary ghost danger|Estados default hover active loading disabled|Story Default Variants States DarkMode
TS-034 — Input y Textarea|US-010|2h|Controles de texto.|components/atoms/Input + Textarea.|Estados default error disabled|Label y helper|Accesibles con aria-describedby
TS-035 — Select, Checkbox, Radio, Switch|US-010|3h|Controles de selección.|components/atoms/{Select,Checkbox,Radio,Switch}/.|Accesibles con label|Estado error|Story de cada uno
TS-036 — Icon, Badge, Tag, Avatar|US-011|3h|Átomos de presentación.|components/atoms/{Icon,Badge,Tag,Avatar}/.|Icon tokenizado|Badge variantes color|Avatar con fallback
TS-037 — Tooltip, Spinner, Divider, Skeleton|US-011|3h|Átomos auxiliares.|components/atoms/{Tooltip,Spinner,Divider,Skeleton}/.|Tooltip accesible teclado|Spinner con aria-label|Skeleton con animación
TS-038 — Modal base + focus trap|US-012|4h|Modal accesible base.|components/molecules/Modal/Modal.tsx.|Overlay|Cierre con Escape|Focus trap activo
TS-039 — Variantes Info/Warning/Error/Success/Confirm|US-012|3h|Variantes preconfiguradas.|Modal con type prop.|Iconos por variante|Colores tokenizados|Botones contextuales
TS-040 — Toast + ToastProvider + aria-live|US-012|3h|Notificaciones no intrusivas.|ToastProvider + ToastHost.|Cola de toasts|Auto-cierre 4s|aria-live polite
TS-041 — Popover|US-012|3h|Popover anclado.|components/molecules/Popover/.|Anclaje a trigger|Cierre en outside click|Posicionamiento en resize
TS-042 — Dropdown|US-013|3h|Menú desplegable.|components/molecules/Dropdown/.|Navegación por teclado|Roles ARIA|Story completa
TS-043 — Tabs|US-013|3h|Pestañas accesibles.|components/molecules/Tabs/.|WAI-ARIA tabs|Navegación con flechas|Story completa
TS-044 — Accordion|US-013|2h|Colapsable.|components/molecules/Accordion/.|Multi-open opcional|Transición suave|Story completa
TS-045 — Breadcrumbs|US-013|2h|Migas de pan.|components/molecules/Breadcrumbs/.|aria-label|Último item no link|Story completa
TS-046 — Pagination|US-013|2h|Paginación.|components/molecules/Pagination/.|Prev/next|Rango de páginas|Navegación por teclado
TS-047 — FormField con error i18n|US-014|2h|Wrapper de label + control + error.|components/molecules/FormField/.|Integra label|Error traducido por i18n|aria-describedby automático
TS-048 — SearchBar con debounce|US-014|2h|Búsqueda con debounce.|components/molecules/SearchBar/.|Debounce 300ms|Clear button|aria-label search
TS-049 — LanguageSwitcher|US-014|2h|Cambio es/en.|components/molecules/LanguageSwitcher/.|Persistencia en i18nextLng|Sin recarga|Bandera o texto
TS-050 — ThemeSwitcher|US-014|2h|Cambio de tema.|components/molecules/ThemeSwitcher/.|Persistencia|Sin recarga|Toggle light/dark/high
TS-051 — DataTable|US-015|5h|Tabla de datos del DS.|components/organisms/DataTable/.|Paginación sorting filtros|Virtualización >100 filas|Estados loading empty error
TS-052 — Estado vacío + skeleton loader|US-015|2h|Estados intermedios.|DataTable EmptyState + Skeleton.|Placeholder ilustrado|Skeleton con filas|aria-busy
TS-053 — ChartContainer con Recharts|US-015|3h|Contenedor de gráficos.|components/organisms/ChartPanel/ChartContainer.tsx.|Recharts integrado|Responsive|API consistente
TS-054 — FullscreenChartModal|US-015|3h|Ampliar gráfico a pantalla completa.|ChartPanel con botón fullscreen.|Modal fullscreen|Re-render responsivo|Botón accesible
TS-055 — MediaPlayer con fullscreen y PiP|US-016|4h|Reproductor multimedia.|components/organisms/MediaPlayer/.|Controles accesibles|Fullscreen|PiP cuando soportado
TS-056 — FileUploader drag & drop|US-016|4h|Subida de archivos.|components/organisms/FileUploader/.|Drag & drop|Validación tipos y tamaños|Progress bar
TS-057 — Wizard multi-paso|US-016|4h|Asistente multi-paso.|components/organisms/Wizard/.|Navegación pasos|Validación por paso|Persistencia borrador
TS-058 — SidebarMenu plegable|US-017|4h|Menú lateral del AppShell.|components/organisms/SidebarMenu/.|Secciones expandibles|Persistencia plegado|Accesible teclado
TS-059 — NotificationCenter|US-017|3h|Centro de notificaciones.|components/organisms/NotificationCenter/.|Badge de no leídas|Lista con agrupación|Acciones por notificación
TS-060 — UserMenu|US-017|2h|Menú de usuario.|components/organisms/UserMenu/.|Perfil idioma logout|Accesible teclado|Consume AuthContext
TS-061 — SafeAreaView|US-018|1h|Wrapper para notch.|components/layout/SafeAreaView.tsx.|env(safe-area-inset-*)|Padding automático|Sin efecto en desktop
TS-062 — KeyboardAwareView|US-018|2h|Ajuste por teclado virtual.|components/layout/KeyboardAwareView.tsx.|visualViewport|Padding-bottom dinámico|Solo en mobile
TS-063 — PublicHeader|US-018|2h|Header público pre-login.|components/layout/PublicHeader.tsx.|Logo + CTA Contáctenos Login Registrar|Responsive|Enlaces correctos
TS-064 — Footer|US-018|2h|Pie de vistas públicas.|components/layout/Footer.tsx.|Legales idioma redes|Responsive|i18n completo
TS-065 — OrientationGate|US-018|2h|Decide horizontal vs vertical.|components/layout/OrientationGate.tsx.|Usa useViewport|Monta rama correspondiente|Fallback definido
TS-066 — AppShell con grid|US-019|4h|Layout autenticado.|components/layout/AppShell.tsx + .module.css.|Grid TopBar Sidebar Workspace|100dvh|Sin scroll body
TS-067 — TopBar|US-019|3h|Barra superior informativa.|TopBar.tsx.|Perfil idioma notificaciones logout|Responsive|Accesible
TS-068 — Sidebar persistente|US-019|3h|Sidebar plegable.|Sidebar.tsx.|Persistencia plegado|Responsive|Atajo teclado
TS-069 — Workspace|US-019|2h|Área de trabajo.|Workspace.tsx.|Scroll propio|Contenido flex|Fondo token
TS-070 — createBrowserRouter + lazyViews|US-020|3h|Routing con lazy.|app/router/index.tsx + lazyViews.ts.|React.lazy por vista|Suspense con skeleton|Rutas declaradas
TS-071 — paths.ts|US-020|1h|Constantes de rutas.|app/router/paths.ts.|ROUTES.HOME LOGIN etc|Tipado|Sin strings mágicos
TS-072 — routes.config.ts|US-020|2h|Metadata de rutas.|app/router/routes.config.ts.|Orientación por ruta|Guard por ruta|Rutas públicas/privadas
TS-073 — PublicRoute|US-021|1h|Guard público.|app/router/guards/PublicRoute.tsx.|Redirige si sesión|Sin parpadeo|Test unitario
TS-074 — ProtectedRoute|US-021|2h|Guard privado.|app/router/guards/ProtectedRoute.tsx.|Redirige si no sesión|Preserva returnTo|Test unitario
TS-075 — RoleRoute|US-021|2h|Guard por rol.|app/router/guards/RoleRoute.tsx.|ADMIN USER PREMIUM|Redirige a 403|Test unitario
TS-076 — OnboardingRoute|US-021|2h|Guard de onboarding.|app/router/guards/OnboardingRoute.tsx.|Redirige si perfil incompleto|Configurable|Test unitario
TS-077 — useViewport|US-022|3h|Viewport reactivo.|shared/hooks/useViewport.ts.|width height orientation deviceClass|Resize listener|SSR-safe
TS-078 — useOrientation|US-022|1h|Orientación.|shared/hooks/useOrientation.ts.|portrait landscape|Basado en useViewport|SSR-safe
TS-079 — useDeviceClass|US-022|1h|Clase de dispositivo.|shared/hooks/useDeviceClass.ts.|mobile tablet desktop tv|Breakpoints únicos|SSR-safe
TS-080 — useKeyboardInset|US-022|2h|Teclado virtual.|shared/hooks/useKeyboardInset.ts.|visualViewport|Actualiza en resize|Solo mobile
TS-081 — useSafeAreaInsets|US-022|1h|Insets del dispositivo.|shared/hooks/useSafeAreaInsets.ts.|top bottom left right|Lee env()|Fallback 0
TS-082 — http.ts con Axios|US-023|2h|Cliente HTTP único.|shared/utils/http.ts.|Base URL desde env|Sin duplicación|Tipado de respuestas
TS-083 — Interceptor de request|US-023|2h|Adjuntar JWT.|Interceptor en http.ts.|Lee tokenStorage|Adjunta Authorization Bearer|Omite en login/refresh
TS-084 — Interceptor de response con refresh|US-023|4h|Refresh automático.|Interceptor en http.ts.|Ante 401 llama refresh-token|Reintenta petición original|Limpia y redirige si falla
TS-085 — httpStatus.ts con mapeo a i18n|US-023|2h|Mapa de códigos.|shared/constants/httpStatus.ts.|AUTH-* REG-* REC-* PWD-* RATE-* SYS-*|Sin strings mágicos|Tipado
TS-086 — tokenStorage|US-023|2h|Persistencia de tokens.|shared/utils/storage.ts.|Claves versionadas|Limpieza al logout|Sin exponer tokens en logs
TS-087 — Hero InitPage horizontal|US-024|3h|Hero de la landing.|views/horizontal/initPage/sections/Hero.tsx.|Copy del producto|CTA principal|Ilustración
TS-088 — Beneficios / Cómo funciona|US-024|3h|Secciones explicativas.|sections/Beneficios.tsx + ComoFunciona.tsx.|Cards explicativas|Iconos|Responsive
TS-089 — Partners + Casos de éxito|US-024|2h|Prueba social.|sections/Partners.tsx + CasosExito.tsx.|Logos de partners|Testimonios|Carrusel o grid
TS-090 — TopBar pública con CTA|US-024|2h|Barra superior pública.|PublicHeader con CTA.|Contáctenos → /contact|Login → /login|Registrar → /register
TS-091 — Footer con legales|US-024|2h|Pie de InitPage.|Footer con legales.|Términos Privacidad|Selector idioma|Redes sociales
TS-092 — Maquetar InitPage vertical|US-025|4h|InitPage móvil.|views/vertical/initPage/InitPage.tsx.|Cards apiladas|100dvh|Sin scroll horizontal
TS-093 — Ajustes 100dvh y safe-area en vertical|US-025|2h|Móvil sin notch.|CSS de InitPage vertical.|env(safe-area-inset-*)|visualViewport.resize|Fallback desktop
TS-094 — ContactView horizontal + vertical|US-026|3h|Formulario de contacto.|views/{horizontal,vertical}/contact/ContactView.tsx.|Formulario o datos|Validación|i18n
TS-095 — TermsView + PrivacyView|US-026|3h|Páginas legales.|views/.../terms + privacy.|Contenido de ejemplo|Responsive|Enlaces desde Footer
TS-096 — LoginView horizontal|US-027|3h|Login desktop.|views/horizontal/login/LoginView.tsx.|Formulario email/password|Manejo de errores|Enlaces a register/recovery
TS-097 — LoginView vertical|US-027|2h|Login móvil.|views/vertical/login/LoginView.tsx.|Sticky CTA|100dvh|Teclado virtual
TS-098 — Conectar POST /api/auth/login|US-027|3h|Consumo real del endpoint.|services/auth.service.ts + AuthContext.|Solo espera token refreshToken|Guarda en tokenStorage|Navega a /home
TS-099 — Mapeo de errores a i18n|US-027|3h|Traducir códigos del backend.|login/errors.json en es/en.|AUTH-001 AUTH-002 AUTH-005 AUTH-006 RATE-001|Sin strings hardcodeadas|Tests de cada uno
TS-100 — Enlaces a /register y /recovery|US-027|1h|Navegación desde login.|Enlaces en LoginView.|Link a /register|Link a /recovery|Con replace
TS-101 — AuthContext|US-028|3h|Estado de sesión global.|app/providers/AuthProvider.tsx.|user token login logout refreshProfile|Sin duplicar en store|Tests unitarios
TS-102 — useRefreshToken|US-028|3h|Sesión deslizante.|shared/hooks/useRefreshToken.ts.|Renueva antes de expirar|Maneja fallo limpio|Tests unitarios
TS-103 — Persistencia segura de tokens|US-028|2h|Sobrevivir a refresh de página.|tokenStorage con versionado.|Claves versionadas|Migración si cambia formato|Limpieza en logout
TS-104 — LogoutButton|US-029|2h|Botón de logout.|components/organisms/UserMenu/LogoutButton.tsx.|Llama POST /api/auth/logout|No bloquea UI|Feedback toast
TS-105 — Limpieza y redirección|US-029|2h|Cierre de sesión.|Cierre en AuthContext.|Limpia tokens|Limpia query cache|navigate replace a /login
TS-106 — RegisterRequestView horizontal + vertical|US-030|4h|Formulario de registro paso 1.|views/{h,v}/register/RegisterRequestView.tsx.|8 campos|Validación en cliente|Responsive
TS-107 — Conectar POST /api/auth/register/request|US-030|3h|Consumo real.|services/register.service.ts.|Envía token por email|Navega a paso 2|Preserva datos
TS-108 — Mapeo REG-001/002/003/007|US-030|3h|Errores específicos.|Mapeo de códigos en register/errors.json.|REG-001 username|REG-002 email|REG-003 celular REG-007 pais
TS-109 — Vista de verificación de token|US-031|4h|Paso 2 de registro.|views/{h,v}/register/RegisterConfirmView.tsx.|Input 6 dígitos|Auto-focus y auto-submit|Reenviar
TS-110 — Conectar POST /api/auth/register/confirm|US-031|3h|Consumo real.|services/register.service.ts.|Maneja token expirado|Maneja token inválido|Timeout 5 min
TS-111 — Auto-login tras confirmación|US-031|2h|Sesión activa.|Tras confirmar, guarda tokens.|Navega a /home|Sin pedir credenciales|Toast bienvenida
TS-112 — RecoveryRequestView horizontal + vertical|US-032|3h|Paso 1 recuperación.|views/{h,v}/recovery/RecoveryRequestView.tsx.|Inputs username + email|Validación|Responsive
TS-113 — Conectar POST /api/auth/recovery/request|US-032|2h|Consumo real.|services/passwordRecovery.service.ts.|Envía token por email|Navega a paso 2|Feedback visual
TS-114 — Vista token + nueva contraseña|US-033|3h|Paso 2 recuperación.|views/{h,v}/recovery/RecoveryVerifyView.tsx.|Input 6 dígitos + nueva|Validación criterios|Repetir contraseña
TS-115 — Conectar POST /api/auth/recovery/verify|US-033|3h|Consumo real.|services/passwordRecovery.service.ts.|Cambia contraseña|Redirige a /login|Toast éxito
TS-116 — Mapeo REC-001/004|US-033|2h|Errores específicos.|recovery/errors.json en es/en.|REC-001 intentos|REC-004 usuario|PWD-001/002/003
TS-117 — ChangeMyPassView horizontal + vertical|US-034|3h|Cambio de contraseña.|views/{h,v}/perfil/ChangeMyPassView.tsx.|3 campos|Validación criterios|Responsive
TS-118 — Conectar POST /api/auth/change-my-pass|US-034|3h|Consumo real.|services/auth.service.ts.|Con JWT|Maneja PWD-003|Toast éxito
TS-119 — Mapeo PWD-001/002/003|US-034|2h|Errores específicos.|change-pass/errors.json.|PWD-001 no coinciden|PWD-002 criterios|PWD-003 actual incorrecta
TS-120 — HomeView horizontal|US-035|4h|Home desktop.|views/horizontal/home/HomeView.tsx.|Widgets de resumen|Layout responsive|Consume health
TS-121 — HomeView vertical|US-035|3h|Home móvil.|views/vertical/home/HomeView.tsx.|Cards apiladas|Bottom sheet opcional|100dvh
TS-122 — Consumir GET /api/test/health|US-035|1h|Estado del sistema.|services/system.service.ts.|Fetch health|Muestra estado|Refresco periódico
TS-123 — Placeholder dashboard/resumen|US-035|2h|Preparar para endpoints futuros.|Placeholder con skeleton.|Cards con copy|Sin datos reales|Fácil sustituir
TS-124 — Widget de perfil resumido|US-036|3h|Acceso rápido al perfil.|Widget en HomeView.|Consume GET /api/auth/get-my-profile|Enlace a /profile|Datos reales
TS-125 — ProfileView horizontal|US-037|3h|Perfil desktop.|views/horizontal/perfil/ProfileView.tsx.|id username email nombreCompleto celular pais activo ultimoLogin createdAt|Botón editar|i18n
TS-126 — ProfileView vertical|US-037|2h|Perfil móvil.|views/vertical/perfil/ProfileView.tsx.|Cards apiladas|Botón editar sticky|100dvh
TS-127 — Consumir GET /api/auth/get-my-profile|US-037|2h|Datos reales sin ofuscar.|services/profile.service.ts.|No aplica máscara (OWN_DATA_PATHS)|Tipado|Tests
TS-128 — EditProfileView horizontal + vertical|US-038|4h|Edición de perfil.|views/{h,v}/perfil/EditProfileView.tsx.|Formulario precargado|Validación en cliente|Responsive
TS-129 — Formulario RHF + Zod|US-038|3h|Validación tipada.|RHF + Zod con UpdateMyProfileRequest.|id username email nombreCompleto paisId celular|Todos obligatorios|Preserva case
TS-130 — Conectar POST /api/auth/update-my-profile|US-038|4h|Consumo real.|services/profile.service.ts.|Valida id/username vs JWT|UPT-0001 éxito|Refetch
TS-131 — Mapeo UPT-0001 + errores|US-038|3h|Mensajes específicos.|edit-profile/errors.json.|UPT-0001 éxito|REG-002/003/007|AUTH-007 SYS-03 genérico
TS-132 — Refetch tras éxito|US-038|2h|Estado consistente.|Actualizar AuthContext + get-my-profile.|Refetch silencioso|Sin recargar página|Toast éxito
TS-133 — Modal de confirmación (delete account)|US-039|3h|Confirmación explícita.|Modal de confirmación.|Advirtiendo consecuencias|Requiere tipear username|Acción irreversible
TS-134 — Conectar + limpiar sesión + redirigir|US-039|2h|Cierre tras borrado.|POST /api/auth/delete-account.|Limpia sesión|Redirige a /login|Toast confirmación
TS-135 — NotFound horizontal + vertical|US-040|2h|Error 404.|views/{h,v}/errors/NotFound.tsx.|CTA Home|i18n|Responsive
TS-136 — Forbidden horizontal + vertical|US-040|2h|Error 403.|views/{h,v}/errors/Forbidden.tsx.|CTA Home o Login|i18n|Responsive
TS-137 — ServerError horizontal + vertical|US-040|2h|Error 500.|views/{h,v}/errors/ServerError.tsx.|CTA reintentar|i18n|Responsive
TS-138 — @axe-core/playwright en todas las vistas|US-041|3h|Auditoría a11y automatizada.|tests/e2e/a11y.spec.ts.|Sin violaciones críticas en / /login /home /profile|Reporte en CI|Lista de reglas excluidas si aplica
TS-139 — Lighthouse >= 90|US-041|3h|Performance medible.|lighthouse-ci config + scripts.|Performance A11y Best Practices SEO >= 90|En 4 rutas clave|Reporte guardado
TS-140 — E2E Playwright 5 configs|US-041|5h|Cobertura E2E.|tests/e2e/*.spec.ts.|mobile-chrome mobile-safari tablet desktop tv|Verde en todas|Traces en fallo
TS-141 — bundle-analyze.mjs + presupuesto|US-041|2h|Control de tamaño.|scripts/bundle-analyze.mjs + budget.|Reporte HTML|Presupuesto por ruta|Falla si excede
TASKS

echo "   Tasks creadas: ${#ALL_TS_IDS[@]}"

# ---------------------------------------------------------
# 7) AGREGAR AL PROJECT
# ---------------------------------------------------------
echo "==> [6/6] Agregando al Project y vinculando jerarquía..."

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

# Vinculación jerárquica
LINKED=0; FAILED=0

link_sub() {
  local parent=$1 child=$2 attempt=1 max_attempts=3 pid cid
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
for us_key in "${!US[@]}"; do link_sub "${FT[${US_PARENT[$us_key]}]}" "${US[$us_key]}"; done
# US -> TS
for us_key in "${!TS_BY_US[@]}"; do
  for ts in ${TS_BY_US[$us_key]}; do link_sub "${US[$us_key]}" "$ts"; done
done

echo "   Links OK: $LINKED | Fallidos: $FAILED"

# Guardar IDs
{
  echo "CAP=$CAP"
  for k in "${!FT[@]}"; do echo "${k//-/_}=${FT[$k]}"; done
  for k in "${!US[@]}"; do echo "${k//-/_}=${US[$k]}"; done
  for i in "${!ALL_TS_IDS[@]}"; do echo "TS_$(printf '%03d' $((i+1)))=${ALL_TS_IDS[$i]}"; done
} > "$KANBAN_DIR/kanban-ids.env"

echo ""
echo "══════════════════════════════════════════════════════"
echo "  ✅ CAP-01 creada"
echo "  - 1 Capability  ·  9 Features  ·  41 User Stories  ·  ${#ALL_TS_IDS[@]} Tasks"
echo "  - Sub-issues vinculados: $LINKED (fallidos: $FAILED)"
echo "  - IDs en: $KANBAN_DIR/kanban-ids.env"
echo "══════════════════════════════════════════════════════"

[ "$FAILED" -eq 0 ] || exit 1