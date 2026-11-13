import '../src/styles/branding/colors.css';
import '../src/styles/branding/typography.css';
import '../src/styles/branding/layout.css';
import '../src/styles/branding/components.css';
import '../src/styles/branding/motion.css';
import '../src/styles/branding/themes/light.css';
import '../src/styles/branding/themes/dark.css';
import '../src/styles/branding/themes/high-contrast.css';

import type { Decorator, Preview } from '@storybook/react-vite';

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
