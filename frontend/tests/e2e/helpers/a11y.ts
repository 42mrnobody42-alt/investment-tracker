import { AxeBuilder } from '@axe-core/playwright';
import { expect, type Page, type TestInfo } from '@playwright/test';
import type { AxeResults } from 'axe-core';

/**
 * Tags de axe que exigen WCAG 2.2 AA (criterio del proyecto, ver
 * `agente-frontend.md` §12 y `pruebas.md`).
 */
const DEFAULT_TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

export interface RunA11yOptions {
  /** Sobrescribe los tags por defecto. */
  tags?: string[];
  /** Selectores CSS a excluir del scan (usar solo con justificación documentada). */
  exclude?: string[];
}

/**
 * Ejecuta la auditoría de accesibilidad sobre la página actual con axe-core.
 *
 * - Aplica los tags WCAG 2.2 AA por defecto.
 * - Sin exclusiones por defecto (todo se escanea).
 * - Si hay violaciones: adjunta reporte HTML y JSON al reporte de Playwright
 *   y falla el test con la lista de IDs de reglas violadas.
 *
 * Requiere que el test corra con `prefers-reduced-motion: reduce` emulado
 * (ver `a11y.spec.ts`), según `agente-frontend.md` §12.
 */
export async function runA11y(
  page: Page,
  options: RunA11yOptions = {},
  testInfo?: TestInfo,
): Promise<AxeResults> {
  let builder = new AxeBuilder({ page }).withTags(options.tags ?? DEFAULT_TAGS);

  for (const selector of options.exclude ?? []) {
    builder = builder.exclude(selector);
  }

  const results = await builder.analyze();

  if (results.violations.length > 0 && testInfo) {
    await testInfo.attach('axe-report.html', {
      body: generateHtmlReport(results),
      contentType: 'text/html',
    });
    await testInfo.attach('axe-raw.json', {
      body: JSON.stringify(results, null, 2),
      contentType: 'application/json',
    });
  }

  const violationIds = results.violations.map((v) => v.id);
  expect(violationIds, `Violaciones axe detectadas: ${violationIds.join(', ')}`).toEqual([]);

  return results;
}

/**
 * Genera un reporte HTML autocontenido con las violaciones detectadas.
 */
function generateHtmlReport(results: AxeResults): string {
  const violations = results.violations;

  if (violations.length === 0) {
    return `<!doctype html><html lang="es"><head><meta charset="utf-8"><title>Reporte a11y</title></head><body><h1>Sin violaciones WCAG 2.2 AA</h1><p>Passes: ${results.passes.length} · Incomplete: ${results.incomplete.length}</p></body></html>`;
  }

  const items = violations
    .map(
      (v) => `
      <details>
        <summary>
          <strong>[${v.impact ?? 'n/a'}] ${v.id}</strong> — ${v.help}
          <small>(${v.nodes.length} instancia${v.nodes.length === 1 ? '' : 's'})</small>
        </summary>
        <p>${v.description}</p>
        <p><a href="${v.helpUrl}" target="_blank" rel="noopener">Más información</a></p>
        <ol>
          ${v.nodes
            .map(
              (n) => `
            <li>
              <code>${n.target.join(' ')}</code>
              <pre>${escapeHtml(n.html)}</pre>
              <p>${escapeHtml(n.failureSummary ?? '')}</p>
            </li>`,
            )
            .join('')}
        </ol>
      </details>`,
    )
    .join('');

  return `<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Reporte a11y — ${violations.length} violaciones</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 960px; margin: 0 auto; padding: 24px; }
    details { border: 1px solid #d1d5db; border-radius: 4px; padding: 8px 12px; margin: 8px 0; }
    summary { cursor: pointer; }
    pre { background: #f3f4f6; padding: 8px; overflow-x: auto; }
    code { color: #b91c1c; }
  </style>
</head>
<body>
  <h1>Reporte a11y — ${violations.length} violaciones</h1>
  <p>Tags: ${DEFAULT_TAGS.join(', ')}</p>
  ${items}
</body>
</html>`;
}

function escapeHtml(input: string): string {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
