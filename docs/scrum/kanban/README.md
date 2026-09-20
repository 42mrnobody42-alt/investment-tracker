# 📋 Kanban Scrum — Investment Tracker Pro

Directorio de planificación local sincronizado con GitHub Projects.

## Estructura de la jerarquía
CAP-### Capability
└── FT-### Feature
└── US-### User Story
└── TS-### Task (≤4h)

- Una **Capability** agrupa Features que entregan un objetivo de negocio completo.
- Una **Feature** agrupa User Stories que aportan un módulo funcional.
- Una **User Story** describe una necesidad del usuario y se descompone en Tasks.
- Una **Task** es trabajo técnico concreto, estimado en máximo 4 horas.

## Directorios

| Directorio | Contenido |
|---|---|
| `capabilities/` | Un `.md` por capability (plan maestro) |
| `features/` | Un `.md` por feature |
| `user-stories/` | Un `.md` por user story |
| `tasks/` | Un `.md` por task |
| `scripts/` | Scripts de creación y sincronización |

## Flujo en GitHub Projects

1. **Idea / Requerimiento** → se crea un issue con label correspondiente (`capability`, `feature`, `user-story`, `task`).
2. El issue se agrega al Project y se prioriza (`Backlog` → `Ready`).
3. Al iniciar → se mueve a `In Progress` y se crea la rama `feature/*`.
4. Al abrir PR → `In Review`, vincular con `Closes #N`.
5. Al mergear a `developer` → `Done`.

## Convenciones

- **Ramas**: `feature/CAP-01-frontend-base`, `feature/FT-001-setup`, `feature/US-003-i18n`.
- **Commits**: `feat(#<issue>): descripción`, `fix(#<issue>): descripción`.
- **Ninguna funcionalidad se considera terminada** hasta que el issue esté en `Done` y la rama mergeada a `developer`.

## Tablero

- **Projects**: https://github.com/users/42mrnobody42-alt/projects/2
- **Repositorio**: https://github.com/42mrnobody42-alt/investment-tracker
