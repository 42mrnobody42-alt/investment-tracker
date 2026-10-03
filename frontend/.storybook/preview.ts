import type { Preview } from '@storybook/react-vite';

// Decoradores globales (ThemeProvider, I18nextProvider, Router) se
// agregaran en TS-009. En TS-008 este archivo queda minimo para
// verificar que Storybook arranca correctamente.

const preview: Preview = {
  // Autodocs global: aplica la generacion automatica de documentacion a
  // TODAS las stories del proyecto, sin necesidad de declarar
  // `tags: ['autodocs']` en cada archivo .stories.tsx.
  tags: ['autodocs'],
  parameters: {
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/i,
      },
    },
  },
};

export default preview;
