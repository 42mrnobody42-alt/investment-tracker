import { expect, test } from './helpers/fixtures';
import { gotoHome } from './helpers/navigation';

test.describe('Smoke tests', () => {
  test('frontend home responde 200 y renderiza', async ({ page }) => {
    await gotoHome(page);
    await expect(page.locator('body')).toBeVisible();
    await expect(page).toHaveTitle(/.+/);
  });

  test('health endpoint (mock) — TODO: reemplazar por llamada real en TS-122 (#727)', async ({
    page,
  }) => {
    // TODO: TS-122 (#727) reemplazará este mock por una llamada real al backend.
    // Ver body de #727: criterio de aceptación "Actualizar el smoke test E2E de TS-013".
    // A medida que avance la construcción, se irán añadiendo los smoke tests de los
    // demás endpoints publicados (README §"Tabla de Endpoints publicados").
    await page.route('**/api/test/health', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ status: 'UP', timestamp: new Date().toISOString() }),
      });
    });

    await gotoHome(page);

    const result = await page.evaluate(async () => {
      const res = await fetch('/api/test/health');
      return { status: res.status, data: (await res.json()) as { status: string } };
    });

    expect(result.status).toBe(200);
    expect(result.data.status).toBe('UP');
  });
});
