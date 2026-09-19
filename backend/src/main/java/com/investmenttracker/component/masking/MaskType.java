package com.investmenttracker.component.masking;

/**
 * Tipos de ofuscación soportados.
 * Para agregar un nuevo tipo (ej: MONTO, CUENTA_BANCARIA),
 * añádelo aquí y agrega su caso en {@link DataMasking#mask}.
 */
public enum MaskType {
    EMAIL,
    CELULAR,
    NOMBRE
}
