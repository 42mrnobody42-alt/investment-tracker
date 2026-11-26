import styles from './ButtonMotionVibrate.module.css';

import { useEffect, useRef, useState } from 'react';

import type { ButtonMotionVibrateProps } from './ButtonMotionVibrate.types';

const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

export function ButtonMotionVibrate({
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
}: ButtonMotionVibrateProps) {
  const [isVibrating, setIsVibrating] = useState(false);
  const [clickCount, setClickCount] = useState(0);
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
    isVibrating ? styles.vibrating : '',
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
      data-vibrate-count={clickCount}
      onClick={(e) => {
        // Forzar re-disparo: quitar clase, reflow, poner clase
        setIsVibrating(false);
        setClickCount((c) => c + 1);
        // requestAnimationFrame garantiza el reflow antes de re-aplicar
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            setIsVibrating(true);
            timers.current.push(window.setTimeout(() => setIsVibrating(false), 2000));
          });
        });
        onClick?.(e);
      }}
      {...rest}
    >
      <span className={styles.label}>{children}</span>
    </button>
  );
}
