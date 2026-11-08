import type { Meta, StoryObj } from '@storybook/react-vite';

import { DesignTokensCompare } from './DesignTokensCompare';

/**
 * Compara los tokens del branding actual
 * (`frontend/src/styles/branding/`) con los tokens generados
 * desde DTCG (`frontend/src/components/imported/generated/`).
 * Las filas rojas indican diferencias.
 */
const meta: Meta<typeof DesignTokensCompare> = {
  title: 'DesignTokens/Compare',
  component: DesignTokensCompare,
  parameters: {
    layout: 'fullscreen',
    docs: {
      description: {
        component:
          'Compara branding actual vs tokens generados. Las filas rojas marcan diferencias.',
      },
    },
  },
  argTypes: {
    theme: {
      control: 'select',
      options: ['light', 'dark', 'high-contrast'],
    },
    onlyDiff: { control: 'boolean' },
  },
};

export default meta;

type Story = StoryObj<typeof DesignTokensCompare>;

export const Compare: Story = {
  args: { theme: 'light', onlyDiff: false },
};

export const CompareDark: Story = {
  args: { theme: 'dark', onlyDiff: false },
};

export const CompareHighContrast: Story = {
  args: { theme: 'high-contrast', onlyDiff: false },
};

export const CompareOnlyDiff: Story = {
  args: { theme: 'light', onlyDiff: true },
};
