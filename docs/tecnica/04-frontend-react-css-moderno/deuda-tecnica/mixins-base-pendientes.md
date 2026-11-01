# ADR-0008 — Mixins base de estilos (focus-ring, container, truncate)

- **Estado**: 🟡 Pendiente
- **Fecha**: 2026-10-11
- **Capa**: Frontend (React + TypeScript + Vite + Stylelint)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: US-007 (#571), US-010 (#574), US-011 (#575), US-013 (#577), US-014 (#578), TS-144, TS-145 (#766)
- **Reemplaza a**: (ninguno)
- **Reemplazado por**: (pendiente)
- **Se resuelve en**: TS-145 (#766)
- **Documentación final**: `convenciones/convenciones.md`

## Contexto

Los tokens de diseño viven en `frontend/src/styles/branding/` (TS-144). Sin embargo,
los **mixins de utilidad** (`focus-ring`, `container`, `truncate`) — que dan a los
componentes los patrones reutilizables de accesibilidad, responsividad y manejo de
texto — aún no existen. Varios átomos y moléculas de US-010, US-011, US-013 y
US-014 dependen de ellos para cumplir WCAG 2.2 AA y evitar duplicación de estilos.

## Decisión

Crear los 3 mixins base en una tarea separada (TS-145) **antes** de que arranquen
los componentes que los consumen. Los mixins son infraestructura transversal, no
pertenecen al scope de ninguna US de componentes. Mientras no existan, US-007,
US-010, US-011, US-013 y US-014 quedan bloqueadas.

## Por qué (importancia y objetivo)

### `focus-ring.css`

**Qué resuelve**: el outline de foco consistente cuando el usuario navega con
teclado (Tab) sobre elementos interactivos.

**Valor de negocio**: WCAG 2.2 AA exige foco visible en **todo** elemento
interactivo. Sin mixin, cada dev define su propio foco → inconsistencia visual
y riesgo de incumplir el contrato de accesibilidad.

**Consumidores**: Button, Input, Select, Checkbox, Radio, Switch (US-010);
Tabs, Dropdown, Accordion (US-013); links del AppShell.

**Costo de no tenerlo**: retrabajo en ~20 componentes cuando se audite la
accesibilidad.

### `container.css`

**Qué resuelve**: patrones de container queries reutilizables para que los
componentes reaccionen al ancho de **su contenedor**, no al viewport.

**Valor de negocio**: los componentes conviven en horizontal (PC/TV) y vertical
(móvil/tablet retrato). Con container queries, un DataTable en un sidebar angosto
se adapta sin reescribir estilos; el layout responsivo funciona por composición,
no por duplicación.

**Consumidores**: Card, DataTable, ChartPanel, FormField, todas las vistas
responsivas.

**Costo de no tenerlo**: breakpoints duplicados en cada componente, layouts
inconsistentes entre horizontal y vertical.

### `truncate.css`

**Qué resuelve**: corte de texto largo con `...` (ellipsis) de forma consistente.

**Valor de negocio**: los usuarios ingresan textos variables (nombres de empresa,
símbolos, notas, emails). Sin truncado consistente, las tablas se rompen y la
información visual se degrada, sobre todo en móvil.

**Consumidores**: DataTable (nombre empresa), SidebarMenu (ítems), UserMenu
(nombre usuario), Toast (mensajes largos).

**Costo de no tenerlo**: tablas rotas en producción, UX degradada en móvil.

## Consecuencias

### Positivas

- Los 4 átomos y moléculas consumidoras arrancan con base sólida.
- Un solo origen para foco, container queries y truncado.
- Menos retrabajo cuando se audite la accesibilidad.

### Negativas

- US-007, US-010, US-011, US-013 y US-014 quedan bloqueadas hasta que TS-145
  se cierre.

## Referencias

- `docs/prompts/agente-frontend.md` §2 (estructura `styles/mixins/`).
- `docs/prompts/agente-frontend.md` §9 (Estilos y theming).
- `docs/prompts/agente-frontend.md` §12 (Accesibilidad — foco visible).
- `docs/prompts/agente-frontend.md` §24.6 (focus-ring de `styles/mixins/`).
- TS-144 — Archivos base de tokens en `styles/branding/`.
- TS-145 (#766) — Implementación de los mixins (cierra este ADR).

---

## Gatillo de resolución

Cuando TS-145 (#766) se cierre:

1. Eliminar este archivo.
2. Mover la documentación de los mixins a `convenciones/convenciones.md`.
3. Tachar la fila de ADR-0008 en la tabla de ADRs del `README.md`.
4. Marcar `- [x] Resuelve ADR-0008` en el body de TS-145.
