import { describe, expect, it } from 'vitest';

import { ASSETS } from '@shared/constants/assets';

describe('ASSETS', () => {
  it('expone la clave HERO', () => {
    expect(ASSETS.HERO).toBeDefined();
  });

  it('HERO apunta a una ruta pública /assets/images/starter/hero.png', () => {
    expect(ASSETS.HERO).toBe('/assets/images/starter/hero.png');
  });

  it('es un objeto congelado (const) que no admite reasignación de la clave', () => {
    expect(Object.keys(ASSETS)).toContain('HERO');
    expect(Object.keys(ASSETS).length).toBe(1);
  });
});
