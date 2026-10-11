import '@styles/branding/paleta-colores-corporativa.css';
import '@styles/branding/tipografia.css';
import '@styles/branding/estilos-componentes.css';
import '@styles/branding/layout.css';
import '@styles/branding/motion.css';
import '@styles/index.css';

import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import App from '@app/App.tsx';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
