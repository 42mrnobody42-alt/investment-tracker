import { useEffect } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';

import { DesignTokens } from './DesignTokens';

/**
 * Catálogo visual de los design tokens de Investment Tracker Pro.
 *
 * Lee los tokens del tema activo (`data-theme`) desde
 * `frontend/src/styles/branding/`. Fuente de verdad:
 * `colors.css`, `typography.css`, `layout.css`,
 * `components.css`, `motion.css`.
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

/**
 * Aplica un tema al `documentElement` (no a un div local) para que
 * `getComputedStyle(documentElement)` del componente vea los valores
 * correctos. Los tokens de `themes/*.css` usan el selector
 * `[data-theme='X']`, que requiere que el atributo esté en `<html>`.
 */
function ThemeWrapper({ theme, children }: { theme: string; children: React.ReactNode }) {
  useEffect(() => {
    const prev = document.documentElement.getAttribute('data-theme');
    document.documentElement.setAttribute('data-theme', theme);
    return () => {
      if (prev) document.documentElement.setAttribute('data-theme', prev);
      else document.documentElement.removeAttribute('data-theme');
    };
  }, [theme]);

  return <>{children}</>;
}

export const Dark: Story = {
  render: () => (
    <ThemeWrapper theme="dark">
      <DesignTokens />
    </ThemeWrapper>
  ),
};

export const HighContrast: Story = {
  render: () => (
    <ThemeWrapper theme="high-contrast">
      <DesignTokens />
    </ThemeWrapper>
  ),
};
