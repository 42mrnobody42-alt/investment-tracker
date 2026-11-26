import styles from './ButtonMotionWave.module.css';

import { useEffect, useRef, useState } from 'react';

import type { MouseEvent } from 'react';

import type { ButtonMotionWaveProps } from './ButtonMotionWave.types';

interface WaveInstance {
  id: number;
  x: string;
  y: string;
}
const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

export function ButtonMotionWave({
  variant = 'primary',
  size = 'm',
  loading = false,
  disabled = false,
  type = 'button',
  className,
  children,
  onClick,
  theme,
  radius = 'md',
  shadow = 'sm',
  fontFamily = 'sans',
  fontWeight = 'medium',
  lineHeight = 'tight',
  letterSpacing = 'normal',
  fontSize,
  ...rest
}: ButtonMotionWaveProps) {
  const [waves, setWaves] = useState<WaveInstance[]>([]);
  const timers = useRef<number[]>([]);
  useEffect(() => () => timers.current.forEach((t) => clearTimeout(t)), []);

  const handleClick = (e: MouseEvent<HTMLButtonElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const id = Date.now() + Math.random();
    setWaves((p) => [
      ...p,
      { id, x: `${e.clientX - rect.left}px`, y: `${e.clientY - rect.top}px` },
    ]);
    timers.current.push(
      window.setTimeout(() => setWaves((p) => p.filter((w) => w.id !== id)), 4000),
    );
    onClick?.(e);
  };

  const classes = [
    styles.button,
    styles[variant],
    styles[size],
    styles[`radius${cap(radius)}`],
    styles[`shadow${shadow === '2xl' ? '2xl' : cap(shadow)}`],
    styles[`font${cap(fontFamily)}`],
    styles[`weight${cap(fontWeight)}`],
    styles[`lh${cap(lineHeight)}`],
    styles[`ls${cap(letterSpacing)}`],
    fontSize ? styles[`fs${fontSize === '2xl' ? '2xl' : cap(fontSize)}`] : '',
    className,
  ]
    .filter((c): c is string => Boolean(c))
    .join(' ');

  return (
    <button
      type={type}
      className={classes}
      disabled={disabled || loading}
      aria-busy={loading}
      data-theme={theme}
      onClick={handleClick}
      {...rest}
    >
      <span className={styles.label}>{children}</span>
      {waves.map((w) => (
        <span key={w.id} className={styles.waveWrapper} aria-hidden="true">
          <span
            className={styles.waveRingThick}
            style={{ '--wave-x': w.x, '--wave-y': w.y } as React.CSSProperties}
          />
          <span
            className={styles.waveRing}
            style={{ '--wave-x': w.x, '--wave-y': w.y } as React.CSSProperties}
          />
        </span>
      ))}
    </button>
  );
}
