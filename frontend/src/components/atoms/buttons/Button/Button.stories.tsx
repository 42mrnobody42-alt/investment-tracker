import type { Meta, StoryObj } from '@storybook/react-vite';

import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Atoms/Button',
  component: Button,
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
          'Botón base del Design System. Usa tokens de `branding/`.',
          '',
          '### Props personalizables',
          '| Prop | Opciones | Default | Token |',
          '| --- | --- | --- | --- |',
          '| `variant` | primary, secondary, ghost, danger | primary | — |',
          '| `size` | xxs, xs, s, m, l, xl, xxl | m | `--button-spacing-padding-*` |',
          '| `radius` | none, sm, md, lg, xl, full | md | `--radius-*` |',
          '| `shadow` | none, xs, sm, md, lg, xl, 2xl | sm | `--shadow-*` |',
          '| `fontFamily` | sans, mono | sans | `--font-sans`, `--font-mono` |',
          '| `fontSize` | xs, sm, base, lg, xl, 2xl | (size) | `--font-size-*` |',
          '| `fontWeight` | regular, medium, semibold, bold | medium | `--font-weight-*` |',
          '| `lineHeight` | tight, normal, relaxed | tight | `--line-height-*` |',
          '| `letterSpacing` | tight, normal, wide | normal | `--letter-spacing-*` |',
          '| `theme` | light, dark, high-contrast | (hereda) | `branding/themes/*.css` |',
          '| `children` | texto libre | — | — |',
          '',
          '### Estados',
          '| Estado | Trigger | Efecto |',
          '| --- | --- | --- |',
          '| Default | — | color primario, borde, sombra |',
          '| Hover | mouse | `--color-brand-primary-hover` |',
          '| Active | click | `transform: scale(0.97)` |',
          '| Focus-visible | teclado | outline 2px |',
          '| Disabled | prop | opacity 0.6 |',
          '| Loading | prop | aria-busy |',
        ].join('\n'),
      },
    },
  },
};
export default meta;
type Story = StoryObj<typeof Button>;
export const Default: Story = { args: { children: 'Click me' } };

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
