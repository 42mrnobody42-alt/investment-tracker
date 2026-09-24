# Kanban local — Investment Tracker

Toda la planificación vive versionada en este directorio y se sincroniza con el
Project V2 [#2](https://github.com/users/42mrnobody42-alt/projects/2).

## Jerarquía

CAP-XX → FT-XXX → US-XXX → TS-XXX

## REGLA OBLIGATORIA — Contenido mínimo por issue

**Todos los issues (CAP, FT, US, TS) DEBEN tener:**

1. `## Contexto` — por qué existe, qué problema resuelve. 2-4 líneas.
2. `## Alcance` (o `## Entregable` en TS) — qué se produce concretamente.
3. `## Criterios de aceptación` — lista con `- [ ]` marcables como cumplidos.
4. `## Dependencias` — qué debe existir antes.

En TS además: 5. `## Estimación` — horas (≤4h). 6. `## US padre` — referencia a US-XXX.

Plantillas en `docs/scrum/kanban/templates/`.

**Ningún issue se considera "Done" hasta que todos los checkboxes de criterios
de aceptación estén marcados.**

## Estados

| Nombre exacto | Alias en kanban-move.sh | Significado            |
| ------------- | ----------------------- | ---------------------- |
| `Backlog`     | `backlog`               | Sin priorizar          |
| `Ready`       | `ready`                 | Listo para trabajar    |
| `In progress` | `progress`              | En desarrollo          |
| `In review`   | `review`                | PR abierto             |
| `Done`        | `done`                  | Mergeado a `developer` |

## Scripts

| Script                                   | Función                             |
| ---------------------------------------- | ----------------------------------- |
| `create-cap01.sh`                        | Crea CAP-01 + 9 FT + 41 US + 141 TS |
| `delete-cap01.sh`                        | Elimina todos los issues de CAP-01  |
| `kanban-move.sh <N> <alias>`             | Mueve entre estados                 |
| `kanban-comment.sh <N> <sha> "<título>"` | Comenta SHA + cambios               |
| `retry-links.sh`                         | Revincula sub-issues huérfanos      |

## Flujo por unidad de trabajo

1. `gh project item-list 2 --owner 42mrnobody42-alt` — ver estado
2. `git checkout developer && git pull && git checkout -b feature/<ID>`
3. `./scripts/kanban-move.sh <N> progress` — mover padre + hijos directos
4. Commit con `tipo(#N): descripción` + `Closes #N`
5. `./scripts/kanban-comment.sh <N> <sha> "<título>"`
6. `./scripts/kanban-move.sh <N> review`
7. `gh pr create --base developer`
8. Al merge: `./scripts/kanban-move.sh <N> done`
