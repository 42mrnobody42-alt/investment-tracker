import { createContext } from 'react';

export type Theme = 'light' | 'dark' | 'high-contrast';

export interface ThemeContextValue {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
}

export const ThemeContext = createContext<ThemeContextValue | null>(null);

export const THEMES: readonly Theme[] = ['light', 'dark', 'high-contrast'];
export const STORAGE_KEY = 'investment-tracker-theme';
