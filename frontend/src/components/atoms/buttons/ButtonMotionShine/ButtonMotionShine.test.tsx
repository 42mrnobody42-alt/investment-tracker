import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { ButtonMotionShine } from './ButtonMotionShine';

describe('ButtonMotionShine', () => {
  it('renderiza el children', () => {
    render(<ButtonMotionShine>Click me</ButtonMotionShine>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('dispara onClick', async () => {
    const onClick = vi.fn();
    render(<ButtonMotionShine onClick={onClick}>Click</ButtonMotionShine>);
    await userEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('respeta disabled', () => {
    render(<ButtonMotionShine disabled>Disabled</ButtonMotionShine>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
