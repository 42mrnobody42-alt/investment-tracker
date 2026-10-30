# agente-frontend.md

> Guía oficial de arquitectura y desarrollo frontend.
> Versión: 1.4.0
> Stack base: React 19 + TypeScript 6 + Vite 8, CSS moderno (CSS Modules + Custom Properties + Container Queries), Storybook, i18next.
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

4. Documentos enlazados en `README.md` y `docs/tecnica/**/*.md`
   - Complementan, no reemplazan. Si hay conflicto, prevalece `README.md` → `prompt_inicial.md` → este archivo.
   - Convención: `docs/tecnica/<NN-nombre-del-capítulo-en-kebab-case>/<subcategoría>/<archivo>.md|.sql`.
   - Para este agente, el capítulo de interés es `docs/tecnica/04-frontend-react-css-moderno/`.

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
  - **`frontend/`** - SPA React 19 + TypeScript 6 + Vite 8
    - `.gitignore` - Archivos ignorados por Git en frontend
      - `.nvmrc` - Versión de Node fijada (por ejemplo, 24.21.0)
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
      - `main.ts` - Configuración principal (addons, framework, stories glob)
      - `preview.tsx` - Decoradores activos (`withPadding`, `withBackground`, `withViewport`) + tags autodocs + import de branding CSS
      - `manager.ts` - Personalización de la UI de Storybook (marca, temas)
      - `tsconfig.json` - TS config específico para Storybook (evita TS2882)
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
          - `ErrorBoundaryProvider.tsx` - Captura errores por ruta
          - `SmoothScrollProvider.tsx` - Inicializa Lenis + GSAP ticker + ScrollTrigger (ver §24.4)
          - `ThemeProvider.tsx` - Tema claro/oscuro y tokens
          - `I18nProvider.tsx` - Inicializa i18next y expone cambio de idioma
          - `AuthProvider.tsx` - Sesión, tokens, refresh automático
          - `QueryProvider.tsx` - TanStack Query con defaults
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
          - **`CursorFollower/`** - Cursor personalizado que sigue al mouse (ver §24.3.4)
          - **`ScrollRevealText/`** - Titular/párrafo que se ilumina palabra a palabra con el scroll (ver §24.3)
          - **`AuraBackground/`** - Fondo con gradientes radiales animados (ver §24.3.3)
          - **`SineWaveButton/`** - Botón con anillos expansivos al hover/click (ver §24.3.1)
        - **`molecules/`**
          - **`Modal/`** - Modal con variantes info/warning/error/success/confirm
          - **`Toast/`** - Toast con variantes y aria-live
          - **`Popover/`** - Popover anclado
          - **`Dropdown/`** - Menú desplegable
          - **`Tabs/`** - Pestañas accesibles
          - **`Accordion/`** - Acordeón colapsable
          - **`Marquee/`** - Cinta móvil con desplazamiento infinito (ver §24.3.2)
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
          - **Motion (ver §24)**:
            - `useLenisScroll.ts` - Smooth scroll global enlazado al ticker de GSAP
            - `useCursorFollower.ts` - Cursor personalizado con `gsap.quickTo()`
            - `useSineWaveButton.ts` - Anillos expansivos al hover/click
            - `useTextReveal.ts` - Titulares que se iluminan palabra a palabra con el scroll
            - `useMarquee.ts` - Cinta infinita con `translateX` (o `translateY`)
            - `useAuraBackground.ts` - Gradientes radiales animados
            - `useParallax.ts` - Parallax con `ScrollTrigger.scrub`
            - `useRevealOnScroll.ts` - Fade + translateY al entrar en viewport
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
    - **`prompts/`**
      - `prompt_inicial.md` - Idea general del proyecto (fuente de verdad, ver sección 0)
      - `agente-frontend.md` - Este documento
      - `agente-backend.md` - Reglas del backend (arquitectura hexagonal, DTOs, errores, seguridad, ofuscación, auditoría, testing)
      - `agente-database.md` - Reglas de la base de datos (nomenclatura SQL, idempotencia, permisos, auditoría, migraciones)
    - **`tecnica/`** - Documentación técnica por capítulo del README
      - **`02-base-de-datos/`** - Cap. 2: Base de Datos
      - **`03-backend-java-spring-boot-3x/`** - Cap. 3: Backend Java Spring Boot 3.x
      - **`04-frontend-react-css-moderno/`** - Cap. 4: Frontend React + CSS
        - **`deuda-tecnica/`** - ADRs de deudas técnicas pendientes
          - `eslint-9-eol.md` (ADR-0001)
          - `stylelint-scope-y-colores.md` (ADR-0002)
          - `assets-hibrido-public-src.md` (ADR-0003)
          - `vulnerabilidades-policy.md` (ADR-0004)
          - `decorador-with-theme-pendiente.md` (ADR-0005)
          - `decorador-with-i18n-pendiente.md` (ADR-0006)
          - `decorador-with-router-pendiente.md` (ADR-0007)
        - **`convenciones/`**
          - `convenciones.md` - Convenciones de código del frontend
          - `storybook.md` - Guía operativa de Storybook (autodocs, decoradores)
        - **`componentes/`**
          - **`atoms/`**
            - `button.md` - Documentación del componente Button (ejemplo TS-007)
          - **`branding/`**
            - `paleta-colores-corporativa.html` - Preview visual de la paleta corporativa
        - **`seguridad/`**
          - `cvss-deuda-seguridad.md` - Vulnerabilidades aceptadas
        - **Carpetas pendientes** (se pueblan cuando avancen sus tasks):
          - `design-system/` → `design-system.md` - Catálogo de componentes y tokens
          - `internacionalizacion/` → `i18n.md` - Convenciones de internacionalización
          - `assets/` → `assets.md` - Cómo reemplazar logos e imágenes en runtime
          - `testing/` → `testing.md` - Estrategia de pruebas unitarias, integración y E2E
          - `deploy/` → `deploy.md` - Build, variables de entorno y despliegue
          - `diagramas-de-secuencias/` → `login.md` - Flujo frontend ↔ backend (se crea con la vista)
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

### 4.6 Componentes de motion (átomos y moléculas)

Definidos en §24. Se listan aquí para que la jerarquía del Design System quede completa.

**Átomos:**

- `CursorFollower/` — cursor personalizado que sigue al mouse. Ver §24.3.4.
- `ScrollRevealText/` — titular que se ilumina palabra a palabra con el scroll. Ver §24.3.
- `AuraBackground/` — fondo con gradientes radiales animados. Ver §24.3.3.
- `SineWaveButton/` — botón con anillos expansivos al hover/click. Átomo independiente, **no** extiende `Button`. Ver §24.3.1.

**Moléculas:**

- `Marquee/` — cinta infinita de texto, íconos o imágenes. Ver §24.3.2.

**Reglas comunes** (además de §4.5):

- Toda animación vive en un hook de `shared/hooks/` (ver §24.2). El componente solo orquesta el hook y aplica el `ref`.
- Ninguno anima `width`, `height`, `top`, `left`, `box-shadow` (regla de §24.6).
- Todos respetan `prefers-reduced-motion: reduce` (§24.7).
- Todas las props configurables están documentadas en `<ComponentName>.types.ts` y en la tabla de §24.3.
- Ninguno hardcodea colores, tamaños, formas ni velocidades: todo pasa por props con tokens `var(--...)`.
- Stories obligatorias por componente: `Default`, `ReducedMotion` + las variantes específicas de §24.3.

---

## 5. Storybook (History Book de componentes)

- Configurado en `frontend/.storybook/` (puerto dev `3010`).
- **TS-008** dejó la infraestructura base (main.ts, preview.tsx, addons) y una
  story mínima del Button (`Default`).
- **TS-009** completó las 5 stories del Button (`Default`, `Variants`, `Sizes`,
  `States`, `DarkMode`) y activó 3 decoradores globales (`withPadding`,
  `withBackground`, `withViewport`).
- Decoradores pendientes (diferidos a tasks posteriores, registrados como ADRs):
  - `withTheme` → TS-024 (#629), ADR-0005
  - `withI18n` → TS-026 (#631), ADR-0006
  - `withRouter` → TS-070 (#675), ADR-0007
- Cada componente atómico/molecular/organismo tiene su .stories.tsx obligatoriamente.
- Guía operativa: [`docs/tecnica/04-frontend-react-css-moderno/convenciones/storybook.md`](../tecnica/04-frontend-react-css-moderno/convenciones/storybook.md).
- Warnings conocidos: [`warnings-storybook.md`](../tecnica/04-frontend-react-css-moderno/convenciones/warnings-storybook.md) — `Skipping docgen` y `ariaLabel` son informativos y están aceptados.
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

### 6.9 Motion aplicado a `initPage`

Los efectos definidos en §24 se integran en las **secciones existentes** de `initPage` (horizontal y vertical). No se crean vistas nuevas ni se duplica lógica entre orientaciones.

| Sección de `initPage` | Efecto de motion                                                                          |
| :-------------------- | :---------------------------------------------------------------------------------------- |
| `Hero`                | `AuraBackground` (fondo) + `CursorFollower` + `ScrollRevealText` en el titular principal. |
| `Beneficios`          | `RevealOnScroll` por tarjeta con `stagger` (delay escalonado).                            |
| `CómoFunciona`        | `ScrollRevealText` en cada paso + `Parallax` suave en las ilustraciones.                  |
| `Partners`            | `Marquee` con los logos duplicados (uno hacia cada dirección si aplica).                  |
| `CasosExito`          | `RevealOnScroll` + `Parallax` en las imágenes destacadas.                                 |
| CTAs (cualquiera)     | `SineWaveButton` con `trigger="hover"` o `"click"` según el caso.                         |

Reglas:

- Los textos de marquees y titulares **pasan siempre por i18n** (§7). Se añaden las claves en `i18n/es/initPage/index.json` y `i18n/en/initPage/index.json` en el mismo PR.
- El mapeo se mantiene actualizado cuando se agregue una sección nueva a `initPage`.
- `initPage` es la primera vista del producto: se prioriza que los efectos no degraden el **LCP** (§13).

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

## 8. Assets — modelo híbrido

Los assets viven en dos ubicaciones según su propósito. Ver ADR-0003
(`docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/assets-hibrido-public-src.md`).

### Criterio de clasificación

| Tipo                                  | Ubicación             | Modelo                                  |
| ------------------------------------- | --------------------- | --------------------------------------- |
| Branding / contenido configurable     | `public/assets/...`   | URL estable + `useAsset()` (TS-009)     |
| Iconos técnicos / acoplados al código | `src/assets/...`      | Import de bundler (hash + tree-shaking) |
| Fuentes self-hosted                   | `src/styles/fuentes/` | Import de bundler (hashed)              |
| Iconos de app (favicon, PWA)          | `public/` (raíz)      | URL estable                             |

### Árbol

- `¿El asset necesita reemplazarse sin recompilar el bundle?`
  - **Sí** → `public/assets/{categoría}/`
    - `logos/` — logos de marca
    - `images/{dominio}/` — imágenes de marketing (`initPage/`, `login/`, `home/`…)
    - `icons/` — iconos consumidos por config/JSON (no por componentes)
  - **No** → `src/assets/` o `src/styles/fuentes/`
    - `icons/` — SVG consumidos por componentes React
    - `images/` — ilustraciones acopladas a componentes
    - `src/styles/fuentes/` — fuentes self-hosted (tipografía de la plataforma, NO editable post-deploy)

### Reglas por modelo

**`public/assets/` (branding)**

- Nombres en kebab-case, SVG preferido, opcional `@1x @2x @3x`.
- Existe `public/assets/manifest.json` que mapea claves lógicas a rutas físicas:
  `{ "logo.primary": "/assets/logos/logo-primary.svg", ... }`.
- El frontend consume el manifest vía `useAsset('logo.primary')` para cambiar sin recompilar.
- Se regenera con `frontend/scripts/gen-assets-manifest.mjs`.
- **Sin type-safety** en la URL. Mitigación: constantes tipadas en `src/shared/constants/assets.ts`.

**`src/assets/` (técnicos)**

- Nombres en kebab-case.
- Importados directamente: `import icon from '../assets/icons/foo.svg'`.
- Vite los hashea (`foo-CHdo91hT.svg`) y los "aplana" en `dist/assets/`.
- **Con type-safety**: el build falla si el archivo no existe.
- **Con tree-shaking**: assets no importados no llegan al bundle.

---

## 9. Estilos y theming

- CSS moderno: custom properties, clamp(), min(), max(), container queries, :has(), color-mix(), nesting nativo.
- Todos los design tokens viven en `frontend/src/styles/branding/` (creados en TS-144):
  - `paleta-colores-corporativa.css` — colores (`--color-*`, `--btn-*`). Temas light, dark y **high-contrast** vía `[data-theme]`.
  - `tipografia.css` — familias (`--font-sans`, `--font-mono`), escalas (`--font-size-*`), pesos, line-heights, letter-spacing. Importa `../fuentes/fuentes.css` que declara los `@font-face` (Inter + JetBrains Mono).
  - `layout.css` — grid, spacing (`--space-*`), breakpoints, z-index.
  - `estilos-componentes.css` — radius, shadows, cards, tables, alerts.
  - `motion.css` — duraciones, easings y stagger (ver §24). Incluye los easings compuestos de péndulo (`--ease-pendulum`, `--ease-pendulum-damped`, amplitud parametrizable vía `--pendulum-amplitude`) y el retardo de barrido de página (`--pasar-pagina`, con 4 direcciones diagonales: `sweepCellTlBr`, `sweepCellTrBl`, `sweepCellBlTr`, `sweepCellBrTl`).
- **No existe `styles/tokens.css`** — la estructura `tokens.css` + `themes/` fue reemplazada por los 5 archivos de `styles/branding/`.
- **Temas light/dark/high-contrast** con `data-theme` en `<html>`. Todos viven dentro de `paleta-colores-corporativa.css` (no existe `themes/`).
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

### 11.5 SmoothScrollProvider

Lenis se inicializa **una sola vez** a nivel de aplicación, dentro de `app/providers/SmoothScrollProvider.tsx`. Detalle completo en §24.4.

- Se monta en `AppProviders.tsx` **por encima** de `ThemeProvider` y por debajo de `ErrorBoundaryProvider`.
- El provider:
  1. Instancia Lenis.
  2. Lo enlaza al ticker de GSAP (`gsap.ticker.add`).
  3. Suscribe `lenis.on('scroll', ScrollTrigger.update)`.
  4. Expone `useLenis()` para que las vistas puedan hacer `scrollTo`.
  5. En cleanup, destruye Lenis y remueve el ticker.
- **Prohibido** instanciar Lenis dentro de vistas o componentes individuales.

---

## 12. Accesibilidad (a11y)

- WCAG 2.2 AA mínimo.
- Foco visible y navegable por teclado en todos los flujos críticos.
- aria-live en toasts y mensajes de validación.
- Contraste verificado con axe-core en CI (tests/e2e/a11y.spec.ts).
- **`prefers-reduced-motion: reduce` es obligatorio en toda animación** (ver §24.7). Cuando el usuario lo activa: no se montan cursores personalizados, no se disparan ondas en botones, los marquees se muestran estáticos, las auras se congelan, y las animaciones de entrada saltan al estado final sin transición.
- Los tests E2E de a11y (`tests/e2e/a11y.spec.ts`) deben correr también con `prefers-reduced-motion: reduce` emulado (Playwright lo permite).
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
- **Presupuesto de motion** (complementa §24.6): solo se animan `transform` y `opacity`. `will-change` solo durante la animación activa. `gsap.quickTo()` obligatorio para alta frecuencia. `ScrollTrigger` registrado una vez. `useGSAP()` con `scope` obligatorio.
- `CursorFollower`, `AuraBackground` y `Marquee` se cargan **lazy** cuando aportan peso significativo al bundle inicial.
- Cualquier animación que supere 1 ms de frame budget debe justificarse en el PR.

---

## 14. Testing

**Gate obligatorio antes de push/PR/merge**: `frontend/tests/shellTest/Frontend-test-Dev.sh` debe terminar en verde (exit 0) antes de hacer push, abrir PR a `developer` o mergear. Commit WIP como checkpoint local permitido con `ALLOW_NEW=1` (prefijo `[WIP]` en el mensaje), pero no autoriza push ni merge. Si la tarea añade un test nuevo (Vitest, Playwright, axe, i18n-check, assets-manifest, bundle-analyze, husky), el test DEBE registrarse en el runner en el mismo PR. Warnings y errores nuevos bloquean push/merge hasta documentarse en `approved-warnings.txt` o resolverse.

- **Unitario**: Vitest 5.0.5 + Testing Library (@testing-library/react 16.3.3, jest-dom 7.0.1, user-event 14.6.8, dom 10.4.2). Configuración en `frontend/vitest.config.ts`. Setup en `frontend/tests/unit/setup.ts`.
- **Entorno DOM**: jsdom 30.1.3.
- **Cobertura mínima**: 80% en `Stmts`, `Branch`, `Funcs` y `Lines`, tanto **global** como **por archivo**. Threshold en modo `error` (falla el CI si no se cumple). Excepciones justificadas en ADR-0009 (`docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/exclusiones-cobertura-tests.md`).
- **Comandos**:
  - `npm test` — modo watch (desarrollo).
  - `npm run test:run` — modo CI (una ejecución, sale con código).
  - `npm run test:coverage` — genera reporte en `frontend/coverage/`.
- **Integración**: flujos de vista (login -> home -> consulta).
- **E2E**: Playwright con **7 proyectos** (`mobile-chrome`, `mobile-android`, `mobile-safari`, `tablet`, `desktop`, `tv-fhd`, `tv-4k`) configurados en `frontend/playwright.config.ts` (TS-013).
- **a11y**: `@axe-core/playwright@4.14.0` + helper `runA11y()` en `tests/e2e/helpers/a11y.ts`. Mockup base en `tests/e2e/fixtures/mock-view.html` (TS-014). Aplicación a todas las vistas reales: **TS-138 (#743)**. Ver subsección `### E2E a11y (Playwright + axe)` en `pruebas.md`.
- **Visual**: Chromatic o Playwright snapshots.
- **Ubicación de tests**:
  - Unitarios de componentes: `frontend/tests/unit/components/<atoms|molecules|organisms>/`.
  - Unitarios de shared: `frontend/tests/unit/shared/`.
  - Integración: `frontend/tests/integration/` (cuando existan flujos).
  - E2E: `frontend/tests/e2e/` + `frontend/playwright.config.ts` (TS-013).
- **Mocks**: alineados con los DTO reales del backend (ver README.md).
- **Exclusiones de cobertura**: ver ADR-0009 (`docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/exclusiones-cobertura-tests.md`).
- **Convenciones completas de testing**: [`docs/tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md`](../tecnica/04-frontend-react-css-moderno/convenciones/pruebas.md). Incluye reglas permanentes (framework, comandos, estructura, cobertura global y por archivo, exclusiones permanentes, líneas con exclusión justificada, convenciones de escritura, mocks, alineación con el backend).

---

### 14.8 Husky + pre-commit (obligatorio)

El proyecto usa **Husky v9** con `.husky/pre-commit` para bloquear commits rotos antes de que lleguen al repositorio. Configuración completa:

**Estructura**

- `frontend/.husky/pre-commit` — hook ejecutable (mode `100755`)
- `frontend/.husky/_/` — bootstrap interno de Husky (ignorado por git via `.husky/_/.gitignore`)
- `frontend/.lintstagedrc.json` — config de lint-staged
- `core.hooksPath` = `frontend/.husky/_` (configurado por `scripts.prepare`)

**Flujo del pre-commit** (ejecutado en cada `git commit`)

1. `npx lint-staged` — corre sobre archivos staged:
   - `*.{ts,tsx}` → `eslint --fix` + `prettier --write`
   - `*.css` → `stylelint --fix` + `prettier --write`
   - `*.{json,md,yml,yaml}` → `prettier --write`
2. `npm run type-check` — valida tipos del proyecto completo (`tsc -b`)

**Qué se bloquea vs qué se autofixea**

| Situación                                 | Resultado                      |
| ----------------------------------------- | ------------------------------ |
| Error de ESLint no autofixeable en staged | ❌ Commit bloqueado (exit ≠ 0) |
| Formato Prettier roto                     | ✅ Autofixea, commit permitido |
| Error de tipos (`tsc -b` falla)           | ❌ Commit bloqueado            |
| Estilo de CSS roto (autofixeable)         | ✅ Autofixea                   |

**Relación con el runner (TS-015)**

- El runner `Frontend-test-Dev.sh` con `RUN_HOOKS=1` valida la **estructura** de los 3 hooks (existencia, ejecutable, `bash -n`). No valida comportamiento — eso lo hace el pre-commit real al ejecutarse.
- Pre-commit es **rápido** (<15 s) y cubre solo staged + types.
- El runner es el **gate completo** (2-3 min) antes de push / PR / merge.
- Ambos son **obligatorios**: pre-commit previene commits rotos; runner previene push/merge rotos.

**Prohibiciones**

- `git commit --no-verify` solo en emergencia documentada (mensaje de commit debe incluir `no-verify: <motivo>`).
- No saltar el hook "porque tarda" — si tarda, es porque el código está mal.

### 14.9 commitlint + commit-msg (obligatorio)

El proyecto usa **commitlint 21.2.4** con `.husky/commit-msg` para validar el formato de cada commit.

**Configuración** (`frontend/commitlint.config.js`):

- `extends: ['@commitlint/config-conventional']`
- `defaultIgnores: true` — ignora `Merge pull request #N from ...`
- `parserPreset.parserOpts.headerPattern: /^(\w+)(?:\(#[0-9]+\))?!?: (.+)$/`
- `parserPreset.parserOpts.breakingHeaderPattern: /^(\w+)(?:\(#[0-9]+\))?!: (.+)$/`
- `rules['type-enum']`: `feat | fix | docs | refactor | test | chore | style | perf | build | ci | revert`
- `rules['subject-empty']: never`, `subject-full-stop: never`, `header-max-length: 100`

**Hook** (`frontend/.husky/commit-msg`):

```bash
#!/usr/bin/env sh
cd "$(git rev-parse --show-toplevel)/frontend" || exit 1

npx commitlint --edit "$1"
```

**Tipos permitidos** (única fuente de verdad: `commitlint.config.js`):

| Tipo       | Uso                                     |
| ---------- | --------------------------------------- |
| `feat`     | Nueva funcionalidad                     |
| `fix`      | Corrección de bug                       |
| `docs`     | Solo documentación                      |
| `refactor` | Cambio de código sin cambio funcional   |
| `test`     | Añadir/corregir tests                   |
| `chore`    | Tareas de mantenimiento (deps, scripts) |
| `style`    | Formato, espacios (no cambia lógica)    |
| `perf`     | Mejora de rendimiento                   |
| `build`    | Sistema de build o deps externas        |
| `ci`       | Configuración de CI                     |
| `revert`   | Revertir commit anterior                |

**Dónde se valida la configuración**:

- **Runner** (`RUN_HOOKS` + Vitest): el hook existe, es ejecutable, `bash -n` OK; los 26 tests de `commitlint.test.ts` validan `headerPattern`, `type-enum` y `defaultIgnores`.
- **Validador específico de la tarea**: comportamiento real del CLI (`echo "..." | commitlint`) con mensajes válidos e inválidos.

**Type declarations**: `commitlint.config.d.ts` existe porque `tsconfig.app.json` tiene `allowJs: false` y el config es `.js` ESM.

**Prohibiciones**:

- `git commit --no-verify` solo en emergencia documentada (mensaje debe incluir `no-verify: <motivo>`).
- No usar tipos fuera de `type-enum` (ej. `feature`, `hotfix`, `wip`).

### 14.10 Husky + pre-push (obligatorio)

El hook `pre-push` es el **gate final** antes de que el código llegue a `origin`. Ejecuta el runner unificado completo.

**Hook** (`frontend/.husky/pre-push`):

```bash
#!/usr/bin/env sh
cd "$(git rev-parse --show-toplevel)/frontend" || exit 1

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo "  pre-push: ejecutando runner completo (~2-3 min)…"
echo "════════════════════════════════════════════════════════════════════"
echo ""

RUN_AUTOFIX=0 bash tests/shellTest/Frontend-test-Dev.sh
```

**Flujo**:

1. Imprime mensaje inicial al usuario ("~2-3 min").
2. Ejecuta `RUN_AUTOFIX=0 bash tests/shellTest/Frontend-test-Dev.sh`.
3. Si el runner sale verde (exit 0) → push permitido.
4. Si el runner falla (exit ≠ 0) → push rechazado.

**Por qué `RUN_AUTOFIX=0`**: el autofix ya corrió en pre-commit. Re-ejecutarlo en pre-push sería doble trabajo inútil y puede ocultar problemas reales (autofix silencioso en pre-push no avisa).

**Tiempo esperado**: ~2-3 min (runner completo: 14 grupos).

**Qué cubre**: ESLint, Stylelint, Prettier, TypeScript, Vitest (81 tests), Vite build, Storybook build, Servicios (frontend-dev + storybook-dev), Playwright smoke (14), Playwright a11y (7), Storybook manager E2E (2), Auto-fix (skip por `RUN_AUTOFIX=0`), Hooks (RUN_HOOKS 3/3).

**Puertos**: al terminar, `verify_ports_released_after_cleanup` valida que `:3000` y `:3010` quedan libres. Si no, avisa (pero no mata procesos ajenos).

**Relación con el resto de la cadena**:

| Hook         | Velocidad | Scope                    | Bloquea si                         |
| ------------ | --------- | ------------------------ | ---------------------------------- |
| `pre-commit` | <15 s     | `lint-staged` + `tsc -b` | Lint no autofixeable / tipos rotos |
| `commit-msg` | <2 s      | `commitlint`             | Formato de commit inválido         |
| `pre-push`   | ~2-3 min  | Runner completo          | Cualquier `[W-NEW]` / `[E-NEW]`    |

**Prohibiciones**:

- `git push --no-verify` solo en emergencia documentada (mensaje de commit relacionado debe incluir `no-verify: <motivo>`).
- No modificar el hook para skipear el runner "porque tarda". Si tarda, es porque el código tiene problemas.

## 15. Convenciones de código

- TypeScript estricto. Sin any (usar unknown y narrowing).
- **Motion (obligatorio)**: `gsap@3.13.x` + `gsap/ScrollTrigger` + `@gsap/react@2.1.x` + `lenis@1.1.x` + `split-type` (alternativa libre a `gsap/SplitText`, que requiere Club GSAP). Versiones pineadas (sin `^` ni `~`). El sistema completo vive en §24.
- ESLint 9.39.5 (fijado por ADR `docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/eslint-9-eol.md`) + Prettier 3.9.9 + `eslint-config-prettier` + `eslint-plugin-import` + `eslint-plugin-jsx-a11y` + `eslint-plugin-simple-import-sort` + `eslint-plugin-react-hooks` + `eslint-plugin-react-refresh`.
- Stylelint 17.15.0 (fijado por ADR `docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/stylelint-scope-y-colores.md`) + `stylelint-config-standard` 40.0.0 + `stylelint-config-css-modules` 4.6.0 + `stylelint-config-recess-order` 7.8.0 + `stylelint-order` 8.1.1.
- Reglas de CSS obligatorias **en nivel `error`**:
  - `declaration-no-important: true` — prohíbe `!important` (agente-frontend §19).
  - `selector-class-pattern: "^[a-z][a-zA-Z0-9]*$"` — clases en **camelCase**.
  - `recess-order` — orden de propiedades (evita deuda de desorden).
  - Scripts separados: `lint:css` y `lint:css:fix` (ver ADR-0002).
  - **Orden de ejecución**: Prettier antes de Stylelint en el flujo local (`npx prettier --write ... && npx stylelint ... --fix`). Ver ADR-0002 §Decisión 3.
- Reglas obligatorias **en nivel `error`** (no `warn`):
  - `eslint-plugin-jsx-a11y` (WCAG 2.2 AA)
  - `eslint-plugin-import` (`no-unresolved`, `no-cycle`, `no-duplicates`, `first`, `newline-after-import`)
  - `simple-import-sort` (orden de imports)
- `strict: true` obligatorio en `tsconfig.app.json` y `tsconfig.node.json`.
- Sin `^` ni `~` en `frontend/package.json`. Todo pineado con `save-exact=true` en `frontend/.npmrc`.
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
- Resolución de alias: nativa en Vite 8 (`resolve.tsconfigPaths: true`) + `tsconfig.paths.json` (fuente única).
- Limitaciones conocidas (no son deuda técnica, son límites del ecosistema):
  - **`import/no-unresolved` desactivado**: el resolver de ESLint (`eslint-import-resolver-typescript`) no soporta `paths` sin `baseUrl`. TypeScript 6+ deprecó `baseUrl`, así que se desactivó esa regla. La validación real la hace el propio `tsc`.
  - Los alias funcionan también para CSS (`.css`, `.module.css`) gracias al soporte nativo de Vite 8 (`resolve.tsconfigPaths: true`).

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
15. **Motion**: nunca escribir animaciones inline en vistas. Todo va por hooks de `shared/hooks/` (§24.2). Si ya existe un hook, reutilizarlo. Reglas completas en §24.7.
16. **`SineWaveButton` no hereda de `Button`**: es un átomo independiente (§24.3.1). Si se necesita compartir estilos, extraer un `useButtonStyles` compartido.

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
- [ ] **Motion**: efectos encapsulados en hooks de `shared/hooks/` (cero lógica de animación en vistas).
- [ ] **Motion**: `useGSAP()` con `scope` + respeto de `prefers-reduced-motion: reduce` (test unitario incluido).
- [ ] **Motion**: solo se animan `transform` y `opacity`. `will-change` solo mientras la animación corre.
- [ ] **Motion**: Lenis inicializado únicamente en `SmoothScrollProvider`.
- [ ] **Motion**: frame budget medido y documentado en el PR.

---

## 19. Anti-patrones prohibidos

- Ejecutar `npm audit fix --force` o `npm audit fix --legacy-peer-deps`. Ver
  política en [ADR-0004](../tecnica/04-frontend-react-css-moderno/deuda-tecnica/vulnerabilidades-policy.md)
  y log en [`cvss-deuda-seguridad.md`](../tecnica/04-frontend-react-css-moderno/seguridad/cvss-deuda-seguridad.md).
  El fix sugerido por npm suele ser un downgrade mayor que rompe el stack.
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
- **Motion**: usar `useEffect` + `requestAnimationFrame` en vez de `gsap.ticker` / `useGSAP()`.
- **Motion**: animar `width`, `height`, `top`, `left`, `margin`, `box-shadow` o dejar `will-change` permanente.
- **Motion**: instanciar Lenis o `ScrollTrigger` dentro de vistas individuales. Debe ir en `SmoothScrollProvider` (§24.4).
- **Motion**: hardcodear colores, tamaños, formas o velocidades en los componentes de motion. Todo por props con tokens.
- **Motion**: extender `Button` para crear `SineWaveButton`. Es un átomo independiente (§24.3.1).
- **Motion**: crear animaciones sin respetar `prefers-reduced-motion: reduce`.

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

## 22. Ciclo de vida de los ADRs

En este proyecto los ADRs **registran deudas técnicas pendientes**, no decisiones
arquitectónicas permanentes.

### Reglas

1. **Al crear un ADR**: su estado siempre es `🟡 Pendiente`.
2. **Nunca** un ADR queda en estado "Aceptada". Los ADRs son un registro temporal
   de deuda, no un archivo histórico.
3. **Cada ADR DEBE tener una tarea que lo resuelva**, identificada en el campo
   `**Se resuelve en**:`. Al crear el ADR:
   - Si la tarea que resuelve la deuda **ya existe** → modificar el body de esa
     tarea agregando el bloque "**Trabajo derivado de TS-XXX**" con los checkboxes
     de resolución y la referencia al ADR.
   - Si la tarea **no existe** → **crear una nueva tarea** en el CAP/FT/US
     correspondiente, con el mismo bloque de resolución y la referencia al ADR.
4. **Al resolver la deuda** (desde la tarea referenciada):
   - **Eliminar** el archivo del ADR de `docs/tecnica/.../arquitectura/`.
   - **Mover** la documentación de la solución al archivo correspondiente
     (`storybook.md`, `cvss-deuda-seguridad.md`, etc.).
   - **Tachar la fila** en la tabla de ADRs de `README.md`.
   - **Marcar el check** `- [x] Resuelve ADR-XXXX` en el body de la tarea.

### Estructura obligatoria de un ADR

- `**Estado**: 🟡 Pendiente`
- `**Se resuelve en**: <task / issue>` (obligatorio; nunca "sin fecha").
- `**Documentación final**: <ruta del doc donde migrará la solución>`.

Y al final, sección **"Gatillo de resolución"** con el procedimiento.

### Regla de lectura obligatoria

Cuando se vaya a modificar cualquier artefacto que dependa de un ADR, **leer el archivo completo del ADR** — no solo la fila de la tabla resumen. Los ADRs contienen contexto, motivos, gatillos de revisión y consecuencias que no caben en una fila.

### Ejemplos activos

| ADR      | Se resuelve en | Documentación final                 |
| -------- | -------------- | ----------------------------------- |
| ADR-0001 | TS-142 (#760)  | `convenciones/convenciones.md`      |
| ADR-0002 | TS-022 (#627)  | `convenciones/convenciones.md`      |
| ADR-0003 | TS-031 (#636)  | `convenciones/convenciones.md`      |
| ADR-0004 | TS-143 (#761)  | `seguridad/cvss-deuda-seguridad.md` |
| ADR-0005 | TS-024 (#629)  | `convenciones/storybook.md`         |
| ADR-0006 | TS-026 (#631)  | `convenciones/storybook.md`         |
| ADR-0007 | TS-070 (#675)  | `convenciones/storybook.md`         |

---

## 23. Referencias cruzadas entre documentos

- README.md (raíz del proyecto): estado general, versión vigente, endpoints publicados, stack, arquitectura, modelo de datos, seguridad, ofuscación, auditoría, Scrum. Es la fuente principal.
- docs/prompts/prompt_inicial.md: idea general del proyecto, requisitos funcionales, reglas para la IA, directrices por capa y flujo obligatorio por issue.
- docs/agente-frontend.md: este documento. Reglas de construcción del frontend.
- docs/prompts/agente-backend.md y docs/prompts/agente-database.md: documentos hermanos. Respetan las mismas reglas de fuentes de verdad y solicitud de archivos.
- docs/tecnica/\*\*/\*.md y docs/tecnica/\*\*/\*.sql: documentación técnica por capítulo del README.
  - Convención: `docs/tecnica/<NN-nombre-del-capítulo-en-kebab-case>/<subcategoría>/<archivo>.md|.sql`.
  - Capítulo de frontend: `docs/tecnica/04-frontend-react-css-moderno/` (se puebla con CAP-01).
  - Capítulo de backend: `docs/tecnica/03-backend-java-spring-boot-3x/`.
  - Capítulo de base de datos: `docs/tecnica/02-base-de-datos/`.

Regla de consistencia:

- Cualquier cambio en README.md o prompt_inicial.md que afecte al frontend debe reflejarse en este archivo en el mismo PR.
- Cualquier convención nueva de este archivo debe reflejarse en README.md (sección de estructura) y, si aplica, en prompt_inicial.md.

---

## 24. Motion System

Esta sección define cómo se construyen las animaciones e interacciones de movimiento en el frontend. Su objetivo es replicar la calidad de interacción de webs de referencia (por ejemplo, la plantilla _Alyssa_ de Framer: cursor personalizado, campos de luz, scroll-reveal de titulares, cintas móviles, botones con onda al hover) sin sacrificar rendimiento, accesibilidad ni la arquitectura ya definida en este documento.

Las animaciones son **parte del Design System**: viven en `shared/hooks/`, `components/` y `app/providers/`, no se escriben inline dentro de las vistas.

### 24.1 Librerías obligatorias

Se instalan con versión exacta (sin `^` ni `~`, según `frontend/.npmrc` con `save-exact=true`):

| Librería             | Versión mínima     | Uso                                                                            |
| :------------------- | :----------------- | :----------------------------------------------------------------------------- |
| `gsap`               | 3.13.x             | Motor de animación principal (timelines, easing, ticker).                      |
| `gsap/ScrollTrigger` | (incluido en gsap) | Sincronización de animaciones con la posición del scroll.                      |
| `gsap/SplitText`     | (Club GSAP)        | División de texto en palabras/caracteres. **Alternativa libre**: `split-type`. |
| `lenis`              | 1.1.x              | Scroll suave (smooth scrolling) sincronizado con el ticker de GSAP.            |
| `@gsap/react`        | 2.1.x              | Hook oficial `useGSAP()` para integración limpia con React 19.                 |

Reglas:

- `useGSAP()` es obligatorio en lugar de `useEffect` para cualquier animación GSAP. Gestiona el cleanup automáticamente y evita memory leaks en el StrictMode de React 19.
- Prohibido mezclar `requestAnimationFrame` propio con el ticker de GSAP. Todo pasa por `gsap.ticker`.
- Si `SplitText` no está disponible por licencia, usar `split-type` y documentarlo en el ADR correspondiente.

### 24.2 Hooks obligatorios en `shared/hooks/`

Todo efecto de movimiento reutilizable se encapsula en un hook. Ninguna vista ni componente implementa la lógica directamente.

| Hook                   | Responsabilidad                                                                                                                             | Efecto de referencia                     |
| :--------------------- | :------------------------------------------------------------------------------------------------------------------------------------------ | :--------------------------------------- |
| `useLenisScroll.ts`    | Inicializa Lenis, lo enlaza al `gsap.ticker` y a `ScrollTrigger.update`. Devuelve la instancia y un `scrollTo(target)`.                     | Scroll suave global.                     |
| `useCursorFollower.ts` | Crea y anima un elemento que sigue al cursor con `gsap.quickTo()` (spring suave). Devuelve la `ref` que debe montarse.                      | Cursor personalizado de Alyssa.          |
| `useSineWaveButton.ts` | Dispara una timeline de N anillos expansivos concéntricos con `stagger` al `hover` o `click`. Recibe la `ref` del botón y la configuración. | Botones con onda al hover/click.         |
| `useTextReveal.ts`     | Divide un titular en palabras y anima `color` de muted → primary palabra por palabra con `ScrollTrigger` + `scrub`.                         | Titulares que se iluminan con el scroll. |
| `useMarquee.ts`        | Anima un track duplicado con `translateX` infinito. Acepta `speed`, `direction`, `pauseOnHover`, `gap` y `repeat`.                          | Cintas móviles.                          |
| `useAuraBackground.ts` | Anima uno o varios gradientes radiales que se desplazan según la configuración recibida.                                                    | Campos de luz / Aura.                    |
| `useParallax.ts`       | Aplica `y` u `x` proporcional al scroll con `ScrollTrigger.scrub`.                                                                          | Parallax genérico.                       |
| `useRevealOnScroll.ts` | Animación de entrada (fade + translateY) para secciones y tarjetas. Reemplaza a AOS.                                                        | Scroll reveal estándar.                  |

Reglas:

- Todos los hooks respetan `prefers-reduced-motion: reduce` (ver §24.7).
- Todos los hooks devuelven `ref` tipadas (`RefObject<HTMLElement>`) y nunca manipulan el DOM por `querySelector`.
- Todos los hooks limpian sus timelines y listeners en el cleanup (garantizado por `useGSAP()`).
- Todos los hooks detectan capacidades del dispositivo: `useCursorFollower` y `useSineWaveButton` (modo `hover`) solo se activan si `matchMedia('(hover: hover) and (pointer: fine)')` es verdadero (no en táctil).

### 24.3 Componentes obligatorios

Ubicados según la jerarquía del Design System (§4). **Todos los componentes de motion son altamente configurables por props** para que puedan reutilizarse en cualquier vista sin duplicar código.

| Componente         | Ubicación                            | Tipo     | Descripción                                                                                                                                   |
| :----------------- | :----------------------------------- | :------- | :-------------------------------------------------------------------------------------------------------------------------------------------- |
| `CursorFollower`   | `components/atoms/CursorFollower/`   | Átomo    | Elemento visual que sigue al cursor. Montado una sola vez en `AppShell` y en `PublicHeader`.                                                  |
| `ScrollRevealText` | `components/atoms/ScrollRevealText/` | Átomo    | Titular o párrafo que se ilumina palabra por palabra con el scroll.                                                                           |
| `Marquee`          | `components/molecules/Marquee/`      | Molécula | Cinta de texto, íconos o imágenes con desplazamiento infinito.                                                                                |
| `AuraBackground`   | `components/atoms/AuraBackground/`   | Átomo    | Fondo con una o varias formas (gradientes, círculos, blobs) animadas.                                                                         |
| `SineWaveButton`   | `components/atoms/SineWaveButton/`   | Átomo    | Botón independiente que dispara N anillos expansivos al `hover` o `click`. **No es una variante de `Button`**: es un átomo propio con su API. |

Cada componente cumple la estructura obligatoria de §4:

```text
components/<nivel>/<ComponentName>/
├── <ComponentName>.tsx
├── <ComponentName>.module.css
├── <ComponentName>.types.ts
├── <ComponentName>.test.tsx
├── <ComponentName>.stories.tsx
└── index.ts
```

#### 24.3.1 `SineWaveButton` — API configurable

Átomo independiente. **No** extiende `Button`; es un botón propio con su estilo, su accesibilidad y su animación de onda. Si en el futuro se necesita reutilizar estilos base, se extrae un `useButtonStyles` compartido, nunca se hace herencia de componentes.

Props (`SineWaveButton.types.ts`):

| Prop           | Tipo                                              | Default                      | Descripción                                                 |
| :------------- | :------------------------------------------------ | :--------------------------- | :---------------------------------------------------------- |
| `children`     | `ReactNode`                                       | —                            | Contenido del botón (label, ícono + label).                 |
| `onClick`      | `() => void`                                      | —                            | Handler estándar.                                           |
| `variant`      | `'primary' \| 'secondary' \| 'ghost' \| 'danger'` | `'primary'`                  | Estilo visual base.                                         |
| `size`         | `'sm' \| 'md' \| 'lg'`                            | `'md'`                       | Tamaño del botón.                                           |
| `disabled`     | `boolean`                                         | `false`                      | Deshabilita el botón y desactiva la onda.                   |
| `loading`      | `boolean`                                         | `false`                      | Muestra spinner y desactiva la onda.                        |
| `trigger`      | `'hover' \| 'click' \| 'both'`                    | `'hover'`                    | Cuándo se dispara la onda.                                  |
| `ringCount`    | `number`                                          | `3`                          | Número de anillos concéntricos.                             |
| `ringDuration` | `number` (ms)                                     | `600`                        | Duración de cada anillo.                                    |
| `ringStagger`  | `number` (ms)                                     | `120`                        | Separación entre anillos.                                   |
| `ringMaxScale` | `number`                                          | `1.6`                        | Escala máxima del anillo al expandirse.                     |
| `ringColor`    | `string` (token)                                  | `var(--color-primary-alpha)` | Color del anillo. Debe ser un token, no un hex hardcodeado. |
| `ringEasing`   | `string`                                          | `'power2.out'`               | Easing GSAP de la expansión.                                |
| `ariaLabel`    | `string`                                          | —                            | Etiqueta accesible si el contenido no es texto.             |
| `type`         | `'button' \| 'submit' \| 'reset'`                 | `'button'`                   | Tipo HTML.                                                  |
| `dataTestId`   | `string`                                          | —                            | `data-testid` para tests.                                   |

Reglas de implementación:

- Los anillos se implementan con **`<span aria-hidden="true">` internos**, nunca con `box-shadow` animado (mata el rendimiento).
- El botón **no se desplaza** con el cursor. El efecto es puramente visual (onda), no magnético.
- Si `trigger === 'hover'`, la onda se dispara en `mouseenter` (una vez por entrada).
- Si `trigger === 'click'`, la onda se dispara en `pointerdown` y se reinicia en cada click.
- Si `trigger === 'both'`, se dispara en ambos.
- Si `prefers-reduced-motion: reduce` o el dispositivo es táctil, no se dispara la onda; el botón conserva su `:hover`/`:active` estándar.
- `ringCount` se valida entre 1 y 6. Fuera de rango, se hace fallback a 3 y se registra un `console.warn` en desarrollo.
- El foco visible (`:focus-visible` con `focus-ring` de `styles/mixins/` (creado en TS-145)) es independiente del efecto de onda.
- Stories obligatorias: `Default`, `Hover`, `Click`, `Both`, `Variants`, `Sizes`, `Loading`, `Disabled`, `RingCount1`, `RingCount6`, `ReducedMotion`, `DarkMode`.

#### 24.3.2 `Marquee` — API configurable

Molécula reutilizable para cintas de texto, íconos o imágenes.

Props (`Marquee.types.ts`):

| Prop           | Tipo                                  | Default          | Descripción                                                             |
| :------------- | :------------------------------------ | :--------------- | :---------------------------------------------------------------------- |
| `items`        | `ReactNode[]`                         | —                | Ítems a desplazar. Pueden ser strings, íconos, imágenes o componentes.  |
| `speed`        | `number` (px/s)                       | `60`             | Velocidad del desplazamiento. Valores negativos invierten la dirección. |
| `direction`    | `'left' \| 'right' \| 'up' \| 'down'` | `'left'`         | Dirección del movimiento.                                               |
| `gap`          | `string` (token)                      | `var(--space-6)` | Separación entre ítems.                                                 |
| `repeat`       | `number`                              | `2`              | Número de copias del track para garantizar continuidad. Mínimo 2.       |
| `pauseOnHover` | `boolean`                             | `true`           | Pausa el desplazamiento al pasar el mouse.                              |
| `fadeEdges`    | `boolean`                             | `true`           | Degradado en los bordes para suavizar entrada/salida.                   |
| `fadeWidth`    | `string`                              | `'10%'`          | Ancho del degradado lateral.                                            |
| `ariaLabel`    | `string`                              | —                | Descripción accesible del contenido del marquee.                        |
| `dataTestId`   | `string`                              | —                | `data-testid` para tests.                                               |
| `className`    | `string`                              | —                | Clase adicional para integración.                                       |

Reglas de implementación:

- El track se duplica `repeat` veces para garantizar un loop sin saltos. La animación se aplica con `gsap.to()` sobre `xPercent` (o `yPercent` si es vertical), con `repeat: -1` y `ease: 'none'`.
- La duración se calcula en base a `speed` y al ancho real del track (`track.offsetWidth / speed`), recalculado en `resize` con `ResizeObserver`.
- En `prefers-reduced-motion: reduce`, el track se muestra estático, sin loop.
- El contenido va **siempre** por i18n si es texto visible (§7).
- Stories obligatorias: `Default`, `Right`, `Vertical`, `Slow`, `Fast`, `WithImages`, `WithIcons`, `PauseOnHover`, `FadeEdges`, `ReducedMotion`.

#### 24.3.3 `AuraBackground` — API configurable

Átomo que renderiza una o varias formas animadas de fondo (gradientes radiales, círculos, blobs).

Props (`AuraBackground.types.ts`):

| Prop           | Tipo           | Default  | Descripción                                                   |
| :------------- | :------------- | :------- | :------------------------------------------------------------ |
| `shapes`       | `AuraShape[]`  | (preset) | Array de formas a renderizar. Ver tipo abajo.                 |
| `speed`        | `number`       | `1`      | Multiplicador de velocidad de la animación. `0` = estático.   |
| `intensity`    | `number` (0–1) | `0.6`    | Opacidad global de las formas.                                |
| `followCursor` | `boolean`      | `false`  | Si `true`, las formas reaccionan a la posición del cursor.    |
| `parallax`     | `boolean`      | `true`   | Si `true`, las formas reaccionan al scroll con leve parallax. |
| `blur`         | `string`       | `'80px'` | Desenfoque global aplicado a las formas.                      |
| `className`    | `string`       | —        | Clase adicional.                                              |
| `dataTestId`   | `string`       | —        | `data-testid` para tests.                                     |

Tipo `AuraShape`:

```ts
export interface AuraShape {
  /** Identificador único dentro del array. */
  id: string;
  /** Forma de la figura. */
  shape: "circle" | "ellipse" | "blob";
  /** Tamaño en unidades CSS (px, rem, %). */
  size: string;
  /** Posición inicial en el contenedor (top/left/right/bottom + valor CSS). */
  position: { top?: string; left?: string; right?: string; bottom?: string };
  /** Color del gradiente. Token obligatorio, no hex hardcodeado. */
  color: string;
  /** Blur específico de esta forma (sobrescribe el global). */
  blur?: string;
  /** Opacidad específica de esta forma (sobrescribe `intensity`). */
  opacity?: number;
  /** Desplazamiento animado en X y Y (en %). */
  movement?: { x: number; y: number };
  /** Duración base del ciclo en segundos. */
  duration?: number;
  /** Retraso inicial de la animación en segundos. */
  delay?: number;
}
```

Reglas de implementación:

- La animación usa `gsap.to()` sobre `xPercent`/`yPercent` y `scale` con `yoyo: true`, `repeat: -1`.
- `followCursor` usa `gsap.quickTo()` para evitar recalcular en cada `mousemove`.
- En `prefers-reduced-motion: reduce`, todas las formas se muestran estáticas en su posición base.
- El contenedor lleva `aria-hidden="true"` y `pointer-events: none`.
- El componente es **decorativo**: nunca comunica información.
- Stories obligatorias: `Default`, `SingleShape`, `MultipleShapes`, `FollowCursor`, `Parallax`, `Fast`, `Slow`, `ReducedMotion`.

#### 24.3.4 `CursorFollower` — API configurable

Átomo que reemplaza visualmente al cursor nativo. Se monta **una sola vez** por layout (`AppShell` para vistas autenticadas, `PublicHeader` para públicas).

Props (`CursorFollower.types.ts`):

| Prop               | Tipo                                      | Default                                 | Descripción                                                                 |
| :----------------- | :---------------------------------------- | :-------------------------------------- | :-------------------------------------------------------------------------- |
| `shape`            | `'circle' \| 'dot' \| 'square' \| 'blob'` | `'circle'`                              | Forma del seguidor.                                                         |
| `size`             | `number` (px)                             | `24`                                    | Tamaño base.                                                                |
| `background`       | `string` (token)                          | `var(--color-primary)`                  | Fondo del cursor. Acepta tokens o `transparent`.                            |
| `border`           | `string`                                  | `'none'`                                | Borde (ej. `2px solid var(--color-primary)`).                               |
| `boxShadow`        | `string`                                  | `'0 0 24px var(--color-primary-alpha)'` | Sombra del cursor.                                                          |
| `mixBlendMode`     | `CSSProperties['mixBlendMode']`           | `'normal'`                              | Modo de fusión (útil para invertir sobre fondos).                           |
| `opacity`          | `number` (0–1)                            | `1`                                     | Opacidad del cursor.                                                        |
| `speed`            | `number`                                  | `0.4`                                   | Factor de suavizado (`gsap.quickTo`). `1` = instantáneo, `0.1` = muy suave. |
| `scaleOnHover`     | `number`                                  | `2.5`                                   | Escala al pasar sobre elementos con `data-cursor="hover"`.                  |
| `scaleOnPress`     | `number`                                  | `0.8`                                   | Escala al hacer click.                                                      |
| `hideNativeCursor` | `boolean`                                 | `true`                                  | Oculta el cursor nativo en el `body`.                                       |
| `visibleOnTouch`   | `boolean`                                 | `false`                                 | Si `false`, no se monta en dispositivos táctiles.                           |
| `dataTestId`       | `string`                                  | —                                       | `data-testid` para tests.                                                   |

Reglas de implementación:

- El elemento se anima con `gsap.quickTo()` sobre `x` e `y` (nunca `left`/`top`).
- `hideNativeCursor` aplica `cursor: none` al `body` **y restaura el cursor nativo** en `input`, `textarea`, `select`, `[contenteditable]` y elementos con `data-cursor="native"`.
- Al pasar sobre elementos con `data-cursor="hover"`, se escala a `scaleOnHover`. Al pasar sobre `data-cursor="native"`, se oculta el seguidor.
- `scaleOnPress` se dispara en `pointerdown` y se revierte en `pointerup`.
- El seguidor lleva `aria-hidden="true"` y `pointer-events: none`.
- En `prefers-reduced-motion: reduce` o en táctil (si `visibleOnTouch: false`), no se monta y se usa el cursor nativo.
- Stories obligatorias: `Default`, `Dot`, `Square`, `Blob`, `BlendModeDifference`, `WithBorder`, `CustomShadow`, `ReducedMotion`.

### 24.4 Provider de scroll suave

Lenis se inicializa **una sola vez** a nivel de aplicación, dentro de `app/providers/`.

- Nuevo archivo: `app/providers/SmoothScrollProvider.tsx`.
- Se añade a `AppProviders.tsx` **por encima** de `ThemeProvider` y por debajo de `ErrorBoundaryProvider`.
- Responsabilidades del provider:
  1. Instanciar Lenis con `{ duration: 1.2, easing: t => Math.min(1, 1.001 - Math.pow(2, -10 * t)) }`.
  2. Suscribirse a `lenis.on('scroll', ScrollTrigger.update)`.
  3. Registrar el `raf` de Lenis en `gsap.ticker.add((time) => lenis.raf(time * 1000))` y desactivar el lag smoothing (`gsap.ticker.lagSmoothing(0)`).
  4. Exponer el contexto con `useLenis()` para que las vistas puedan hacer `scrollTo`.
  5. En el cleanup, destruir Lenis y remover el ticker.
- Prohibido instanciar Lenis dentro de vistas o componentes individuales.

Los textos de los marquees y titulares **pasan por i18n** (§7). Se añaden claves en `i18n/es/initPage/index.json` y `i18n/en/initPage/index.json` en el mismo PR.

### 24.5 Reglas de performance

Presupuesto de motion (complementa §13):

- **Solo se animan `transform` y `opacity`.** Prohibido animar `width`, `height`, `top`, `left`, `margin` o `box-shadow` (provocan layout/paint costoso).
- `will-change: transform` **solo** se declara mientras la animación está activa y se retira al terminar (usar `onStart`/`onComplete` de GSAP). Prohibido dejarlo permanente.
- `gsap.quickTo()` es obligatorio para animaciones de alta frecuencia (cursor follower, parallax con scrub). Nunca `gsap.to()` por cada `mousemove` o `scroll` event.
- Los `ScrollTrigger` se registran una sola vez y se reutilizan. Prohibido crear triggers dentro de bucles `map` sin `ScrollTrigger.batch()`.
- `useGSAP()` con `scope` obligatorio para que las animaciones se destruyan con el componente.
- Cualquier animación que supere 1 ms de frame budget en el profiler de React DevTools debe justificarse en el PR.
- Lighthouse Performance ≥ 90 se mantiene como criterio de "Done" (§18).
- `CursorFollower`, `AuraBackground` y `Marquee` se cargan **lazy** dentro de sus vistas si aportan peso significativo al bundle inicial (medir con `bundle-analyze.mjs`).

### 24.6 Accesibilidad y `prefers-reduced-motion`

- Todos los hooks detectan `window.matchMedia('(prefers-reduced-motion: reduce)')` y, si está activo:
  - `useCursorFollower` no monta el cursor personalizado (se usa el nativo).
  - `useSineWaveButton` no dispara la onda (queda el `:hover`/`:active` estándar).
  - `useTextReveal` muestra el texto en su estado final iluminado de inmediato.
  - `useMarquee` detiene el desplazamiento (el contenido se muestra estático).
  - `useAuraBackground` congela las formas en su posición base.
  - `useParallax` y `useRevealOnScroll` aplican el estado final sin transición.
- El cursor personalizado **nunca** oculta información ni impide la interacción. El cursor nativo se oculta solo con `cursor: none` sobre el `body` y se restaura en inputs, textareas y elementos editables.
- `CursorFollower` y `AuraBackground` llevan `aria-hidden="true"` y `pointer-events: none`.
- `SineWaveButton` conserva el foco visible (`:focus-visible` con `focus-ring` de `styles/mixins/` (creado en TS-145)), independientemente del efecto de onda.
- Ninguna animación es la única forma de transmitir información (WCAG 1.3.3, 2.2.2).
- Los tests E2E de a11y (`tests/e2e/a11y.spec.ts`) deben correr también con `prefers-reduced-motion: reduce` (Playwright permite emularlo).

### 24.7 Reglas para agentes IA sobre motion

Además de las reglas de §17:

1. Antes de crear un efecto, verificar si ya existe un hook en `shared/hooks/` que lo cubra. No duplicar.
2. Todo componente nuevo de motion debe incluir: `.tsx`, `.module.css`, `.types.ts`, `.test.tsx`, `.stories.tsx`, `index.ts` (§4).
3. Toda animación nueva debe añadir su story en Storybook (`Default` + `ReducedMotion` + las variantes específicas de cada componente de §24.3).
4. Todo hook nuevo debe añadir test unitario que verifique: (a) cleanup correcto al desmontar, (b) comportamiento con `prefers-reduced-motion: reduce`, (c) que las props por defecto coincidan con la tabla de §24.3.
5. Si se necesita una librería de animación distinta a GSAP + Lenis, solicitar autorización explícita y registrar ADR (§22).
6. No animar nunca `width`/`height`/`top`/`left`. Si el efecto lo requiere, rediseñar con `transform`.
7. Documentar en el PR la medición de frame budget del efecto (React DevTools Profiler o Chrome Performance).
8. Actualizar §24.5 si se añade una sección nueva a `initPage` con su efecto correspondiente.
9. **Nunca hardcodear colores, tamaños, formas o velocidades** en los componentes de motion. Todo se expone por props con tokens y defaults documentados.
10. **`SineWaveButton` no hereda de `Button`**. Si en el futuro se necesita compartir estilos, se extrae un hook (`useButtonStyles`) y se reutiliza, sin herencia de componentes.

---

Fin del documento.
