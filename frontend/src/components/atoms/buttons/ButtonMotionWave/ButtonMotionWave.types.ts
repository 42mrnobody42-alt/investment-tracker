import type { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonMotionWaveVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type ButtonMotionWaveSize = 'xxs' | 'xs' | 's' | 'm' | 'l' | 'xl' | 'xxl';
export type ButtonMotionWaveRadius = 'sm' | 'md' | 'lg' | 'xl' | 'full' | 'none';
export type ButtonMotionWaveShadow = 'none' | 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';
export type ButtonMotionWaveFontFamily = 'sans' | 'mono';
export type ButtonMotionWaveFontSize = 'xs' | 'sm' | 'base' | 'lg' | 'xl' | '2xl';
export type ButtonMotionWaveFontWeight = 'regular' | 'medium' | 'semibold' | 'bold';
export type ButtonMotionWaveLineHeight = 'tight' | 'normal' | 'relaxed';
export type ButtonMotionWaveLetterSpacing = 'tight' | 'normal' | 'wide';
export type ButtonMotionWaveTheme = 'light' | 'dark' | 'high-contrast';

export interface ButtonMotionWaveProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonMotionWaveVariant;
  size?: ButtonMotionWaveSize;
  loading?: boolean;
  children: ReactNode;
  radius?: ButtonMotionWaveRadius;
  shadow?: ButtonMotionWaveShadow;
  fontFamily?: ButtonMotionWaveFontFamily;
  fontSize?: ButtonMotionWaveFontSize;
  fontWeight?: ButtonMotionWaveFontWeight;
  lineHeight?: ButtonMotionWaveLineHeight;
  letterSpacing?: ButtonMotionWaveLetterSpacing;
  theme?: ButtonMotionWaveTheme;
}
