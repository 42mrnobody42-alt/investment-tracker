/**
 * Setup global de Vitest.
 *
 * Carga `@testing-library/jest-dom` (matchers como `toBeInTheDocument`,
 * `toHaveClass`, etc.), limpia el DOM entre tests y mockea APIs de
 * navegador que jsdom no implementa por defecto.
 */
import { cleanup } from '@testing-library/react';
import { afterEach, vi } from 'vitest';

import '@testing-library/jest-dom/vitest';

// Limpieza entre tests: desmonta árboles de React renderizados
afterEach(() => {
  cleanup();
});

// ===== Mocks de APIs de navegador no implementadas por jsdom =====

// matchMedia — usado por hooks de responsive / motion
if (!window.matchMedia) {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  });
}

// ResizeObserver — usado por container queries y observers
globalThis.ResizeObserver = class ResizeObserver {
  observe = vi.fn();
  unobserve = vi.fn();
  disconnect = vi.fn();
};

// IntersectionObserver — usado por lazy loading / reveal-on-scroll
globalThis.IntersectionObserver = class IntersectionObserver {
  root = null;
  rootMargin = '';
  thresholds = [];
  observe = vi.fn();
  unobserve = vi.fn();
  disconnect = vi.fn();
  takeRecords = vi.fn(() => []);
} as unknown as typeof IntersectionObserver;

// scrollTo — usado por navegación / smooth scroll
window.scrollTo = vi.fn();
