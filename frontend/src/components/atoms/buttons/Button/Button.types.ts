import type { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type ButtonSize = 'xxs' | 'xs' | 's' | 'm' | 'l' | 'xl' | 'xxl';
export type ButtonRadius = 'sm' | 'md' | 'lg' | 'xl' | 'full' | 'none';
export type ButtonShadow = 'none' | 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';
export type ButtonFontFamily = 'sans' | 'mono';
export type ButtonFontSize = 'xs' | 'sm' | 'base' | 'lg' | 'xl' | '2xl';
export type ButtonFontWeight = 'regular' | 'medium' | 'semibold' | 'bold';
export type ButtonLineHeight = 'tight' | 'normal' | 'relaxed';
export type ButtonLetterSpacing = 'tight' | 'normal' | 'wide';
export type ButtonTheme = 'light' | 'dark' | 'high-contrast';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
  children: ReactNode;
  radius?: ButtonRadius;
  shadow?: ButtonShadow;
  fontFamily?: ButtonFontFamily;
  fontSize?: ButtonFontSize;
  fontWeight?: ButtonFontWeight;
  lineHeight?: ButtonLineHeight;
  letterSpacing?: ButtonLetterSpacing;
  theme?: ButtonTheme;
}
