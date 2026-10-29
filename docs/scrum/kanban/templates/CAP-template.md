## Contexto

<Por qué existe esta capability. Qué problema de negocio resuelve. 3-5 líneas.>

## Alcance

- <Entregable 1>
- <Entregable 2>
- <Entregable 3>

## Features

- FT-XXX — <título>
- FT-XXX — <título>

## Criterios de aceptación

Cada criterio DEBE tener un código único `**CA_##:**` al inicio. El MISMO
código se usa como primer argumento de `check()` en el validador
(`/tmp/validate-capXX.sh`). Sin coincidencia código↔criterio, la validación
no cubre el criterio.

- [ ] **CA_01:** <criterio verificable 1>
- [ ] **CA_02:** <criterio verificable 2>
- [ ] **CA_03:** <criterio verificable 3>

## Dependencias

<Qué debe existir antes: otras CAP, versiones del backend, etc.>

**Rama base:** developer
**Rama de trabajo:** feature/CAP-XX-<slug>
