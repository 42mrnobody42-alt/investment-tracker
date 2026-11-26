import type { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonMotionVibrateVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type ButtonMotionVibrateSize = 'xxs' | 'xs' | 's' | 'm' | 'l' | 'xl' | 'xxl';
export type ButtonMotionVibrateRadius = 'sm' | 'md' | 'lg' | 'xl' | 'full' | 'none';
export type ButtonMotionVibrateShadow = 'none' | 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';
export type ButtonMotionVibrateFontFamily = 'sans' | 'mono';
export type ButtonMotionVibrateFontSize = 'xs' | 'sm' | 'base' | 'lg' | 'xl' | '2xl';
export type ButtonMotionVibrateFontWeight = 'regular' | 'medium' | 'semibold' | 'bold';
export type ButtonMotionVibrateLineHeight = 'tight' | 'normal' | 'relaxed';
export type ButtonMotionVibrateLetterSpacing = 'tight' | 'normal' | 'wide';
export type ButtonMotionVibrateTheme = 'light' | 'dark' | 'high-contrast';

export interface ButtonMotionVibrateProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonMotionVibrateVariant;
  size?: ButtonMotionVibrateSize;
  loading?: boolean;
  children: ReactNode;
  radius?: ButtonMotionVibrateRadius;
  shadow?: ButtonMotionVibrateShadow;
  fontFamily?: ButtonMotionVibrateFontFamily;
  fontSize?: ButtonMotionVibrateFontSize;
  fontWeight?: ButtonMotionVibrateFontWeight;
  lineHeight?: ButtonMotionVibrateLineHeight;
  letterSpacing?: ButtonMotionVibrateLetterSpacing;
  theme?: ButtonMotionVibrateTheme;
}
