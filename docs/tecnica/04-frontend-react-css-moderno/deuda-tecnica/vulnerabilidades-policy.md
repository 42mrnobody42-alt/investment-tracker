# ADR-0004 — Política de vulnerabilidades aceptadas en el frontend

- **Estado**: 🟡 Pendiente
- **Fecha**: 2026-10-03
- **Capa**: Frontend (dev tooling / supply chain)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: TS-008 (#613), US-003 (#567), FT-001 (#556)
- **Reemplaza a**: (ninguno)
- **Reemplazado por**: (pendiente cuando `braces` reciba fix)

## Contexto

Durante TS-008, al instalar Storybook, `npm install` re-resolvió el árbol de
dependencias y `npm audit` reportó **11 vulnerabilidades high** en transitivas
de **Stylelint** (instalado en TS-003):

```
braces@3.0.3
  └── micromatch@4.0.8
        └── fast-glob@3.3.3
              └── globby@16.2.4
                    └── stylelint@17.15.0
                          ├── stylelint-config-standard@40.0.0
                          ├── stylelint-config-css-modules@4.6.0
                          ├── stylelint-config-recess-order@7.8.0
                          └── stylelint-order@8.1.1
```

El fix sugerido por `npm audit fix --force` era **downgrade de `stylelint@17.15.0`
a `stylelint@7.7.0`** — inaceptable, porque rompe toda la configuración de TS-003
(`stylelint-config-standard@40` requiere `stylelint >= 16`).

Investigación: `braces@3.0.3` es la **última versión publicada** en npm.
No existe fix disponible en el ecosistema.

## Decisión

Adoptar una **política formal de aceptación** de vulnerabilidades en el frontend:

1. **Registrar** cada vulnerabilidad aceptada en
   [`docs/tecnica/04-frontend-react-css-moderno/seguridad/cvss-deuda-seguridad.md`](../seguridad/cvss-deuda-seguridad.md).
2. **Prohibir** `npm audit fix --force` y `npm audit fix --legacy-peer-deps` como
   mecanismos de resolución automática. Todo fix debe pasar por evaluación manual.
3. **Clasificar** cada vulnerabilidad según su impacto real:
   - Afecta producción → bloqueante (no se acepta).
   - Solo dev + sin fix → aceptar y documentar (estado 🟡).
   - Solo dev + con fix limpio → aplicar y documentar (estado 🟢).
4. **Gatillar** la revisión de cada vulnerabilidad aceptada con eventos concretos
   (publicación de fix, actualización del paquete padre, o paso del tiempo).

## Justificación

- **No afecta producción**: `stylelint` es `devDependency`; nunca llega a `dist/`.
  El bundle de producción no contiene este código.
- **Vector limitado**: la vulnerabilidad (CWE-674) solo se activa si un atacante
  controla los patrones `glob` procesados. En este proyecto, los patrones son
  **estáticos** (`src/**/*.css`), definidos en `package.json`.
- **No hay fix**: `braces@3.0.3` es la última publicada. Un `override` en
  `package.json` no puede apuntar a una versión inexistente.
- **El downgrade sugerido rompe el stack**: `stylelint@7.7.0` es de 2020 y es
  incompatible con todos los configs actuales.
- **Visibilidad**: la alternativa de "ignorar el reporte" produce deuda silenciosa.
  Documentar formalmente hace la deuda trazable y auditable.

## Consecuencias

### Positivas

- Proyecto sigue funcionando con Stylelint 17 (tooling moderno).
- Proceso claro y repetible para futuras vulnerabilidades.
- Deuda de seguridad visible y trazable.
- Onboarding más rápido: cualquier dev nuevo entiende por qué `npm audit` no se ejecuta con `--force`.

### Negativas

- `npm audit` seguirá reportando 11 high en cada ejecución hasta que el ecosistema publique un fix.
- Requiere revisión periódica manual (los gatillos están definidos).
- Riesgo residual aceptado (aunque bajo) — no es cero.

### Neutrales

- Sin cambios en el bundle de producción.
- Sin cambios en el comportamiento de la aplicación.
- Sin cambios en el rendimiento.

## Regla operativa

**Nunca ejecutar**:

```bash
npm audit fix --force               # ❌ Puede hacer downgrade mayor
npm audit fix --legacy-peer-deps    # ❌ Ignora incompatibilidades reales
```

**En su lugar**:

```bash
npm audit                           # Ver el reporte
npm ls <paquete>                    # Investigar la cadena
npm view <paquete> version          # Ver si hay fix disponible
```

Y si hay fix → evaluar manualmente + aplicar + actualizar
`cvss-deuda-seguridad.md`.

## Gatillos de revisión

Cualquiera reactiva la evaluación:

1. Publicación de `braces@>3.0.3`.
2. Publicación de `micromatch@>4.0.8` con actualización de `braces`.
3. `stylelint` publica una versión con transitivas actualizadas.
4. **12 meses** desde esta decisión (2027-10-03).

## Referencias

- `docs/tecnica/04-frontend-react-css-moderno/seguridad/cvss-deuda-seguridad.md` — log de vulnerabilidades aceptadas.
- ADR-0001 (`eslint-9-eol.md`) — patrón de documentación de deuda técnica en el proyecto.
- ADR-0002 (`stylelint-scope-y-colores.md`) — patrón de gatillos de revisión.
- [GHSA-vfj7-8cjw-p6xm](https://github.com/advisories/GHSA-vfj7-8cjw-p6xm) — advisory de `braces`.
