## Informe gerencial

<Impacto de esta FT sobre la Capability CA-XX. 2-4 líneas: qué aporta al
negocio, a qué CAP pertenece, cuál es el resultado observable al terminar.>

- **Capability**: CAP-XX — <título de la CA>
- **Impacto**: <qué habilita esta FT para la CA y para las FTs hermanas>
- **Resultado observable**: <qué puede hacer el usuario/equipo al terminar>

## Contexto

<Por qué esta feature. 1-2 líneas.>

## Alcance

- <Módulo / área funcional>
- <US/TS que agrupa>
- <Fuera del scope explícito si aplica>

## User Stories

Cada US debe indicar su **aporte dentro de la FT** (cómo contribuye al
objetivo global de la feature). No basta con el título.

- **US-XXX — <título>**: <cómo aporta dentro de la FT (1-2 líneas)>
- **US-YYY — <título>**: <cómo aporta dentro de la FT (1-2 líneas)>

## Criterios de aceptación (release)

Los CAs de una FT son **de cierre/release**, no de implementación. La
implementación se valida en cada US/TS hija (con su propio validador
`validate-tsNNN.sh`). La FT valida que el conjunto se libera correctamente
a `lastest`.

- [ ] **CA_01:** Merge `developer → lastest` ejecutado vía PR sin conflictos.
  `origin/lastest` contiene el commit de merge. Usar
  `.pasarCambiosALastest.sh` o el flujo equivalente.
- [ ] **CA_02:** Versión incrementada (`Version` / `Release` / `Hotfix`)
  según lo indique el desarrollador en el PR de release. Solo se toca
  lo que corresponda (hotfix para bugfix, release para features, version
  para cambio mayor).
- [ ] **CA_03:** Bump aplicado en los docs versionados que correspondan:
  `README.md` (header del proyecto) + `prompt_inicial.md` + `agente-frontend.md`
  (cada uno tiene su esquema propio; ver docs).
- [ ] **CA_04:** US hijas cerradas (`gh issue view <N>` = `closed` +
  Kanban `Done`).
- [ ] **CA_05:** FT cerrada: `kanban-move.sh <N> done` + `gh issue close <N>`.
  Trazabilidad final del release.

## Dependencias

- <US / FT previas que deben estar cerradas>
- <Notas de bloqueo / prerequisites si aplica>
