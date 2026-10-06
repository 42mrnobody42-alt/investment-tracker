import '../src/styles/branding/paleta-colores-corporativa.css';

import type { Decorator, Preview } from '@storybook/react-vite';

// ============================================================================
// Decoradores globales
// ============================================================================
//
// Decoradores activos (TS-009):
//   - withPadding:      padding uniforme para que el componente no toque bordes.
//   - withBackground:   fondo claro/oscuro segun el parametro `backgrounds`.
//   - withViewport:     ancho fijo segun el parametro `viewport`.
//
// Decoradores pendientes (registrados como ADRs en `deuda-tecnica/`):
//   - withTheme:   requiere `ThemeProvider` (TS-024 #629, ADR-0005).
//   - withI18n:    requiere `I18nextProvider` (TS-026 #631, ADR-0006).
//   - withRouter:  requiere React Router (TS-070 #675, ADR-0007).
//
// Al resolver cada ADR, agregar el decorador aqui y eliminar el ADR.

const withPadding: Decorator = (Story) => (
  <div style={{ padding: '24px' }}>
    <Story />
  </div>
);

const withBackground: Decorator = (Story, context) => {
  const dark = context.parameters.backgrounds?.default === 'dark';
  return (
    <div
      data-theme={dark ? 'dark' : 'light'}
      style={{
        padding: '24px',
        background: dark ? '#1a1a1a' : '#ffffff',
        minHeight: '100px',
      }}
    >
      <Story />
    </div>
  );
};

const withViewport: Decorator = (Story, context) => {
  const width = context.parameters.viewportWidth as number | undefined;
  if (!width) return <Story />;
  return (
    <div style={{ width: `${width}px`, margin: '0 auto' }}>
      <Story />
    </div>
  );
};

const preview: Preview = {
  // Autodocs global: aplica la generacion automatica de documentacion a
  // TODAS las stories del proyecto, sin necesidad de declarar
  // `tags: ['autodocs']` en cada archivo .stories.tsx.
  tags: ['autodocs'],
  decorators: [withPadding, withBackground, withViewport],
  parameters: {
    backgrounds: {
      default: 'light',
      values: [
        { name: 'light', value: '#ffffff' },
        { name: 'dark', value: '#1a1a1a' },
      ],
    },
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/i,
      },
    },
  },
};

export default preview;
