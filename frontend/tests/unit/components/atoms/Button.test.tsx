import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { Button } from '@components/atoms/Button';

describe('Button', () => {
  it('renderiza los children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('usa type="button" por defecto', () => {
    render(<Button>Click</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('type', 'button');
  });

  it('respeta el type explícito (submit)', () => {
    render(<Button type="submit">Enviar</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('type', 'submit');
  });

  it('aplica la clase de variante primary por defecto', () => {
    render(<Button>Click</Button>);
    expect(screen.getByRole('button').className).toContain('primary');
  });

  it.each([['primary'], ['secondary'], ['ghost'], ['danger']] as const)(
    'aplica la clase de variante %s',
    (variant) => {
      render(<Button variant={variant}>Click</Button>);
      expect(screen.getByRole('button').className).toContain(variant);
    },
  );

  it.each([['sm'], ['md'], ['lg']] as const)('aplica la clase de tamaño %s', (size) => {
    render(<Button size={size}>Click</Button>);
    expect(screen.getByRole('button').className).toContain(size);
  });

  it('usa tamaño md por defecto', () => {
    render(<Button>Click</Button>);
    expect(screen.getByRole('button').className).toContain('md');
  });

  it('aplica className externa sumada a las internas', () => {
    render(<Button className="custom-class">Click</Button>);
    expect(screen.getByRole('button').className).toContain('custom-class');
    expect(screen.getByRole('button').className).toContain('button');
  });

  it('dispara onClick al hacer click', async () => {
    const user = userEvent.setup();
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    await user.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('se deshabilita con disabled=true', () => {
    render(<Button disabled>Click</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('se deshabilita con loading=true y marca aria-busy', () => {
    render(<Button loading>Click</Button>);
    const btn = screen.getByRole('button');
    expect(btn).toBeDisabled();
    expect(btn).toHaveAttribute('aria-busy', 'true');
  });

  it('no dispara onClick cuando loading=true', async () => {
    const user = userEvent.setup();
    const handleClick = vi.fn();
    render(
      <Button loading onClick={handleClick}>
        Click
      </Button>,
    );
    await user.click(screen.getByRole('button'));
    expect(handleClick).not.toHaveBeenCalled();
  });

  it('pasa atributos HTML nativos (aria-label, data-testid)', () => {
    render(
      <Button aria-label="accion" data-testid="btn-1">
        Click
      </Button>,
    );
    const btn = screen.getByTestId('btn-1');
    expect(btn).toHaveAttribute('aria-label', 'accion');
  });
});
