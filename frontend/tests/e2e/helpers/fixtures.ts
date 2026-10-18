import { expect, test as base } from '@playwright/test';

import { gotoHome } from './navigation';

/**
 * Fixtures compartidas para los tests E2E.
 *
 * Uso:
 *   import { test, expect } from './helpers/fixtures';
 *   test('...', async ({ page, homeReady }) => { ... });
 */
export const test = base.extend<{
  /** Navega a la home y espera a que la app esté lista. */
  homeReady: () => Promise<void>;
}>({
  homeReady: async ({ page }, use) => {
    // El parámetro `use` es el callback de extensión de fixtures de Playwright,
    // no el hook `use` de React 19. Falso positivo de react-hooks en E2E.
    // eslint-disable-next-line react-hooks/rules-of-hooks
    await use(async () => {
      await gotoHome(page);
    });
  },
});

export { expect };
