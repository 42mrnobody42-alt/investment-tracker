# agente-frontend.md

> Guía oficial de arquitectura y desarrollo frontend.
> Versión: 1.3.0
> Stack base: React 18+, TypeScript, Vite, CSS moderno (CSS Modules + Custom Properties + Container Queries), Storybook, i18next.
> Público objetivo: Desarrolladores frontend senior, tech leads y agentes automatizados de generación de código.
> Documento hermano del backend, la base de datos y el README del proyecto. Ver sección 0 y 22.

---

## 0. Contexto obligatorio y fuentes de verdad

Antes de proponer, generar, modificar o revisar cualquier artefacto del frontend, el agente (humano o IA) DEBE leer y respetar las siguientes fuentes, en este orden de autoridad:

1. `README.md` (raíz de `investment-tracker/`)
   - Estado general del proyecto, versión vigente (Version/Release/Hotfix), arquitectura, requisitos funcionales, stack tecnológico, historial de cambios y estructura de directorios detallada.
   - Es la fuente de verdad para: versionado, endpoints publicados, roles, stack, decisiones de seguridad (JWT, refresh token, masking, auditoría), modelo de datos y flujo Scrum (kanban, ramas, commits).
   - Si algún dato del frontend no está aquí, debe resolverse y luego documentarse en este mismo README o en un documento enlazado.

2. `docs/prompts/prompt_inicial.md`
   - Idea general del proyecto, requisitos funcionales del negocio, definiciones de los componentes, reglas de la IA, directrices por capa (backend, DB, frontend), gestión del tablero y flujo obligatorio por issue.
   - Es la fuente de verdad para: propósito del producto, reglas de negocio que afectan la UI, flujos funcionales (login, registro, recuperación, perfil, inversiones, calculadora de venta óptima, auditoría).

3. Este archivo (`docs/agente-frontend.md`)
   - Especifica cómo se construye el frontend: estructura de directorios, vistas por orientación, componentes, i18n, assets, testing, a11y, performance, seguridad y reglas para agentes IA.
   - Todo lo que aquí se define es de cumplimiento obligatorio para cualquier contribución al frontend.

4. Documentos enlazados en `README.md` y `docs/frontend/*.md`
   - Complementan, no reemplazan. Si hay conflicto, prevalece `README.md` → `prompt_inicial.md` → este archivo.

Reglas derivadas:

- Si el agente no tiene contexto suficiente (endpoint, DTO, regla de negocio, versión, estructura de un directorio), DEBE pedir el archivo concreto antes de generar código. Ver sección 21.
- Si detecta contradicción entre este archivo y `README.md`/`prompt_inicial.md`, DEBE señalarlo, proponer la corrección y actualizar el documento correspondiente en el mismo PR.
- Está prohibido inventar endpoints, campos, códigos de error o estructuras. Se toman del `README.md` y del código real del backend.

---

## 1. Principios rectores (Big-Tech Standard)

1. Separación por orientación y dispositivo: todo lo horizontal (PC, Smart TV, tablet apaisada) vive en frontend/src/views/horizontal. Todo lo vertical (móvil, tablet retrato) vive en frontend/src/views/vertical. Nunca se mezclan layouts de orientación distinta en el mismo directorio.
2. Mobile-first con escalado progresivo: los estilos base se escriben para móvil vertical y se escalan con min-width y @container.
3. Composición sobre herencia: las vistas se arman combinando componentes pequeños, no se heredan vistas.
4. Contratos tipados: todo componente y toda vista expone props tipadas con TypeScript estricto (strict: true, noImplicitAny: true).
5. Aislamiento i18n: ningún texto plano en el código. Todo texto pasa por t('namespace.clave').
6. Storybook como fuente de verdad: cada componente atómico/molecular tiene al menos una story (Default, Loading, Error, Empty, variantes responsivas).
7. Assets mutables en runtime: logos, imágenes corporativas y fuentes viven en frontend/public/assets para poder reemplazarse sin recompilar.
8. Accesibilidad AA mínimo: roles ARIA correctos, foco visible, navegación por teclado, contraste >= 4.5:1.
9. Performance como feature: code-splitting por ruta, lazy load de vistas pesadas, React.memo selectivo, virtualización de listas largas.
10. Convención sobre configuración: nombres, carpetas y exports siguen una única convención para que cualquier dev o agente encuentre las cosas en segundos.
11. Fuentes de verdad primero: antes de escribir código, consultar README.md y docs/prompts/prompt_inicial.md (ver sección 0).
12. Trazabilidad con el tablero: todo cambio nace de un issue del Project Board y se referencia en el commit/PR (ver README.md sección 106 y prompt_inicial.md).

---

## 2. Estructura de directorios del proyecto

Solo se listan las ramas relevantes al frontend y a los contenedores. Las ramas backend/, database/ y backups/ quedan fuera del alcance de este documento y se documentan en el README.md.

- **`investment-tracker/`** - Raíz del proyecto
  - `.gitignore` - Archivos ignorados por Git
  - `README.md` - Documentación principal (fuente de verdad, ver sección 0)
  - **`docker/`** - Contenedores y orquestación
    - `docker-compose.yml` - Orquestación de servicios
    - `Dockerfile.frontend` - Imagen para React (build + nginx)
    - **`nginx/`**
      - `default.conf` - Reverse proxy HTTPS
      - `nginx-frontend.conf` - Servidor frontend (SPA fallback a index.html)
      - **`ssl/`**
        - `localhost.crt` - Certificado SSL autofirmado
        - `localhost.key` - Llave privada SSL
    - **`shellTest/`** - Scripts de mantenimiento
      - `check-all.sh` - Verificación completa
      - `reset-all.sh` - Reset de servicios
  - **`frontend/`** - SPA React 18 + TypeScript + Vite
    - `.gitignore` - Archivos ignorados por Git en frontend
    - `.nvmrc` - Versión de Node fijada (por ejemplo, 20.11.1)
    - `.env.example` - Plantilla de variables de entorno
    - `.env.development` - Variables para desarrollo (VITE_API_URL, VITE_APP_ENV)
    - `.env.staging` - Variables para staging
    - `.env.production` - Variables para producción
    - `.editorconfig` - Reglas de formato de editor
    - `.eslintrc.cjs` - ESLint (react, hooks, jsx-a11y, import)
    - `.eslintignore` - Exclusiones de ESLint
    - `.prettierrc` - Reglas de Prettier
    - `.prettierignore` - Exclusiones de Prettier
    - `.stylelintrc.json` - Reglas de Stylelint para CSS Modules
    - `.browserslistrc` - Navegadores soportados (incluye Smart TV)
    - `package.json` - Dependencias y scripts npm
    - `package-lock.json` - Lockfile reproducible
    - `tsconfig.json` - Configuración TypeScript base (strict)
    - `tsconfig.node.json` - TS para tooling (Vite, Storybook)
    - `tsconfig.paths.json` - Alias de imports (@app, @components, @views, @shared, @i18n, @styles)
    - `vite.config.ts` - Configuración Vite (alias, proxy API, build)
    - `vitest.config.ts` - Configuración de pruebas unitarias
    - `playwright.config.ts` - Proyectos E2E: mobile-chrome, mobile-safari, tablet, desktop, tv
    - `index.html` - HTML raíz con viewport-fit=cover y CSP
    - `README.md` - Cómo levantar, construir y desplegar el frontend
    - `CHANGELOG.md` - Historial de cambios (Keep a Changelog)
    - **`.husky/`** - Git hooks
      - `pre-commit` - Ejecuta lint-staged
      - `commit-msg` - Ejecuta commitlint
      - `pre-push` - Ejecuta tests unitarios
    - **`.storybook/`** - History Book de componentes
      - `main.ts` - Configuración principal (addons, frameworks, rutas)
      - `preview.ts` - Decoradores globales (ThemeProvider, I18nextProvider, Router)
      - `preview-head.html` - Carga de fuentes y tokens en Storybook
      - `manager.ts` - Personalización de la UI de Storybook (marca, temas)
    - **`public/`** - Assets públicos servidos tal cual
      - `favicon.ico` - Favicon raíz
      - `robots.txt` - Reglas de indexación
      - `manifest.webmanifest` - PWA manifest
      - `sitemap.xml` - Sitemap público
      - **`assets/`** - Assets corporativos editables post-deploy
        - `manifest.json` - Mapa clave lógica -> ruta física para useAsset()
        - **`logos/`**
          - `logo-primary.svg` - Logo principal
          - `logo-primary-dark.svg` - Logo para tema oscuro
          - `logo-compact.svg` - Logo reducido para sidebar
          - `logo-partner-placeholder.svg` - Placeholder de partners
        - **`images/`**
          - **`initPage/`** - Hero, beneficios, mockups
          - **`login/`** - Ilustración lateral
          - **`home/`** - Widgets e íconos ilustrativos
          - **`casosExito/`** - Casos de éxito con logos de clientes
          - **`partners/`** - Logos de partners
        - **`icons/`** - SVGs optimizados por dominio
          - **`common/`** - Flechas, cierres, menús
          - **`servicioA/`** - Íconos propios del servicio A
          - **`admin/`** - Íconos de administración
        - **`fonts/`** - Fuentes self-hosted
          - `Inter-Regular.woff2` - Peso 400
          - `Inter-Medium.woff2` - Peso 500
          - `Inter-SemiBold.woff2` - Peso 600
          - `Inter-Bold.woff2` - Peso 700
          - `fonts.css` - @font-face con font-display: swap
        - **`locales-runtime/`** - JSONs cargados en runtime si se requiere override
      - **`screenshots/`** - Capturas para el manifest PWA
    - **`src/`**
      - `main.tsx` - Punto de entrada React (monta App y providers globales)
      - `vite-env.d.ts` - Tipos de Vite (import.meta.env)
      - **`app/`** - Núcleo de la aplicación
        - `App.tsx` - Componente raíz con providers y router
        - **`router/`**
          - `index.tsx` - createBrowserRouter con lazy loading por vista
          - `routes.config.ts` - Definición declarativa de rutas, guardas y orientación
          - `paths.ts` - Constantes de rutas (ROUTES.HOME, ROUTES.LOGIN, etc.)
          - `lazyViews.ts` - Importadores React.lazy de todas las vistas
          - **`guards/`**
            - `PublicRoute.tsx` - Solo accesible sin sesión (login, register, initPage)
            - `ProtectedRoute.tsx` - Requiere sesión activa
            - `RoleRoute.tsx` - Requiere rol específico (ADMIN, USER, PREMIUM)
            - `OnboardingRoute.tsx` - Redirige si el perfil está incompleto
        - **`providers/`**
          - `AppProviders.tsx` - Compone todos los providers en orden
          - `ThemeProvider.tsx` - Tema claro/oscuro y tokens
          - `I18nProvider.tsx` - Inicializa i18next y expone cambio de idioma
          - `AuthProvider.tsx` - Sesión, tokens, refresh automático
          - `QueryProvider.tsx` - TanStack Query con defaults
          - `ErrorBoundaryProvider.tsx` - Captura errores por ruta
          - `ToastProvider.tsx` - Cola de toasts global
          - `ModalProvider.tsx` - Registro global de modales
        - **`store/`** - Estado global UI
          - `index.ts` - Store principal (Zustand)
          - `uiSlice.ts` - Sidebar abierta, tema, idioma, tamaño
          - `authSlice.ts` - Usuario actual, roles, permisos
          - `persist.ts` - Persistencia en localStorage (con versionado)
          - `selectors.ts` - Selectores memoizados
      - **`components/`** - Design System
        - **`atoms/`**
          - **`Button/`**
            - `Button.tsx` - Botón (variantes primary/secondary/ghost/danger)
            - `Button.module.css` - Estilos y estados
            - `Button.types.ts` - Tipos de props
            - `Button.test.tsx` - Pruebas unitarias
            - `Button.stories.tsx` - Stories Default/Variants/States/Responsive/Dark
            - `index.ts` - Barrel export
          - **`Input/`** - Mismo patrón (.tsx, .module.css, .types.ts, .test.tsx, .stories.tsx, index.ts)
          - **`Textarea/`** - Mismo patrón
          - **`Select/`** - Mismo patrón
          - **`Checkbox/`** - Mismo patrón
          - **`Radio/`** - Mismo patrón
          - **`Switch/`** - Mismo patrón
          - **`Icon/`** - Ícono SVG con tamaño y color tokenizados
          - **`Badge/`** - Etiqueta de estado
          - **`Tag/`** - Etiqueta removible
          - **`Avatar/`** - Avatar de usuario
          - **`Tooltip/`** - Tooltip accesible
          - **`Spinner/`** - Indicador de carga
          - **`Divider/`** - Separador
          - **`Skeleton/`** - Placeholder de carga
        - **`molecules/`**
          - **`Modal/`** - Modal con variantes info/warning/error/success/confirm
          - **`Toast/`** - Toast con variantes y aria-live
          - **`Popover/`** - Popover anclado
          - **`Dropdown/`** - Menú desplegable
          - **`Tabs/`** - Pestañas accesibles
          - **`Accordion/`** - Acordeón colapsable
          - **`Breadcrumbs/`** - Migas de pan
          - **`Pagination/`** - Paginación
          - **`FormField/`** - Label + control + error i18n
          - **`SearchBar/`** - Barra de búsqueda con debounce
          - **`LanguageSwitcher/`** - Cambio es/en
          - **`ThemeSwitcher/`** - Cambio claro/oscuro
        - **`organisms/`**
          - **`DataTable/`** - Sorting, filtering, paginación, virtualización
          - **`ChartPanel/`** - Gráfico con botón "ampliar a pantalla completa"
          - **`MediaPlayer/`** - Video/audio con fullscreen y PiP
          - **`FormBuilder/`** - Formularios por schema (zod)
          - **`SidebarMenu/`** - Menú de procesos plegables
          - **`NotificationCenter/`** - Centro de notificaciones
          - **`UserMenu/`** - Menú de usuario (perfil, idioma, logout)
          - **`FileUploader/`** - Subida de archivos con drag & drop
          - **`Wizard/`** - Asistente multi-paso
        - **`layout/`**
          - `AppShell.tsx` - Envoltura TopBar + Sidebar + Workspace
          - `AppShell.module.css` - Grid responsive y 100dvh
          - `TopBar.tsx` - Barra superior informativa
          - `Sidebar.tsx` - Barra lateral plegable con persistencia
          - `Workspace.tsx` - Área de trabajo con scroll propio
          - `Footer.tsx` - Pie de vistas públicas
          - `PublicHeader.tsx` - Header de initPage/login
          - `SafeAreaView.tsx` - Respeta env(safe-area-inset-\*)
          - `KeyboardAwareView.tsx` - Ajuste por teclado virtual
          - `OrientationGate.tsx` - Decide rama horizontal o vertical
      - **`views/`** - Vistas por orientación
        - **`horizontal/`** - PC, tablet apaisada, Smart TV
          - **`initPage/`**
            - `InitPage.tsx` - Vista pública de presentación
            - `InitPage.module.css` - Layout ancho
            - `sections/` - Hero, Beneficios, CómoFunciona, Partners, CasosExito
            - `index.ts` - Barrel export
          - **`login/`** - Formulario + SSO + recuperación
          - **`register/`** - Registro multi-paso
          - **`home/`** - Dashboard con widgets por rol
          - **`consulta/`** - DataTable + filtros + exportación
          - **`edicion/`** - FormBuilder + validación + autosave
          - **`perfil/`** - Datos del usuario, cambio de contraseña
          - **`servicioA/`** - Dominio funcional A (inversiones)
          - **`admin/`** - Administración de usuarios y roles
          - **`seguridad/`** - Configuración de seguridad de la cuenta
          - **`errors/`**
            - `NotFound.tsx` - 404
            - `Forbidden.tsx` - 403
            - `ServerError.tsx` - 500
        - **`vertical/`** - Móvil y tablet retrato
          - **`initPage/`** - Misma estructura, layout vertical
          - **`login/`**
          - **`register/`**
          - **`home/`** - Bottom sheet, cards apiladas
          - **`consulta/`** - Tabla apilada o lista con detalle
          - **`edicion/`** - Formulario a pantalla completa, sticky CTA
          - **`perfil/`**
          - **`servicioA/`**
          - **`admin/`**
          - **`seguridad/`**
          - **`errors/`** - 404, 403, 500 en vertical
      - **`shared/`** - Código transversal
        - **`hooks/`**
          - `useViewport.ts` - width, height, orientation, deviceClass
          - `useOrientation.ts` - portrait | landscape
          - `useDeviceClass.ts` - mobile/tablet/desktop/tv
          - `useKeyboardInset.ts` - Altura del teclado virtual vía visualViewport
          - `useSafeAreaInsets.ts` - Insets del dispositivo
          - `useMediaQuery.ts` - Media queries reactivas
          - `useContainerQuery.ts` - Container queries reactivas
          - `useLocalStorage.ts` - Persistencia tipada
          - `useDebounce.ts` - Debounce genérico
          - `useThrottle.ts` - Throttle genérico
          - `useIntersectionObserver.ts` - Lazy reveal e infinite scroll
          - `useAsset.ts` - Resuelve clave lógica a ruta física desde manifest.json
          - `usePermissions.ts` - Permisos por rol (ADMIN, USER, PREMIUM)
          - `useIdleTimeout.ts` - Cierre de sesión por inactividad
          - `useFocusTrap.ts` - Trampa de foco para modales
        - **`utils/`**
          - `http.ts` - Cliente HTTP (axios/fetch) con interceptores JWT y refresh
          - `fetcher.ts` - Adaptador para TanStack Query
          - `formatters.ts` - Fechas, números, monedas con Intl.\*
          - `validators.ts` - Esquemas zod reutilizables
          - `storage.ts` - Wrapper seguro de localStorage/cookies
          - `sanitize.ts` - DOMPurify para HTML dinámico
          - `classNames.ts` - cn() para CSS Modules condicional
          - `logger.ts` - Logger con redacción de datos sensibles
          - `retry.ts` - Retry con backoff exponencial
        - **`constants/`**
          - `breakpoints.ts` - Breakpoints únicos y exportables
          - `devices.ts` - Rangos por deviceClass
          - `routes.ts` - Espejo de rutas si no se usa app/router/paths.ts
          - `storageKeys.ts` - Claves de localStorage versionadas
          - `httpStatus.ts` - Mapa de códigos HTTP a claves i18n
          - `regex.ts` - Expresiones regulares reutilizables
        - **`types/`**
          - `api.types.ts` - Tipos de respuestas del backend (basados en el README.md)
          - `models.types.ts` - Modelos de dominio
          - `view.types.ts` - Tipos de props de vistas
          - `env.d.ts` - Tipado de import.meta.env
          - `global.d.ts` - Declaraciones globales
        - **`services/`** - Clientes por dominio del backend
          - `auth.service.ts` - login, refresh-token, logout, change-my-pass, delete-account
          - `profile.service.ts` - get-my-profile, update-my-profile
          - `register.service.ts` - register/request, register/confirm
          - `passwordRecovery.service.ts` - recovery/request, recovery/verify
          - `admin.service.ts` - restart-password, delete-user (solo pruebas)
          - `queryKeys.ts` - Claves jerárquicas de TanStack Query
      - **`i18n/`** - Internacionalización
        - `index.ts` - Inicialización de i18next (idiomas, fallback, detectors)
        - `formatters.ts` - Formatos por locale
        - `i18n.d.ts` - Tipado fuerte de claves (autogenerado)
        - **`es/`** - Español
          - **`common/`** - index.json, errors.json, validations.json, dates.json
          - **`initPage/`** - index.json, partners.json, footer.json
          - **`login/`** - index.json, errors.json
          - **`register/`** - index.json, steps.json
          - **`logout/`** - index.json
          - **`home/`** - index.json
          - **`consulta/`** - index.json
          - **`edicion/`** - index.json
          - **`perfil/`** - index.json
          - **`seguridad/`** - index.json
          - **`servicioA/`** - index.json
          - **`admin/`** - index.json
        - **`en/`** - Inglés (misma estructura que es/)
      - **`styles/`** - Estilos globales y tokens
        - `tokens.css` - Design tokens (color, spacing, radius, typography, z-index)
        - `reset.css` - Reset moderno
        - `global.css` - Estilos globales (body, scrollbar, selección)
        - `utilities.css` - Utilidades mínimas (sr-only, hidden, etc.)
        - `animations.css` - Keyframes reutilizables
        - `print.css` - Estilos de impresión
        - **`themes/`** - light.css, dark.css, high-contrast.css
        - **`mixins/`** - container.css, focus-ring.css, truncate.css
    - **`tests/`** - Pruebas del frontend
      - **`unit/`** - setup.ts, mocks/
      - **`integration/`** - login.flow, consulta.flow, edicion.flow
      - **`e2e/`** - initPage, login, logout, home, consulta, edicion, a11y + helpers/
    - **`scripts/`** - Automatización del frontend
      - `check-i18n.mjs` - Verifica claves faltantes entre es y en
      - `gen-i18n-types.mjs` - Genera i18n.d.ts desde los JSON
      - `gen-assets-manifest.mjs` - Regenera public/assets/manifest.json
      - `optimize-images.mjs` - Convierte imágenes a AVIF/WebP
      - `bundle-analyze.mjs` - Reporte de tamaño de bundle
    - **`dist/`** - Build de producción (generado por Vite)
    - **`coverage/`** - Reporte de cobertura de Vitest (generado)
    - **`playwright-report/`** - Reporte HTML de Playwright (generado)
    - **`test-results/`** - Resultados crudos de Playwright (generado)
    - **`storybook-static/`** - Storybook compilado (generado)
    - **`node_modules/`** - Dependencias instaladas (generado)
  - **`docs/`** - Documentación
    - `README_IdeaICompletaDeArchivos.md` - Idea completa de arquitectura
    - `agente-frontend.md` - Este documento
    - `agente-backend.md` - (planificado) Reglas del backend
    - `agente-database.md` - (planificado) Reglas de la base de datos
    - **`prompts/`**
      - `prompt_inicial.md` - Idea general del proyecto (fuente de verdad, ver sección 0)
      - `prompt_frontend.md` - Prompt específico del frontend
    - **`frontend/`**
      - `arquitectura.md` - Diagrama y decisiones de arquitectura
      - `design-system.md` - Catálogo de componentes y tokens
      - `i18n.md` - Convenciones de internacionalización
      - `assets.md` - Cómo reemplazar logos e imágenes en runtime
      - `storybook.md` - Cómo levantar y publicar Storybook
      - `testing.md` - Estrategia de pruebas unitarias, integración y E2E
      - `deploy.md` - Build, variables de entorno y despliegue
    - **`serverConfig/`**
      - `popOS22.04.md` - Guía de instalación en Pop!\_OS 22.04

---

## 3. Reglas de vistas por orientación

### 3.1 Detección de orientación y dispositivo

- Hook central useViewport() expone:
  {
  orientation: 'portrait' | 'landscape',
  deviceClass: 'mobile' | 'tablet' | 'desktop' | 'tv',
  width, height,
  safeAreaInsets: { top, bottom, left, right },
  keyboardInset: number // altura ocupada por teclado virtual
  }
- El router decide qué rama montar (views/horizontal vs views/vertical) en base a orientation y deviceClass.
- No se permite duplicar lógica de vista: cada vista horizontal y vertical comparte hooks y servicios, pero su composición visual es independiente.

### 3.2 Layout interno de vistas autenticadas (obligatorio)

Toda vista posterior al login (home, perfil, servicioA, admin, consulta, edición) se compone con AppShell:

┌────────────────────────────────────────────┐
│ TopBar │
├──────────────┬─────────────────────────────┤
│ │ │
│ Sidebar │ Workspace │
│ (plegable) │ (área de trabajo real) │
│ │ │
└──────────────┴─────────────────────────────┘

- TopBar: información contextual, notificaciones, perfil, cambio de idioma, logout.
- Sidebar: procesos plegables, agrupados por categoría, con estado persistido en localStorage.
- Workspace: recibe la vista activa. Es un main con overflow: auto y scroll propio.

### 3.3 Adaptación móvil (vertical)

- Respetar env(safe-area-inset-\*) para notch y barra de gestos.
- Detectar teclado virtual con visualViewport y aplicar padding-bottom dinámico al formulario activo.
- Cuando aparecen/desaparecen barras inferiores del navegador móvil, usar 100dvh (no 100vh) y recalcular con visualViewport.resize.
- Botones de acción principales: position: sticky al fondo del workspace dentro de su contenedor.

### 3.4 Vistas horizontales

- Smart TV: foco navegable con flechas del control remoto (roving tabindex). Tamaños mínimos de fuente 18px, targets >= 48px.
- PC: sidebar puede colapsar a modo íconos. Atajos de teclado documentados.
- Tablet horizontal: layout híbrido con sidebar reducido.

### 3.5 Vistas que dependen del negocio

- Las vistas del dominio (inversiones, comisiones, calculadora de venta óptima, transacciones, auditoría) toman reglas y códigos del README.md y del prompt_inicial.md.
- Los roles visibles en la UI son ROLE_ADMIN, ROLE_USER y ROLE_PREMIUM (ver README.md).
- Los endpoints consumidos se toman de la tabla "Servicios Publicados" del README.md. No inventar rutas.

---

## 4. Estructura de componentes (Design System)

Cada componente vive en su carpeta:

components/<nivel>/<ComponentName>/
├── <ComponentName>.tsx
├── <ComponentName>.module.css
├── <ComponentName>.types.ts
├── <ComponentName>.test.tsx
├── <ComponentName>.stories.tsx
└── index.ts # barrel export

### 4.1 Átomos mínimos obligatorios

- Button (variantes: primary, secondary, ghost, danger; estados: default, hover, active, loading, disabled).
- Input, Textarea, Select, Checkbox, Radio, Switch.
- Icon, Badge, Tag, Avatar, Tooltip, Spinner, Divider, Skeleton.

### 4.2 Moléculas obligatorias

- Modal (con variantes info, warning, error, success, confirm).
- Toast (mismo set de variantes).
- Popover, Dropdown, Tabs, Accordion, Breadcrumbs, Pagination.
- FormField, SearchBar, LanguageSwitcher, ThemeSwitcher.

### 4.3 Organismos obligatorios

- DataTable: sorting, filtering, paginación, selección, columnas configurables, estados loading | empty | error, virtualización > 100 filas.
- ChartPanel: envoltorio de gráficos con botón "ampliar a pantalla completa".
- MediaPlayer: video/audio con fullscreen y PiP.
- FormBuilder: basado en schema (zod / yup) para vistas de edición.
- SidebarMenu, NotificationCenter, UserMenu, FileUploader, Wizard.

### 4.4 Layout obligatorio

- AppShell, TopBar, Sidebar, Workspace, Footer, PublicHeader, SafeAreaView, KeyboardAwareView, OrientationGate.

### 4.5 Reglas de calidad de componentes

- Props públicas documentadas con JSDoc en inglés (código) y descripciones i18n para la UI en español e inglés.
- Cero lógica de negocio dentro de componentes de presentación; se inyecta por props o hooks.
- Cero textos hardcodeados: siempre t('...').
- Cero estilos inline salvo valores dinámicos calculados en runtime (por ejemplo --dynamic-offset).
- Cada componente expone data-testid estable.

---

## 5. Storybook (History Book de componentes)

- Configurado en frontend/.storybook/.
- Cada componente atómico/molecular/organismo tiene su .stories.tsx obligatoriamente.
- Stories mínimas por componente:
  - Default
  - Variants
  - States (loading, disabled, error, empty)
  - Responsive (viewports: mobile-vertical, tablet-portrait, tablet-landscape, desktop, tv)
  - DarkMode
- Se documenta con autodocs: true y MDX para componentes complejos.
- Los tokens de diseño se muestran en una story DesignTokens/Overview.
- Storybook debe poder desplegarse como sitio estático versionado (storybook-static/).

---

## 6. Vistas estándar (plantillas reutilizables)

Toda vista nueva debe derivar de una de estas plantillas. No se inventan layouts desde cero. Los flujos están alineados con el README.md y el prompt_inicial.md.

1. initPage (pública, pre-login)
   - Barra superior: logo + menú Contáctenos, Login, Registrar.
   - Hero: qué hace el producto, qué problema resuelve, CTA principal.
   - Sección de beneficios / cómo funciona.
   - Sección inferior: Partners + Casos de éxito.
   - Footer con legales, idioma y redes.

2. login
   - Formulario email/contraseña + SSO opcional + recuperación.
   - Validación en cliente y servidor, mensajes i18n, bloqueo tras N intentos.
   - El backend retorna solo token y refreshToken (ver README.md). Los datos personales se consultan por separado con get-my-profile.

3. register
   - Multi-paso si aplica, con validación por paso y persistencia de borrador.
   - Flujo en dos pasos: request + confirm por token de 6 dígitos (TTL 5 min). Roles asignados: FREE -> ROLE_USER, PREMIUM -> ROLE_PREMIUM.

4. logout
   - Acción global: limpia tokens, store, caché de queries y redirige a login.
   - Nunca se navega hacia atrás a una vista protegida (usar replace).
   - Llama a /api/auth/logout y descarta el refresh token.

5. home
   - Dashboard dentro de AppShell. Widgets configurables por rol.
   - Consume /api/dashboard/resumen (planificado) o endpoints del dominio.

6. consulta de datos
   - DataTable + filtros + exportación (CSV, XLSX, PDF) + detalle lateral o modal.
   - Ejemplo: transacciones, plataformas, comisiones.

7. edición de datos
   - FormBuilder con schema, validación, autosave opcional, confirmación al salir con cambios sin guardar.
   - Ejemplo: update-my-profile, alta/edición de plataformas.

8. errores
   - 404 (NotFound), 403 (Forbidden), 500 (ServerError) en ambas orientaciones.

---

## 7. Internacionalización (i18n)

- Librería: i18next + react-i18next + i18next-browser-languagedetector.
- Estructura: frontend/src/i18n/<locale>/<componente>/ con archivos JSON por dominio. Ejemplo: i18n/es/login/index.json, i18n/en/servicioA/index.json.
- Idiomas soportados: es, en. Fallback: es.
- Reglas:
  - Prohibido texto plano en JSX.
  - Claves en camelCase y namespaces = nombre de carpeta de la vista o componente.
  - Pluralización con count nativo de i18next.
  - Fechas, números y monedas con Intl.\* o i18next formatters. Importante: el proyecto maneja 54 divisas (ver README.md).
  - Cambio de idioma en runtime sin recargar.
  - Todo texto nuevo se agrega en ambos idiomas en el mismo PR.
  - Se valida con script frontend/scripts/check-i18n.mjs que no falten claves.

Ejemplo de uso:
t('login:index.emailLabel')
t('servicioA:index.errors.network')

---

## 8. Assets corporativos editables en runtime

- Todo logo, imagen o icono corporativo vive en frontend/public/assets/....
- Nunca se importan desde src/ mediante bundler para assets que puedan cambiar post-deploy.
- Nombres en kebab-case, con sufijos @1x, @2x, @3x o SVG preferentemente.
- Existe un manifest.json en frontend/public/assets/ que mapea claves lógicas a rutas físicas:
  { "logo.primary": "/assets/logos/logo-primary.svg", ... }
- El frontend consume el manifest a través de useAsset('logo.primary') para poder cambiar assets sin recompilar.
- Se regenera con frontend/scripts/gen-assets-manifest.mjs.

---

## 9. Estilos y theming

- CSS moderno: custom properties, clamp(), min(), max(), container queries, :has(), color-mix(), nesting nativo.
- Tokens en frontend/src/styles/tokens.css (color, tipografía, spacing, radius, sombras, z-index).
- Tema claro/oscuro con data-theme en <html>. Existe tema de alto contraste.
- Breakpoints definidos una sola vez en frontend/src/shared/constants/breakpoints.ts y expuestos como custom properties.
- Prohibido !important salvo justificación en PR.
- Todos los tamaños con unidades relativas (rem, em, %, dvh) excepto bordes finos.
- Uso obligatorio de 100dvh en lugar de 100vh en vistas móviles.

---

## 10. Estado y datos

- Estado local: useState / useReducer.
- Estado global UI: Zustand (preferido) o Redux Toolkit, en frontend/src/app/store/.
- Estado de servidor: TanStack Query con claves jerárquicas ['servicioA', 'list', filters].
- Nunca se duplica estado de servidor en el store global.
- Manejo de errores: ErrorBoundaryProvider por ruta + toasts para errores recuperables.
- Cliente HTTP único en frontend/src/shared/utils/http.ts con interceptores JWT y refresh automático.
- Los códigos de error del backend (AUTH-_, REG-_, REC-_, PWD-_, VAL-_, ENC-_, BIZ-_, RATE-_, SYS-\*) se mapean a claves i18n. El mapeo vive en shared/constants/httpStatus.ts.
- El rate limiting (RATE-001) y el bloqueo de cuenta (AUTH-002) se comunican al usuario con mensajes claros y acciones sugeridas.

---

## 11. Rutas y navegación

- React Router v6+ con createBrowserRouter en frontend/src/app/router/index.tsx.
- frontend/src/app/router/routes.config.ts define rutas, guardas y qué orientación montar.
- Guards: PublicRoute, ProtectedRoute, RoleRoute (ADMIN, USER, PREMIUM), OnboardingRoute.
- Lazy loading por vista: React.lazy + Suspense con skeletons.
- Transiciones de página con <ViewTransition> cuando el navegador lo soporte.

---

## 12. Accesibilidad (a11y)

- WCAG 2.2 AA mínimo.
- Foco visible y navegable por teclado en todos los flujos críticos.
- aria-live en toasts y mensajes de validación.
- Contraste verificado con axe-core en CI (tests/e2e/a11y.spec.ts).
- Soporte de prefers-reduced-motion.
- Textos alternativos i18n en todas las imágenes.

---

## 13. Performance

- Presupuesto: LCP < 2.5s en 4G, INP < 200ms, CLS < 0.1.
- Code splitting por ruta y por vendor.
- Imágenes en AVIF/WebP con srcset y loading="lazy".
- Fuentes en woff2 con font-display: swap y preload del subset crítico.
- Memoización selectiva; prohibido React.memo sin justificación medida.
- Listas > 100 filas virtualizadas (@tanstack/react-virtual).
- Reporte de bundle con frontend/scripts/bundle-analyze.mjs.

---

## 14. Testing

- Unitario: Vitest + Testing Library. Cobertura mínima 80% en components/ y shared/.
- Integración: flujos de vista (login -> home -> consulta).
- E2E: Playwright con proyectos mobile-chrome, mobile-safari, desktop-chrome, tablet, tv.
- Visual: Chromatic o Playwright snapshots.
- a11y: @axe-core/playwright en cada vista.
- Los tests viven junto al código (\*.test.tsx) o en frontend/tests/ según tipo.
- Los tests usan mocks alineados con los DTO reales del backend (ver README.md).

---

## 15. Convenciones de código

- TypeScript estricto. Sin any (usar unknown y narrowing).
- ESLint + Prettier + eslint-plugin-import + eslint-plugin-react-hooks + eslint-plugin-jsx-a11y + Stylelint para CSS Modules.
- Commits con Conventional Commits + Husky + lint-staged + commitlint.
- Formato de commit: tipo(#N): descripción — feat, fix, docs, refactor, test, chore. Siempre referenciar el issue con Closes #N o Refs #N (ver README.md sección 106).
- Nombres:
  - Componentes: PascalCase.tsx.
  - Hooks: useAlgo.ts.
  - Utilidades: camelCase.ts.
  - Carpetas de vista: kebab-case o camelCase según dominio.
- Exports nombrados; default solo para vistas de ruta.
- Máximo ~200 líneas por componente; si excede, dividir.
- Alias de import obligatorios: @app, @components, @views, @shared, @i18n, @styles.

---

## 16. Seguridad

- Sin secretos en el bundle. Variables sensibles solo backend.
- Variables de entorno públicas expuestas solo con prefijo VITE\_ y a través de .env.\*.
- Sanitización obligatoria de HTML dinámico (DOMPurify en shared/utils/sanitize.ts).
- CSP estricta en frontend/index.html y en docker/nginx/default.conf.
- HTTPS forzado vía docker/nginx/default.conf con certificados en docker/nginx/ssl/.
- Manejo de tokens: preferir httpOnly cookies si el backend lo soporta; si no, seguir la estrategia del README.md (JWT + refresh token con sesión deslizante de 1 hora).
- El cliente HTTP debe aplicar refresh automático antes de expirar y limpiar todo al logout.
- No exponer en la UI datos que el backend enmascara. Los endpoints en OWN_DATA_PATHS devuelven datos reales del propio usuario; el resto llega enmascarado (ver README.md, sección Ofuscación).
- No loggear en consola datos sensibles (email, celular, nombre completo, tokens).

---

## 17. Reglas para agentes automatizados (IA)

1. Leer primero README.md y docs/prompts/prompt_inicial.md (ver sección 0) antes de proponer cualquier cambio.
2. Antes de crear una vista, verificar si existe plantilla equivalente en frontend/src/views/<orientación>/.
3. Nunca duplicar lógica entre horizontal y vertical: extraer a shared/.
4. Todo texto nuevo debe agregarse simultáneamente en i18n/es/_ y i18n/en/_.
5. Todo componente nuevo debe incluir: .tsx, .module.css, .types.ts, .test.tsx, .stories.tsx, index.ts.
6. Respetar tokens de diseño; prohibido hardcodear colores o espaciados.
7. Respetar AppShell para vistas autenticadas.
8. Añadir data-testid en elementos interactivos.
9. Actualizar este archivo cuando se introduzca una convención nueva.
10. No inventar endpoints, DTOs, códigos de error ni roles. Se toman del README.md y del código real.
11. Toda contribución nace de un issue del tablero y sigue el flujo de ramas definido en el prompt_inicial.md.
12. Si falta contexto para avanzar (endpoint, DTO, diseño, regla de negocio, versión), solicitar el archivo concreto. Ver sección 21.
13. Si detecta contradicción entre documentos, señalarla y proponer la corrección en el mismo PR.
14. Cuando se cree una vista, agregar su story, sus tests y su entrada i18n en el mismo PR.

---

## 18. Definición de "Done" (checklist por PR)

- [ ] Vistas horizontal y vertical cubiertas (o justificación).
- [ ] i18n es/en completo y sin claves faltantes (node frontend/scripts/check-i18n.mjs).
- [ ] Stories de Storybook creadas y visualmente revisadas.
- [ ] Tests unitarios e integración pasando.
- [ ] E2E en las 5 configuraciones verdes.
- [ ] a11y sin violaciones críticas.
- [ ] Lighthouse >= 90 en Performance, A11y, Best Practices, SEO.
- [ ] Assets en frontend/public/assets si son mutables post-deploy.
- [ ] Documentación actualizada (README del componente + este archivo si aplica).
- [ ] Issue del tablero referenciado con Closes #N o Refs #N.
- [ ] Sin textos hardcodeados, sin any, sin colores hardcodeados.

---

## 19. Anti-patrones prohibidos

- Textos hardcodeados en JSX.
- Colores/espaciados hardcodeados fuera de tokens.
- Importar vistas de una orientación desde la otra.
- 100vh en móvil.
- any en TypeScript.
- Lógica de negocio en componentes de presentación.
- Componentes sin story.
- Duplicar estado de servidor en store global.
- Assets corporativos importados por bundler cuando deberían ser mutables en runtime.
- Secretos o tokens hardcodeados en el código fuente.
- Inventar endpoints, DTOs o códigos de error.
- Avanzar sin haber leído README.md y prompt_inicial.md.

---

## 20. Regla de entrega de archivos .md o comandos que generan archivos .md

Cuando el usuario pida un archivo .md, un documento, una guía, un README, un archivo de configuración con formato markdown, o cualquier comando/salida que vaya a producir un archivo .md, el agente DEBE responder siguiendo estrictamente esta regla:

- No puedo generar ni adjuntar archivos descargables directamente desde esta conversación: solo produzco texto. Lo que sí puedo hacer es entregarte el contenido en un único bloque de código para que lo copies y lo pegues directamente en tu editor (VSCode, Notepad++, etc.) y lo guardes tú como <nombre-archivo>.md. Ese bloque no interpreta nada del contenido, lo conserva literal.

Aplicación obligatoria:

1. Entregar SIEMPRE el contenido completo dentro de un único bloque de código (cercado con backticks triples), sin dividirlo en varios bloques.
2. No interpretar ni renderizar el markdown interno: debe verse como texto plano dentro del bloque.
3. No resumir, no truncar, no usar "..." ni "resto igual": el archivo debe quedar listo para pegar y guardar.
4. Indicar claramente el nombre exacto del archivo a crear (por ejemplo: agente-frontend.md).
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
2. Priorizar archivos de las fuentes de verdad: README.md, docs/prompts/prompt_inicial.md, este agente, luego código real (services, DTOs, vistas existentes, tests, configuración de Vite/TS).
3. Nunca asumir la forma de un DTO, un endpoint, un código de error ni un rol: si no está en las fuentes, se pide.
4. Si el usuario pide una tarea que abarca varias capas (frontend + backend + DB), pedir primero el contrato de API (endpoints, request/response, códigos de error) y luego continuar.
5. Si el usuario pide "crear la vista X" sin contrato, pedir: (a) endpoint(s) exactos del README.md o del código, (b) DTO de request, (c) DTO de response, (d) roles con acceso, (e) reglas de negocio y validaciones.
6. Si el usuario pide "mejorar el diseño", pedir: (a) mockups o referencias visuales, (b) tokens actuales (styles/tokens.css), (c) componentes existentes reutilizables.
7. Si el usuario pide "configurar Storybook/Vite/TS", pedir los archivos de configuración actuales (vite.config.ts, tsconfig.json, .storybook/main.ts, package.json).
8. Si el usuario pide "agregar traducciones", pedir el listado de claves vigentes (o el árbol de i18n/es y i18n/en) para no romper claves.
9. Nunca avanzar con supuestos silenciosos. Si se hace un supuesto por continuidad, declararlo explícitamente y marcarlo como pendiente de validación.

Ejemplos:

- Petición: "Crea la vista de perfil para móvil."
  Respuesta esperada del agente: solicitar ProfileResponse y UpdateMyProfileRequest (o los .java correspondientes), el listado de campos con validación, los códigos de error (REG-002, REG-003, REG-007, AUTH-007, SYS-03), y confirmar que /api/auth/get-my-profile está en OWN_DATA_PATHS. Con eso procede.

- Petición: "Arma el DataTable de transacciones."
  Respuesta esperada: solicitar el DTO de transacción (o entidad), los filtros soportados por el backend, el formato de paginación, y si hay endpoints de exportación.

- Petición: "Agrega i18n al módulo admin."
  Respuesta esperada: solicitar i18n/es/admin/index.json, i18n/en/admin/index.json y el listado de vistas/campos del admin.

---

## 22. Referencias cruzadas entre documentos

- README.md (raíz del proyecto): estado general, versión vigente, endpoints publicados, stack, arquitectura, modelo de datos, seguridad, ofuscación, auditoría, Scrum. Es la fuente principal.
- docs/prompts/prompt_inicial.md: idea general del proyecto, requisitos funcionales, reglas para la IA, directrices por capa y flujo obligatorio por issue.
- docs/agente-frontend.md: este documento. Reglas de construcción del frontend.
- docs/agente-backend.md y docs/agente-database.md: documentos hermanos (planificados). Deben respetar las mismas reglas de fuentes de verdad y solicitud de archivos.
- docs/frontend/\*.md: profundizan en arquitectura, design system, i18n, assets, storybook, testing y deploy.

Regla de consistencia:

- Cualquier cambio en README.md o prompt_inicial.md que afecte al frontend debe reflejarse en este archivo en el mismo PR.
- Cualquier convención nueva de este archivo debe reflejarse en README.md (sección de estructura) y, si aplica, en prompt_inicial.md.

---

Fin del documento.
