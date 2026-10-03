import type { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** Variante visual del botón. */
  variant?: ButtonVariant;
  /** Tamaño del botón. */
  size?: ButtonSize;
  /** Si `true`, muestra estado de carga y bloquea la interacción. */
  loading?: boolean;
  /** Contenido del botón. */
  children: ReactNode;
}
