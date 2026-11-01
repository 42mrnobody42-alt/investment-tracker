import { expect, test } from '@playwright/test';
import process from 'node:process';

const STORYBOOK_URL = `http://localhost:${process.env.STORYBOOK_PORT || '3010'}`;

const KNOWN_WARNING_PATTERNS = [
  /The 'ariaLabel' prop on 'PopoverProvider' will become mandatory/,
  /Download the React DevTools/,
  /\[vite\] connect/,
  /\[vite\] hot updated/,
  /Storybook connects to/,
];

interface StoryEntry {
  id: string;
  title: string;
  name: string;
  type: string;
}

/**
 * Storybook 10 envuelve las entradas en `{ v: 5, entries: { ... } }` (o `{ v3: { entries } }`).
 * Versiones anteriores usaban un mapa plano `{ "story-id": {...} }`.
 * Esta función soporta ambos formatos.
 */
function extractEntries(raw: unknown): Record<string, StoryEntry> {
  if (!raw || typeof raw !== 'object') return {};
  const obj = raw as Record<string, unknown>;
  if (obj.entries && typeof obj.entries === 'object') {
    return obj.entries as Record<string, StoryEntry>;
  }
  if (obj.v3 && typeof obj.v3 === 'object') {
    const v3 = obj.v3 as Record<string, unknown>;
    if (v3.entries && typeof v3.entries === 'object') {
      return v3.entries as Record<string, StoryEntry>;
    }
  }
  return obj as Record<string, StoryEntry>;
}

test.describe('Storybook manager', () => {
  test('no emite warnings nuevos en la inicialización', async ({ page }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'Solo corre en desktop');

    const consoleMessages: { type: string; text: string }[] = [];
    page.on('console', (msg) => {
      const t = msg.type();
      if (t === 'warning' || t === 'error') {
        consoleMessages.push({ type: t, text: msg.text() });
      }
    });

    await page.goto(STORYBOOK_URL, { waitUntil: 'networkidle', timeout: 30000 });
    await page.waitForTimeout(3000);

    await testInfo.attach('console-messages.json', {
      body: JSON.stringify(consoleMessages, null, 2),
      contentType: 'application/json',
    });

    const relevant = consoleMessages.filter((m) => {
      if (m.type === 'error') return true;
      return !KNOWN_WARNING_PATTERNS.some((p) => p.test(m.text));
    });

    expect(
      relevant,
      `Mensajes no documentados en manager:\n${relevant.map((m) => `[${m.type}] ${m.text}`).join('\n')}`,
    ).toEqual([]);
  });

  test('todas las stories renderizan sin error overlay', async ({ page, request }, testInfo) => {
    test.skip(testInfo.project.name !== 'desktop', 'Solo corre en desktop');

    const indexRes = await request.get(`${STORYBOOK_URL}/index.json`, { timeout: 10000 });
    expect(indexRes.ok(), 'index.json debe responder').toBeTruthy();
    const raw = await indexRes.json();

    await testInfo.attach('index-json-raw.json', {
      body: JSON.stringify(raw, null, 2),
      contentType: 'application/json',
    });

    const entries = extractEntries(raw);
    const stories = Object.values(entries).filter((s) => s?.type === 'story');

    expect(
      stories.length,
      `No se encontraron stories en index.json. Formato detectado: ${Object.keys(raw ?? {}).join(', ')}`,
    ).toBeGreaterThan(0);

    const failures: string[] = [];
    for (const story of stories) {
      const label = `${story.title} / ${story.name}`;
      try {
        const r = await page.goto(`${STORYBOOK_URL}/iframe.html?id=${story.id}&viewMode=story`, {
          waitUntil: 'domcontentloaded',
          timeout: 20000,
        });
        if (!r?.ok()) {
          failures.push(`${label}: HTTP ${r?.status() ?? 'sin respuesta'}`);
          continue;
        }
        await page.waitForTimeout(300);
        const errorOverlays = await page
          .locator('.sb-show-errordisplay, [data-testid="storybook-error"]')
          .count();
        if (errorOverlays > 0) {
          const msg = await page
            .locator('.sb-show-errordisplay')
            .textContent()
            .catch(() => null);
          failures.push(`${label}: error overlay${msg ? ` — ${msg.slice(0, 200)}` : ''}`);
        }
      } catch (e) {
        failures.push(`${label}: ${e instanceof Error ? e.message : String(e)}`);
      }
    }

    if (failures.length > 0) {
      await testInfo.attach('story-failures.txt', {
        body: failures.join('\n'),
        contentType: 'text/plain',
      });
    }

    expect(failures, `Stories con problemas:\n${failures.join('\n')}`).toEqual([]);
  });
});
