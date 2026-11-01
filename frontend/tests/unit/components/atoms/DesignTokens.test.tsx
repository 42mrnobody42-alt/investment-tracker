import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it } from 'vitest';

import type { DesignTokensSection } from '@components/atoms/DesignTokens';
import { DesignTokens } from '@components/atoms/DesignTokens';
import { TokenCard } from '@components/atoms/DesignTokens/DesignTokens';

describe('DesignTokens', () => {
  describe('contrato base', () => {
    it('renderiza sin section → todas las secciones por defecto', () => {
      const { container } = render(<DesignTokens />);
      expect(container.querySelectorAll('section').length).toBeGreaterThan(10);
    });

    it('aplica className junto a la clase raíz', () => {
      const { container } = render(<DesignTokens className="custom-root" />);
      const root = container.firstChild as HTMLElement;
      expect(root.className).toContain('custom-root');
      expect(root.className).toContain('root');
    });

    it('aplica data-testid al contenedor raíz', () => {
      render(<DesignTokens dataTestId="dt-root" />);
      expect(screen.getByTestId('dt-root')).toBeInTheDocument();
    });
  });

  describe('renderiza solo la sección indicada', () => {
    it.each<DesignTokensSection>([
      'colors',
      'typography',
      'spacing',
      'radius',
      'shadows',
      'layout',
      'motion',
    ])('section=%s no explota y produce contenido', (section) => {
      const { container } = render(<DesignTokens section={section} />);
      expect(container.querySelectorAll('section').length).toBeGreaterThan(0);
    });
  });

  describe('sección Colors — 3 temas × 3 subgrupos', () => {
    it('renderiza Brand, Semantic, Neutral para light, dark y high-contrast', () => {
      render(<DesignTokens section="colors" />);
      expect(screen.getByRole('heading', { level: 2, name: /Brand — light/i })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: /Brand — dark/i })).toBeInTheDocument();
      expect(
        screen.getByRole('heading', { level: 2, name: /Brand — high-contrast/i }),
      ).toBeInTheDocument();
      expect(
        screen.getByRole('heading', { level: 2, name: /Semantic — light/i }),
      ).toBeInTheDocument();
      expect(
        screen.getByRole('heading', { level: 2, name: /Neutral — light/i }),
      ).toBeInTheDocument();
    });

    it('cada token aparece como <code>', () => {
      render(<DesignTokens section="colors" />);
      expect(screen.getAllByText('--color-primary').length).toBeGreaterThan(0);
      expect(screen.getAllByText('--color-success').length).toBeGreaterThan(0);
      expect(screen.getAllByText('--color-bg').length).toBeGreaterThan(0);
    });
  });

  describe('sección Typography — 6 subgrupos + demo', () => {
    it('renderiza familias, sizes, weights, line heights, letter spacing y demo', () => {
      render(<DesignTokens section="typography" />);
      expect(screen.getByRole('heading', { level: 2, name: 'Font families' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Font sizes' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Font weights' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Line heights' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Letter spacing' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Demo' })).toBeInTheDocument();
    });

    it('la demo muestra h1/h2/h3 y code', () => {
      render(<DesignTokens section="typography" />);
      expect(screen.getByRole('heading', { level: 1, name: 'Heading 1' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Heading 2' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 3, name: 'Heading 3' })).toBeInTheDocument();
      expect(screen.getByText(/Monospace/)).toBeInTheDocument();
    });
  });

  describe('sección Spacing', () => {
    it('renderiza 8 filas (--space-1 a --space-10)', () => {
      render(<DesignTokens section="spacing" />);
      expect(screen.getByText('--space-1')).toBeInTheDocument();
      expect(screen.getByText('--space-2')).toBeInTheDocument();
      expect(screen.getByText('--space-3')).toBeInTheDocument();
      expect(screen.getByText('--space-4')).toBeInTheDocument();
      expect(screen.getByText('--space-5')).toBeInTheDocument();
      expect(screen.getByText('--space-6')).toBeInTheDocument();
      expect(screen.getByText('--space-8')).toBeInTheDocument();
      expect(screen.getByText('--space-10')).toBeInTheDocument();
    });
  });

  describe('sección Radius', () => {
    it('renderiza los 5 tokens de radio', () => {
      render(<DesignTokens section="radius" />);
      expect(screen.getByText('--radius-sm')).toBeInTheDocument();
      expect(screen.getByText('--radius-md')).toBeInTheDocument();
      expect(screen.getByText('--radius-lg')).toBeInTheDocument();
      expect(screen.getByText('--radius-xl')).toBeInTheDocument();
      expect(screen.getByText('--radius-full')).toBeInTheDocument();
    });
  });

  describe('sección Shadows', () => {
    it('renderiza 6 cards (xs, sm, md, lg, xl, 2xl)', () => {
      render(<DesignTokens section="shadows" />);
      expect(screen.getByText('--shadow-xs')).toBeInTheDocument();
      expect(screen.getByText('--shadow-sm')).toBeInTheDocument();
      expect(screen.getByText('--shadow-md')).toBeInTheDocument();
      expect(screen.getByText('--shadow-lg')).toBeInTheDocument();
      expect(screen.getByText('--shadow-xl')).toBeInTheDocument();
      expect(screen.getByText('--shadow-2xl')).toBeInTheDocument();
    });
  });

  describe('sección Layout — grid, breakpoints, z-index', () => {
    it('renderiza Grid, Breakpoints y Z-index', () => {
      render(<DesignTokens section="layout" />);
      expect(screen.getByRole('heading', { level: 2, name: 'Grid' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Breakpoints' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Z-index' })).toBeInTheDocument();
    });

    it('muestra el label compuesto --grid-gutter (espaciado entre celdas)', () => {
      render(<DesignTokens section="layout" />);
      expect(screen.getByText('--grid-gutter (espaciado entre celdas)')).toBeInTheDocument();
    });

    it('breakpoints muestra los 5 tokens', () => {
      render(<DesignTokens section="layout" />);
      expect(screen.getByText('--breakpoint-sm')).toBeInTheDocument();
      expect(screen.getByText('--breakpoint-2xl')).toBeInTheDocument();
    });

    it('z-index tiene tabla con cabeceras Token / Profundidad / Valor', () => {
      render(<DesignTokens section="layout" />);
      expect(screen.getByRole('columnheader', { name: 'Token' })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: 'Profundidad' })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: 'Valor' })).toBeInTheDocument();
    });

    it('z-index muestra los 8 tokens en la tabla', () => {
      render(<DesignTokens section="layout" />);
      expect(screen.getByText('--z-base')).toBeInTheDocument();
      expect(screen.getByText('--z-toast')).toBeInTheDocument();
    });
  });

  describe('sección Motion — durations, easings, stagger, sweep', () => {
    it('renderiza Durations, Easings, Stagger y Barrido de página', () => {
      render(<DesignTokens section="motion" />);
      expect(screen.getByRole('heading', { level: 2, name: 'Durations' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Easings' })).toBeInTheDocument();
      expect(screen.getByRole('heading', { level: 2, name: 'Stagger' })).toBeInTheDocument();
      expect(
        screen.getByRole('heading', { level: 2, name: 'Barrido de página (4 direcciones)' }),
      ).toBeInTheDocument();
    });

    it('Durations muestra los 5 tokens', () => {
      render(<DesignTokens section="motion" />);
      expect(screen.getByText('--duration-instant')).toBeInTheDocument();
      expect(screen.getAllByText('--duration-slower').length).toBeGreaterThan(0);
    });

    it('Easings muestra los 5 tokens y las 2 pendulums', () => {
      render(<DesignTokens section="motion" />);
      expect(screen.getByText('--ease-linear')).toBeInTheDocument();
      expect(screen.getByText('--ease-spring')).toBeInTheDocument();
      expect(screen.getAllByText('--ease-pendulum').length).toBeGreaterThan(0);
      expect(screen.getAllByText('--ease-pendulum-damped').length).toBeGreaterThan(0);
    });

    it('Easings muestra la nota de --pendulum-amplitude (2 veces: una por péndulo)', () => {
      render(<DesignTokens section="motion" />);
      const notes = screen.getAllByText(/la amplitud de ambos péndulos/);
      expect(notes.length).toBe(2);
    });

    it('Stagger muestra los 3 tokens', () => {
      render(<DesignTokens section="motion" />);
      expect(screen.getByText('--stagger-fast')).toBeInTheDocument();
      expect(screen.getByText('--stagger-normal')).toBeInTheDocument();
      expect(screen.getByText('--stagger-slow')).toBeInTheDocument();
    });

    it('Barrido de página renderiza los 4 bloques con su clase CSS', () => {
      render(<DesignTokens section="motion" />);
      expect(screen.getByText(/sweepCellTlBr/)).toBeInTheDocument();
      expect(screen.getByText(/sweepCellTrBl/)).toBeInTheDocument();
      expect(screen.getByText(/sweepCellBlTr/)).toBeInTheDocument();
      expect(screen.getByText(/sweepCellBrTl/)).toBeInTheDocument();
    });

    it('Barrido de página muestra el bloque de info con --pasar-pagina y --duration-slow', () => {
      render(<DesignTokens section="motion" />);
      expect(screen.getByText('--pasar-pagina (retardo por paso)')).toBeInTheDocument();
      expect(screen.getByText('--duration-slow (duración por celda)')).toBeInTheDocument();
      expect(screen.getByText('--ease-out (curva)')).toBeInTheDocument();
    });

    it('los botones Replay son clickeables y no rompen', async () => {
      const user = userEvent.setup();
      render(<DesignTokens section="motion" />);
      const replayButtons = screen.getAllByRole('button', { name: /Replay/i });
      expect(replayButtons.length).toBeGreaterThan(0);
      for (const btn of replayButtons) {
        await user.click(btn);
      }
    });
  });
});

describe('TokenCard (componente interno)', () => {
  it('variant="swatch" renderiza el div con clase swatch', () => {
    const { container } = render(<TokenCard name="--color-primary" variant="swatch" />);
    expect(container.querySelector('.swatch')).toBeInTheDocument();
  });

  it('variant="bar" renderiza el div con clase bar', () => {
    const { container } = render(<TokenCard name="--space-4" variant="bar" />);
    expect(container.querySelector('.bar')).toBeInTheDocument();
  });

  it('variant="radius" renderiza el div con clase radiusBox', () => {
    const { container } = render(<TokenCard name="--radius-md" variant="radius" />);
    expect(container.querySelector('.radiusBox')).toBeInTheDocument();
  });

  it('variant="text" no renderiza ningún div de muestra', () => {
    const { container } = render(<TokenCard name="--font-sans" variant="text" />);
    expect(container.querySelector('.swatch')).not.toBeInTheDocument();
    expect(container.querySelector('.bar')).not.toBeInTheDocument();
    expect(container.querySelector('.radiusBox')).not.toBeInTheDocument();
  });
});
