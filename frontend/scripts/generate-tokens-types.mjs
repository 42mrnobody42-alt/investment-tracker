/**
 * generate-tokens-types.mjs — TS-024 (#629)
 *
 * Lee generated/light.ts (autogenerado por Style Dictionary) y escribe
 * shared/types/tokens.ts con el union de nombres válidos.
 *
 * Se ejecuta en build:tokens después de convert + SD build.
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const FRONTEND = join(__dirname, '..');

const lightTs = readFileSync(join(FRONTEND, 'src/components/imported/generated/light.ts'), 'utf8');

// Extrae los nombres de token: --color-brand-primary, etc.
const names = [...lightTs.matchAll(/'--([a-z0-9-]+)':/g)].map((m) => '--' + m[1]);

const union = names.map((n) => `  | '${n}'`).join('\n');

const out = `// Generado por generate-tokens-types.mjs — NO editar.
// Total: ${names.length} tokens.

export type TokenName =
${union};

export const TOKEN_NAMES: readonly TokenName[] = [
${names.map((n) => `  '${n}',`).join('\n')}
] as const;
`;

writeFileSync(join(FRONTEND, 'src/shared/types/tokens.ts'), out);
console.log(`[tokens-types] ${names.length} tokens → src/shared/types/tokens.ts`);
