import type { Page } from '@playwright/test';

/**
 * Navegación a la home y espera de que la SPA esté lista.
 *
 * Fallará si la home no responde 200, garantizando que el smoke test
 * no pase silenciosamente por un error de servidor.
 */
export async function gotoHome(page: Page): Promise<void> {
  const response = await page.goto('/');
  if (!response || response.status() !== 200) {
    throw new Error(`Home page returned status ${response?.status() ?? 'unknown'}`);
  }
  await page.waitForLoadState('networkidle');
}
