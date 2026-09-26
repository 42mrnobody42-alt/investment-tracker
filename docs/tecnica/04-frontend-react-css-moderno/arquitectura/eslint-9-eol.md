# ADR-0001 — Fijar ESLint 9.39.5 por incompatibilidad de plugins con ESLint 10

- **Estado**: Aceptada
- **Fecha**: 2026-09-26
- **Capa**: Frontend (React + TypeScript + Vite)
- **Decisores**: Equipo Investment Tracker
- **Relacionado**: TS-002 (#607), FT-001 (#556), US-001 (#565), CAP-01 (#554)
- **Reemplaza a**: (ninguno)
- **Reemplazado por**: (pendiente cuando el ecosistema soporte ESLint 10)

## Contexto

El 26 de septiembre de 2026, al inicializar el proyecto frontend (TS-001), Vite 8.3.1
instaló **ESLint 10.10.0** como versión por defecto del template `react-ts`.

En TS-002 (#607) intentamos agregar los plugins obligatorios que exige
`docs/prompts/agente-frontend.md` §15:

- `eslint-plugin-jsx-a11y` (WCAG 2.2 AA)
- `eslint-plugin-import` (salud de imports)
- `eslint-config-prettier` (compatibilidad con Prettier)
- `eslint-plugin-simple-import-sort` (orden de imports)

La instalación falló con `ERESOLVE`:

```
Found: eslint@10.10.0
Could not resolve dependency:
peer eslint@"^3 || ^4 || ^5 || ^6 || ^7 || ^8 || ^9" from eslint-plugin-jsx-a11y@6.10.2
peer eslint@"^2 || ^3 || ^4 || ^5 || ^6 || ^7.2.0 || ^8 || ^9" from eslint-plugin-import@2.32.0
```

Ambos plugins **no declaran compatibilidad con ESLint 10** todavía. Es un
problema de ecosistema, no un error de configuración.

## Decisión

**Fijar `eslint` y `@eslint/js` en `9.39.5`** (última 9.x disponible) para el frontend,
sustituyendo la versión 10.10.0 que Vite 8 instaló por defecto.

El resto del stack queda intacto:

| Paquete                             | Versión                      |
| ----------------------------------- | ---------------------------- |
| `eslint`                            | `9.39.5`                     |
| `@eslint/js`                        | `9.39.5`                     |
| `typescript-eslint`                 | `8.69.0` (soporta 8, 9 y 10) |
| `eslint-plugin-react-hooks`         | `7.1.1` (soporta 3–10)       |
| `eslint-plugin-react-refresh`       | `0.5.6` (soporta 9 y 10)     |
| `eslint-plugin-jsx-a11y`            | `6.10.2` (soporta 3–9)       |
| `eslint-plugin-import`              | `2.32.0` (soporta 2–9)       |
| `eslint-plugin-simple-import-sort`  | `14.0.0`                     |
| `eslint-config-prettier`            | `10.1.8`                     |
| `eslint-import-resolver-typescript` | `4.4.5`                      |

## Justificación

1. **Todos los plugins obligatorios funcionan** con ESLint 9 sin flags especiales
   (`--legacy-peer-deps`, `--force`).
2. **ESLint es un dev tool** — no corre en producción, no procesa input externo,
   no hay superficie de ataque.
3. **La versión EOL tiene bajo impacto operativo** en este contexto: solo afecta
   al pipeline de lint, no al bundle final ni a los usuarios.
4. **Evita `--legacy-peer-deps`**, que oculta incompatibilidades reales y puede
   producir fallos sutiles en runtime del propio ESLint.
5. **Es una decisión reversible** con un solo PR cuando el ecosistema madure.

## Consecuencias

### Positivas

- Todos los plugins obligatorios funcionan sin flags de escape.
- Un solo comando `npm install` limpio.
- No hay deuda de `--legacy-peer-deps` acumulada.

### Negativas

- ESLint 9.39.5 está **EOL** (fin de soporte oficial). No recibe parches de
  seguridad ni nuevas reglas.
- Cada `npm install` emite el warning:
  ```
  npm warn deprecated eslint@9.39.5: This version is no longer supported.
  ```
- Los mantenedores del proyecto deben recordar hacer el upgrade cuando el
  ecosistema madure.

### Neutrales

- La API pública de ESLint entre 9 y 10 es compatible en el 95% de los casos.
  El código del proyecto no debería verse afectado por el upgrade futuro.
- `eslint.config.js` (flat config) es el mismo formato en 9 y 10.

## Alternativas consideradas

### A. Quedarnos en ESLint 10 + `--legacy-peer-deps`

Rechazada. Los peers de `jsx-a11y` e `import` no llegan a ESLint 10, y forzar
la instalación puede provocar fallos sutiles en el pipeline.

### B. Quedarnos en ESLint 10 + usar forks modernos

Rechazada. `eslint-plugin-import-x` es un fork válido de `eslint-plugin-import`,
pero **no existe fork conocido de `eslint-plugin-jsx-a11y`** que soporte ESLint 10.
Sin a11y estático no cumplimos WCAG 2.2 AA del `agente-frontend.md` §12.

### C. Quedarnos en ESLint 10 + diferir a11y

Rechazada. Aplaza el cumplimiento de accesibilidad sin fecha y rompe la DoD
de TS-002.

### D. `--force` en ambos installs

Rechazada. `--force` es más agresivo que `--legacy-peer-deps` e ignora
incluso conflictos de versión mayor.

## Cuándo revisar esta decisión

**Gatillos de revisión** (cualquiera dispara la revisión):

1. `eslint-plugin-jsx-a11y` publica una versión con `peerDependencies: ^10`.
2. `eslint-plugin-import` publica una versión con `peerDependencies: ^10`.
3. Se detecta una vulnerabilidad de seguridad en ESLint 9.x con impacto real.
4. Han pasado **12 meses** desde esta decisión (2027-09-26) sin que se cumplan (1) o (2).

**Verificación**:

```bash
cd /prog/datos/investment-tracker/frontend
npm view eslint-plugin-jsx-a11y peerDependencies
npm view eslint-plugin-import peerDependencies
```

Si ambos listan `^10`, se puede hacer el upgrade en un solo PR:

```bash
cd /prog/datos/investment-tracker/frontend
npm install -D --save-exact eslint@latest @eslint/js@latest
npm run lint
npm run build
```

## Referencias

- [ESLint 10.0.0 release notes](https://eslint.org/blog/)
- [eslint-plugin-jsx-a11y — peerDependencies](https://www.npmjs.com/package/eslint-plugin-jsx-a11y)
- [eslint-plugin-import — peerDependencies](https://www.npmjs.com/package/eslint-plugin-import)
- `docs/prompts/agente-frontend.md` §15 — Stack obligatorio de linting
- `README.md` §104 — Stack tecnológico del proyecto
