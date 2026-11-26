import type { Meta, StoryObj } from '@storybook/react-vite';

import { ButtonMotionShine } from './ButtonMotionShine';

const meta: Meta<typeof ButtonMotionShine> = {
  title: 'Atoms/ButtonMotionShine',
  component: ButtonMotionShine,
  argTypes: {
    children: { control: 'text' },
    variant: { control: 'select', options: ['primary', 'secondary', 'ghost', 'danger'] },
    size: { control: 'select', options: ['xxs', 'xs', 's', 'm', 'l', 'xl', 'xxl'] },
    radius: { control: 'select', options: ['none', 'sm', 'md', 'lg', 'xl', 'full'] },
    shadow: { control: 'select', options: ['none', 'xs', 'sm', 'md', 'lg', 'xl', '2xl'] },
    fontFamily: { control: 'select', options: ['sans', 'mono'] },
    fontSize: { control: 'select', options: ['xs', 'sm', 'base', 'lg', 'xl', '2xl'] },
    fontWeight: { control: 'select', options: ['regular', 'medium', 'semibold', 'bold'] },
    lineHeight: { control: 'select', options: ['tight', 'normal', 'relaxed'] },
    letterSpacing: { control: 'select', options: ['tight', 'normal', 'wide'] },
    theme: { control: 'select', options: [undefined, 'light', 'dark', 'high-contrast'] },
    loading: { control: 'boolean' },
    disabled: { control: 'boolean' },
  },
  parameters: {
    docs: {
      description: {
        component: [
          'Botón con **shine sweep** + hundirse al click. Usa tokens de `branding/`.',
          'Cada click añade un brillo independiente (se superponen).',
          '',
          '### Props personalizables',
          'Mismas que `Button`: variant, size, radius, shadow, fontFamily, fontSize, fontWeight, lineHeight, letterSpacing, theme, children.',
          '',
          '### Estados',
          '| Estado | Trigger | Efecto |',
          '| --- | --- | --- |',
          '| Active | click | `scale(0.97)` + brillo |',
        ].join('\n'),
      },
    },
  },
};
export default meta;
type Story = StoryObj<typeof ButtonMotionShine>;
export const Default: Story = { args: { children: 'MotionShine' } };

// ── Stories por dispositivo (estándares del proyecto) ─────────────────────
// Tamaños basados en playwright.config.ts + pruebas.md + agente-frontend §3.4

export const Mobile: Story = {
  args: {
    children: 'Mobile',
    size: 's',
    fontSize: 'sm',
  },
  parameters: {
    viewport: { defaultViewport: 'mobile1' },
    docs: { description: { story: '393×873 (mobile-chrome / mobile-android / mobile-safari)' } },
  },
};

export const Tablet: Story = {
  args: {
    children: 'Tablet',
    size: 'm',
    fontSize: 'base',
  },
  parameters: {
    viewport: { defaultViewport: 'tablet' },
    docs: { description: { story: '768×1024 (iPad portrait)' } },
  },
};

export const Desktop: Story = {
  args: {
    children: 'Desktop',
    size: 'm',
    fontSize: 'base',
  },
  parameters: {
    viewport: { defaultViewport: 'desktop' },
    docs: { description: { story: '1920×1080 (desktop)' } },
  },
};

export const TvFhd: Story = {
  args: {
    children: 'TV FHD',
    size: 'l',
    fontSize: 'lg',
  },
  parameters: {
    viewport: { defaultViewport: 'tv' },
    docs: { description: { story: '1920×1080 (tv-fhd) — fuente ≥18px, target ≥48px' } },
  },
};

export const Tv4k: Story = {
  args: {
    children: 'TV 4K',
    size: 'xl',
    fontSize: 'xl',
  },
  parameters: {
    viewport: { defaultViewport: 'tv' },
    docs: { description: { story: '3840×2160 (tv-4k)' } },
  },
};
