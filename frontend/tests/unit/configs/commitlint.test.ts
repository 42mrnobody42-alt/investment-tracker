import { describe, expect, it } from 'vitest';

import commitlintConfig from '../../../commitlint.config.js';

const headerPattern = commitlintConfig.parserPreset.parserOpts.headerPattern;
const validTypes = commitlintConfig.rules['type-enum'][2];

describe('commitlint — headerPattern (estructura)', () => {
  describe('acepta', () => {
    it.each([
      'feat(#620): agregar runner unificado',
      'fix(#123): corregir error',
      'docs(#42): documentar flujo',
      'refactor(#7): reorganizar módulos',
      'test(#8): añadir tests',
      'chore: bumpear dependencias',
      'style: aplicar prettier',
      'perf(#99): optimizar render',
      'build(#10): actualizar vite',
      'ci(#11): mejorar workflow',
      'revert(#12): deshacer cambio',
      'feat!: romper compatibilidad',
      'feat(#620)!: romper compatibilidad con issue',
      'fix!: urgente',
    ])('%s', (msg) => {
      expect(headerPattern.test(msg)).toBe(true);
    });
  });

  describe('rechaza (estructura inválida)', () => {
    it.each([
      'update stuff',
      'feat',
      'feat(): descripción',
      'feat(#): descripción',
      'feat(#abc): descripción',
      'feat(#1):',
      'feat(#1): ',
      'feat(#1):descripción',
    ])('%s', (msg) => {
      expect(headerPattern.test(msg)).toBe(false);
    });
  });
});

describe('commitlint — type-enum', () => {
  it('contiene exactamente los tipos permitidos', () => {
    expect(validTypes).toEqual([
      'feat',
      'fix',
      'docs',
      'refactor',
      'test',
      'chore',
      'style',
      'perf',
      'build',
      'ci',
      'revert',
    ]);
  });

  it('"feature" NO está en type-enum (usar "feat")', () => {
    expect(validTypes).not.toContain('feature');
  });

  it('"hotfix" NO está en type-enum', () => {
    expect(validTypes).not.toContain('hotfix');
  });
});

describe('commitlint — defaultIgnores', () => {
  it('defaultIgnores está habilitado (merge commits)', () => {
    expect(commitlintConfig.defaultIgnores).toBe(true);
  });
});
