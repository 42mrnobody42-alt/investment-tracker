import { defineConfig, devices } from '@playwright/test';

const FRONTEND_PORT = process.env.FRONTEND_PORT || '3000';

/**
 * Playwright configuration — Investment Tracker Pro
 *
 * 7 proyectos E2E alineados con los dispositivos objetivo (2026):
 *   - mobile-chrome:   Infinix GT 30 Pro (393×873, dpr 2.75, touch, Chromium)
 *   - mobile-android:  Xiaomi Redmi Note 14 (393×873, dpr 2.75, touch, Chromium)
 *   - mobile-safari:   iPhone 14 Pro (393×852, dpr 3, touch, WebKit)
 *   - tablet:          768×1024, dpr 2, touch (Chromium)
 *   - desktop:         1920×1080, dpr 1 (Chromium)
 *   - tv-fhd:          1920×1080, dpr 1 (Chromium)
 *   - tv-4k:           3840×2160, dpr 2 (Chromium)
 *
 * Traces: on-first-retry. Screenshots: only-on-failure.
 * WebServer: Vite dev en puerto 3000 (reuseExistingServer fuera de CI).
 */
export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html', { outputFolder: 'playwright-report', open: 'never' }], ['list']],
  use: {
    baseURL: `http://localhost:${FRONTEND_PORT}`,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10_000,
    navigationTimeout: 15_000,
  },
  projects: [
    {
      name: 'mobile-chrome',
      use: {
        defaultBrowserType: 'chromium',
        viewport: { width: 393, height: 873 },
        deviceScaleFactor: 2.75,
        isMobile: true,
        hasTouch: true,
        userAgent:
          'Mozilla/5.0 (Linux; Android 14; Infinix GT 30 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',
      },
    },
    {
      name: 'mobile-android',
      use: {
        defaultBrowserType: 'chromium',
        viewport: { width: 393, height: 873 },
        deviceScaleFactor: 2.75,
        isMobile: true,
        hasTouch: true,
        userAgent:
          'Mozilla/5.0 (Linux; Android 14; Redmi Note 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',
      },
    },
    {
      name: 'mobile-safari',
      use: {
        ...devices['iPhone 14 Pro'],
      },
    },
    {
      name: 'tablet',
      use: {
        defaultBrowserType: 'chromium',
        viewport: { width: 768, height: 1024 },
        deviceScaleFactor: 2,
        hasTouch: true,
        isMobile: false,
      },
    },
    {
      name: 'desktop',
      use: {
        defaultBrowserType: 'chromium',
        viewport: { width: 1920, height: 1080 },
        deviceScaleFactor: 1,
        hasTouch: false,
        isMobile: false,
      },
    },
    {
      name: 'tv-fhd',
      use: {
        defaultBrowserType: 'chromium',
        viewport: { width: 1920, height: 1080 },
        deviceScaleFactor: 1,
        hasTouch: false,
        isMobile: false,
      },
    },
    {
      name: 'tv-4k',
      use: {
        defaultBrowserType: 'chromium',
        viewport: { width: 3840, height: 2160 },
        deviceScaleFactor: 2,
        hasTouch: false,
        isMobile: false,
      },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: `http://localhost:${FRONTEND_PORT}`,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
    stdout: 'ignore',
    stderr: 'pipe',
  },
});
