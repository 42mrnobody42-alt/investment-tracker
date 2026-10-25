import { defineConfig } from '@playwright/test';
import process from 'node:process';

const STORYBOOK_PORT = process.env.STORYBOOK_PORT || '3010';

export default defineConfig({
  testDir: './tests/e2e',
  testMatch: /storybook-manager\.spec\.ts/,
  fullyParallel: false,
  workers: 1,
  reporter: 'list',
  use: {
    baseURL: `http://localhost:${STORYBOOK_PORT}`,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'desktop', use: { browserName: 'chromium' } }],
  webServer: {
    command: 'npm run storybook',
    url: `http://localhost:${STORYBOOK_PORT}`,
    reuseExistingServer: !process.env.CI,
    timeout: 180_000,
    stdout: 'ignore',
    stderr: 'pipe',
  },
});
