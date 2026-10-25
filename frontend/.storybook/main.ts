import type { StorybookConfig } from '@storybook/react-vite';

const config: StorybookConfig = {
  stories: ['../src/**/*.stories.@(ts|tsx)'],
  addons: ['@storybook/addon-docs', '@storybook/addon-a11y', '@storybook/addon-themes'],
  framework: {
    name: '@storybook/react-vite',
    options: {},
  },
  typescript: {
    reactDocgen: 'react-docgen-typescript',
  },
  viteFinal: async (config) => {
    config.build = config.build ?? {};
    // Solo para Storybook (storybook-static/), NO para dist/.
    // 5000 KB: margen 4.5x sobre el chunk actual (1.1 MB), cubre ~100 componentes
    // + motion + charts + forms + Storybook 11. Si se supera, Vite avisa y el
    // runner lo bloquea como W-NEW. Ver warnings-storybook.md (W-003).
    config.build.chunkSizeWarningLimit = 5000;
    return config;
  },
};

export default config;
