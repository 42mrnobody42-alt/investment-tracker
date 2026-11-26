import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';

import { ButtonMotionVibrate } from './ButtonMotionVibrate';

describe('ButtonMotionVibrate', () => {
  it('renderiza el children', () => {
    render(<ButtonMotionVibrate>Click me</ButtonMotionVibrate>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('dispara onClick', async () => {
    const onClick = vi.fn();
    render(<ButtonMotionVibrate onClick={onClick}>Click</ButtonMotionVibrate>);
    await userEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('respeta disabled', () => {
    render(<ButtonMotionVibrate disabled>Disabled</ButtonMotionVibrate>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
