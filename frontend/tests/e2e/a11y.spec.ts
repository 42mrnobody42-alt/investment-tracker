import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { runA11y } from './helpers/a11y';
import { expect, test } from './helpers/fixtures';

const __dirname = dirname(fileURLToPath(import.meta.url));
const mockHtml = readFileSync(resolve(__dirname, 'fixtures/mock-view.html'), 'utf-8');

test.describe('A11y base — WCAG 2.2 AA', () => {
  test('mock-view pasa la auditoría de axe', async ({ page }, testInfo) => {
    // WCAG 2.3.3 — Animation from Interactions: la UI debe ser usable con
    // animaciones desactivadas.
    await page.emulateMedia({ reducedMotion: 'reduce' });
    await page.setContent(mockHtml);

    await expect(page).toHaveTitle(/Mock View/);
    await runA11y(page, {}, testInfo);
  });
});
