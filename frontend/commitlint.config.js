// ============================================================================
// commitlint.config.js — Validación del formato de commit
// ============================================================================
// Formato del proyecto: tipo(#N): descripción
//   - tipo: feat|fix|docs|refactor|test|chore|style|perf|build|ci|revert
//   - (#N): opcional (obligatorio solo si el commit resuelve un issue)
//   - !: opcional (breaking change)
//   - descripción: no vacía
//
// Ejemplos válidos:
//   feat(#620): agregar runner unificado
//   fix(#123)!: romper compatibilidad de la API pública
//   chore: bumpear dependencias
//   docs(#42): documentar el flujo
//
// Ejemplos inválidos:
//   update stuff                     → sin tipo
//   feature(#1): agregar             → tipo "feature" no permitido (usar "feat")
//   feat(): agregar                  → scope vacío
//
// Los merge commits de GitHub ("Merge pull request #N from...") se ignoran
// automáticamente por `defaultIgnores: true`.
// ============================================================================

export default {
  extends: ['@commitlint/config-conventional'],
  defaultIgnores: true,

  parserPreset: {
    parserOpts: {
      headerPattern: /^(\w+)(?:\((#[0-9]+)\))?!?: (.+)$/,
      headerCorrespondence: ['type', 'issue', 'subject'],
      breakingHeaderPattern: /^(\w+)(?:\((#[0-9]+)\))?!: (.+)$/,
    },
  },

  rules: {
    'type-enum': [
      2,
      'always',
      [
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
      ],
    ],
    'type-empty': [2, 'never'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
    'body-leading-blank': [2, 'always'],
    'footer-leading-blank': [2, 'always'],
  },
};
