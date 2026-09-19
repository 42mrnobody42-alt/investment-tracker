package com.investmenttracker.component.masking;

import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * Utilidades puras de ofuscación. Sin estado, sin dependencias.
 * Reglas:
 *   - EMAIL:    "user@test.com"        → "u***@***.com"
 *   - CELULAR:  3001234567             → "***4567"
 *   - NOMBRE:   "Juan Pérez García"    → "J*** P*** G***"
 */
public final class DataMasking {

    private DataMasking() {
        // utilidad
    }

    public static String mask(Object value, MaskType type) {
        if (value == null) {
            return null;
        }
        String s = String.valueOf(value);
        if (s.isBlank()) {
            return s;
        }
        return switch (type) {
            case EMAIL -> maskEmail(s);
            case CELULAR -> maskCelular(s);
            case NOMBRE -> maskNombre(s);
        };
    }

    static String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 0) {
            return "***";
        }
        String first = email.substring(0, 1);
        String domain = email.substring(at + 1);
        int dot = domain.lastIndexOf('.');
        String tld = (dot > 0) ? domain.substring(dot) : "";
        return first + "***@***" + tld;
    }

    static String maskCelular(String celular) {
        String digits = celular.replaceAll("\\D", "");
        if (digits.length() <= 4) {
            return "***";
        }
        return "***" + digits.substring(digits.length() - 4);
    }

    static String maskNombre(String nombre) {
        return Arrays.stream(nombre.split("\\s+"))
                .filter(p -> !p.isEmpty())
                .map(p -> p.charAt(0) + "***")
                .collect(Collectors.joining(" "));
    }
}
