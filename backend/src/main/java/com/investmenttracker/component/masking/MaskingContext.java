package com.investmenttracker.component.masking;

/**
 * Contexto ThreadLocal que indica si la ofuscación está activa
 * para la petición en curso.
 *
 * <p>Default: {@code true} (ofuscar). Los endpoints que devuelven
 * datos propios del usuario autenticado (login, refresh-token, etc.)
 * deben desactivarlo temporalmente durante el request.
 */
public final class MaskingContext {

    private static final ThreadLocal<Boolean> ENABLED = ThreadLocal.withInitial(() -> Boolean.TRUE);

    private MaskingContext() {
        // utilidad
    }

    public static boolean isEnabled() {
        return Boolean.TRUE.equals(ENABLED.get());
    }

    public static void enable() {
        ENABLED.set(Boolean.TRUE);
    }

    public static void disable() {
        ENABLED.set(Boolean.FALSE);
    }

    public static void clear() {
        ENABLED.remove();
    }
}
