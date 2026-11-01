/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Contrato fijo con el backend. Solo cambia si cambia el prefijo del backend. */
  readonly VITE_API_URL: string;
  /** Entorno actual. `tsc` rechaza valores fuera del union. */
  readonly VITE_APP_ENV: 'development' | 'qa' | 'production';
  /** Nombre mostrado en la UI. */
  readonly VITE_APP_NAME: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
