import styles from './ButtonMotionShine.module.css';

import { useEffect, useRef, useState } from 'react';

import type { ButtonMotionShineProps } from './ButtonMotionShine.types';

const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

export function ButtonMotionShine({
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
}: ButtonMotionShineProps) {
  const [waves, setWaves] = useState<number[]>([]);
  const timers = useRef<number[]>([]);
  useEffect(() => () => timers.current.forEach((t) => clearTimeout(t)), []);

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
      onClick={(e) => {
        const id = Date.now() + Math.random();
        setWaves((p) => [...p, id]);
        timers.current.push(
          window.setTimeout(() => setWaves((p) => p.filter((w) => w !== id)), 2000),
        );
        onClick?.(e);
      }}
      {...rest}
    >
      <span className={styles.label}>{children}</span>
      {waves.map((id) => (
        <span key={id} className={styles.shineWave} aria-hidden="true" />
      ))}
    </button>
  );
}
