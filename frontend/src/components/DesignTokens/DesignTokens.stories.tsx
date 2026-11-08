import type { Meta, StoryObj } from '@storybook/react-vite';

import { DesignTokens } from './DesignTokens';

/**
 * Catálogo visual de los design tokens de Investment Tracker Pro.
 *
 * Lee los tokens del tema activo (`data-theme`) desde
 * `frontend/src/styles/branding/`. Fuente de verdad:
 * `paleta-colores-corporativa.css`, `tipografia.css`, `layout.css`,
 * `estilos-componentes.css`, `motion.css`.
 */
const meta: Meta<typeof DesignTokens> = {
  title: 'DesignTokens/Overview',
  component: DesignTokens,
  parameters: {
    layout: 'fullscreen',
    docs: {
      description: {
        component:
          'Catálogo de design tokens. Muestra colores, tipografía, spacing, radius, shadows, layout y motion del tema activo.',
      },
    },
  },
  argTypes: {
    section: {
      control: 'select',
      options: ['colors', 'typography', 'spacing', 'radius', 'shadows', 'layout', 'motion'],
    },
  },
};

export default meta;

type Story = StoryObj<typeof DesignTokens>;

export const Colors: Story = {
  args: { section: 'colors' },
};

export const Typography: Story = {
  args: { section: 'typography' },
};

export const Spacing: Story = {
  args: { section: 'spacing' },
};

export const Radius: Story = {
  args: { section: 'radius' },
};

export const Shadows: Story = {
  args: { section: 'shadows' },
};

export const Layout: Story = {
  args: { section: 'layout' },
};

export const Motion: Story = {
  args: { section: 'motion' },
};

export const Dark: Story = {
  render: () => (
    <div data-theme="dark">
      <DesignTokens />
    </div>
  ),
};

export const HighContrast: Story = {
  render: () => (
    <div data-theme="high-contrast">
      <DesignTokens />
    </div>
  ),
};
