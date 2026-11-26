import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { ButtonMotionWave } from './ButtonMotionWave';

describe('ButtonMotionWave', () => {
  it('renderiza el children', () => {
    render(<ButtonMotionWave>Click me</ButtonMotionWave>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('dispara onClick', async () => {
    const onClick = vi.fn();
    render(<ButtonMotionWave onClick={onClick}>Click</ButtonMotionWave>);
    await userEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('respeta disabled', () => {
    render(<ButtonMotionWave disabled>Disabled</ButtonMotionWave>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
