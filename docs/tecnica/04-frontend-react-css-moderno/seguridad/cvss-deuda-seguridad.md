# CVSS — Deuda de Seguridad del Frontend

> **Log continuo** de vulnerabilidades de seguridad aceptadas en el frontend.
> Política de aceptación y proceso completo en el ADR-0004:
> [`docs/tecnica/04-frontend-react-css-moderno/deuda-tecnica/vulnerabilidades-policy.md`](../deuda-tecnica/vulnerabilidades-policy.md).
> Detalle técnico de la deuda: [ADR-0004](../deuda-tecnica/vulnerabilidades-policy.md).

## Propósito

Registrar y hacer seguimiento de las vulnerabilidades de seguridad **aceptadas
conscientemente** en el frontend, con su clasificación CVSS real, el análisis
de explotabilidad en este proyecto y los gatillos de revisión.

## Regla inviolable

**NO ejecutar** `npm audit fix --force` ni `npm audit fix --legacy-peer-deps`
mientras exista una entrada activa en este documento.

**Motivo**: el fix sugerido por npm suele ser un downgrade mayor del paquete
afectado (por ejemplo, `stylelint@17.15.0` → `stylelint@7.7.0`), que rompe toda
la configuración del proyecto. Cualquier fix debe pasar por evaluación manual
y por una nueva entrada en este archivo.

## Proceso

1. Ejecutar `npm audit` tras cada cambio de dependencias.
2. Para cada vulnerabilidad nueva:
   - Investigar la cadena completa con `npm ls <paquete>`.
   - Determinar si afecta a producción (vs. solo dev).
   - Buscar fix disponible (`npm view <paquete> version`).
   - Si no hay fix, o si el fix rompe el stack → registrar aquí como **Aceptada**.
   - Si hay fix limpio → aplicar el fix y documentar como **Resuelta**.
3. Re-revisar cuando se cumpla el gatillo de cada entrada.
4. Nunca usar `--force` ni `--legacy-peer-deps` para "resolver" el reporte.

## Estados

- 🟡 **Aceptada** — Documentada, sin fix disponible o fix rompe stack.
- 🟢 **Resuelta** — Fix aplicado, entrada archivada.
- 🔴 **Bloqueante** — Afecta a producción; debe resolverse antes del merge.

---

## Activas

### VULN-001 — `braces` CWE-674 (DoS por stack exhaustion)

| Campo           | Valor                                                                    |
| --------------- | ------------------------------------------------------------------------ |
| **ID**          | VULN-001                                                                 |
| **Paquete**     | `braces@3.0.3`                                                           |
| **Severidad**   | High                                                                     |
| **CWE**         | CWE-674 (Uncontrolled Recursion / Stack Exhaustion)                      |
| **Advisory**    | [GHSA-vfj7-8cjw-p6xm](https://github.com/advisories/GHSA-vfj7-8cjw-p6xm) |
| **Cadena**      | `stylelint@17.15.0` → `micromatch@4.0.8` → `braces@3.0.3`                |
| **Tipo**        | Dev dependency — nunca llega a producción                                |
| **Estado**      | 🟡 Aceptada                                                              |
| **Aceptada el** | 2026-10-03                                                               |
| **Decisión**    | [ADR-0004](../deuda-tecnica/vulnerabilidades-policy.md)                   |

#### Clasificación real

| Aspecto                                | Valor                                                                     |
| -------------------------------------- | ------------------------------------------------------------------------- |
| ¿Afecta a producción?                  | ❌ No — Stylelint es `devDependency`, corre en build-time                 |
| ¿Afecta al bundle?                     | ❌ No — nunca llega a `dist/`                                             |
| ¿Es explotable?                        | ⚠️ Solo si un atacante controla los patrones `glob` procesados localmente |
| ¿El riesgo es real para este proyecto? | ❌ Bajo — Stylelint procesa solo archivos locales controlados             |
| Tipo de vulnerabilidad                 | CWE-674 (stack-exhaustion DoS) — bajo impacto real                        |
| CVSS                                   | 7.5 (high) — vector `AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H`                 |
| Impacto                                | Solo **DoS** (Denial of Service). Sin confidencialidad, sin integridad    |
| Alcance                                | Ninguno fuera del proceso local de linting                                |

#### Justificación de aceptación

- `braces@3.0.3` es la **última versión publicada**. No existe fix disponible en el ecosistema.
- El fix sugerido por npm (`stylelint@7.7.0`) es un downgrade mayor que rompe `stylelint-config-standard@40`, `stylelint-config-css-modules@4.6` y `stylelint-config-recess-order@7.8`.
- El vector real de ataque requiere que un atacante controle los patrones `glob` que Stylelint procesa. En este proyecto, los patrones son **estáticos** (`src/**/*.css`).
- No hay exposición: Stylelint no corre en runtime, no está expuesto a red, y no procesa input externo.

#### Cuándo se espera solución / cuándo validar

**Gatillos de revisión** (cualquiera reactiva la evaluación):

1. Publicación de `braces@>3.0.3` en npm.
2. Publicación de `micromatch@>4.0.8` con actualización de `braces`.
3. Publicación de `stylelint@>17.15.0` con actualización de sus transitivas.
4. **12 meses** desde la aceptación (2027-10-03) sin que se cumplan (1)-(3).

**Comando de verificación**:

```bash
cd /prog/datos/investment-tracker/frontend

# 1. ¿Hay fix nuevo?
npm view braces version
# Si > 3.0.3 → aplicar fix y marcar VULN-001 como Resuelta.

# 2. ¿Sigue reportando?
npm audit
# Si dice "found 0 vulnerabilities" → marcar VULN-001 como Resuelta.

# 3. ¿Actualizaron Stylelint?
npm view stylelint version
# Si > 17.15.0 → evaluar actualización (ver ADR-0004).
```

#### Vulnerabilidades asociadas

**Total de vulnerabilidades high asociadas**: 11 (todas derivadas de la misma cadena).
Todas comparten el mismo origen y la misma aceptación.

Listado (por cadena de dependencias):

- `braces@3.0.3` (raíz)
- `micromatch@4.0.8` (hereda)
- `fast-glob@3.3.3` (hereda)
- `globby@16.2.4` (hereda)
- `stylelint@17.15.0` (hereda)
- +6 más derivadas de los configs de Stylelint

---

## Resueltas

_(vacío)_
