import type { Meta, StoryObj } from '@storybook/react-vite';

import { ThemeProvider } from './ThemeProvider';
import { THEMES } from './ThemeProvider.types';
import { useTheme } from './useTheme';

function ThemeDemo() {
  const { theme, setTheme, toggleTheme } = useTheme();
  return (
    <div style={{ padding: 24, fontFamily: 'var(--font-sans)' }}>
      <p>
        Tema actual: <strong>{theme}</strong>
      </p>
      <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
        {THEMES.map((t) => (
          <button
            key={t}
            type="button"
            onClick={() => setTheme(t)}
            style={{
              padding: '8px 12px',
              background: t === theme ? 'var(--color-brand-primary)' : 'var(--color-surface)',
              color: t === theme ? 'var(--color-text-inverse)' : 'var(--color-text)',
              border: '1px solid var(--color-border)',
              borderRadius: 'var(--radius-md)',
              cursor: 'pointer',
            }}
          >
            {t}
          </button>
        ))}
        <button
          type="button"
          onClick={toggleTheme}
          style={{
            padding: '8px 12px',
            border: '1px solid var(--color-border)',
            borderRadius: 'var(--radius-md)',
            cursor: 'pointer',
          }}
        >
          toggle
        </button>
      </div>
      <p style={{ color: 'var(--color-text-muted)', marginTop: 24 }}>
        El tema se guarda en localStorage bajo la clave <code>investment-tracker-theme</code>. Si no
        hay preferencia persistida, se usa <code>prefers-color-scheme</code>.
      </p>
    </div>
  );
}

const meta: Meta<typeof ThemeProvider> = {
  title: 'Providers/ThemeProvider',
  component: ThemeProvider,
  parameters: { layout: 'fullscreen' },
  decorators: [
    (Story) => (
      <ThemeProvider>
        <Story />
      </ThemeProvider>
    ),
  ],
};

export default meta;

type Story = StoryObj<typeof ThemeProvider>;

export const Default: Story = {
  render: () => <ThemeDemo />,
};
