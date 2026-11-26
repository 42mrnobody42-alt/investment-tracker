import type { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonMotionShineVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type ButtonMotionShineSize = 'xxs' | 'xs' | 's' | 'm' | 'l' | 'xl' | 'xxl';
export type ButtonMotionShineRadius = 'sm' | 'md' | 'lg' | 'xl' | 'full' | 'none';
export type ButtonMotionShineShadow = 'none' | 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';
export type ButtonMotionShineFontFamily = 'sans' | 'mono';
export type ButtonMotionShineFontSize = 'xs' | 'sm' | 'base' | 'lg' | 'xl' | '2xl';
export type ButtonMotionShineFontWeight = 'regular' | 'medium' | 'semibold' | 'bold';
export type ButtonMotionShineLineHeight = 'tight' | 'normal' | 'relaxed';
export type ButtonMotionShineLetterSpacing = 'tight' | 'normal' | 'wide';
export type ButtonMotionShineTheme = 'light' | 'dark' | 'high-contrast';

export interface ButtonMotionShineProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonMotionShineVariant;
  size?: ButtonMotionShineSize;
  loading?: boolean;
  children: ReactNode;
  radius?: ButtonMotionShineRadius;
  shadow?: ButtonMotionShineShadow;
  fontFamily?: ButtonMotionShineFontFamily;
  fontSize?: ButtonMotionShineFontSize;
  fontWeight?: ButtonMotionShineFontWeight;
  lineHeight?: ButtonMotionShineLineHeight;
  letterSpacing?: ButtonMotionShineLetterSpacing;
  theme?: ButtonMotionShineTheme;
}
