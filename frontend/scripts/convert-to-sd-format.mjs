/**
 * convert-to-sd-format.mjs — TS-023 (#628)
 *
 * Convierte archivos DTCG ($value/$type) al formato legacy (value/type)
 * que Style Dictionary v5 soporta al 100%.
 *
 * Fuente:  src/components/imported/**\/*.tokens.json
 * Destino: .tokens-sd-build/**\/*.json
 *
 * El destino se limpia al final del build (ver package.json).
 */

import { readFileSync, writeFileSync, mkdirSync, rmSync, readdirSync, statSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const FRONTEND = join(__dirname, '..');
const SRC = join(FRONTEND, 'src/components/imported');
const DEST = join(FRONTEND, '.tokens-sd-build');

function walk(dir) {
  const out = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    const st = statSync(full);
    if (st.isDirectory()) out.push(...walk(full));
    else if (entry.endsWith('.tokens.json')) out.push(full);
  }
  return out;
}

function convert(node) {
  if (Array.isArray(node)) return node.map(convert);
  if (node === null || typeof node !== 'object') return node;
  const out = {};
  for (const [key, val] of Object.entries(node)) {
    let k = key;
    if (key === '$value') k = 'value';
    else if (key === '$type') k = 'type';
    else if (key === '$description') k = 'description';
    else if (key === '$extensions') k = 'extensions';
    out[k] = convert(val);
  }
  return out;
}

// Limpiar destino
rmSync(DEST, { recursive: true, force: true });
mkdirSync(DEST, { recursive: true });

const files = walk(SRC);
let count = 0;

for (const file of files) {
  const rel = relative(SRC, file);
  const destFile = join(DEST, rel);
  mkdirSync(dirname(destFile), { recursive: true });
  const content = JSON.parse(readFileSync(file, 'utf8'));
  const converted = convert(content);
  writeFileSync(destFile, JSON.stringify(converted, null, 2) + '\n');
  count++;
  console.log(`  convert: ${rel}`);
}

console.log(`[convert] ${count} archivos convertidos → .tokens-sd-build/`);
