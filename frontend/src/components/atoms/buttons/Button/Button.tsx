import styles from './Button.module.css';

import type { ButtonProps } from './Button.types';

const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

export function Button({
  variant = 'primary',
  size = 'm',
  loading = false,
  disabled = false,
  type = 'button',
  className,
  children,
  theme,
  radius = 'md',
  shadow = 'sm',
  fontFamily = 'sans',
  fontWeight = 'medium',
  lineHeight = 'tight',
  letterSpacing = 'normal',
  fontSize,
  ...rest
}: ButtonProps) {
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
      {...rest}
    >
      {children}
    </button>
  );
}
