package com.investmenttracker.component.masking;

import java.io.IOException;
import java.util.Set;

import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Filtro que decide si la ofuscación debe estar activa durante la petición,
 * según el endpoint invocado.
 *
 * <p>
 * Endpoints que devuelven datos propios del usuario autenticado (login,
 * refresh-token, etc.) desactivan la ofuscación para que el usuario vea sus
 * datos reales. El resto de endpoints mantiene la ofuscación activa.
 */
@Component
public class MaskingFilter extends OncePerRequestFilter {

    /** Rutas donde el usuario ve sus propios datos reales. */
    private static final Set<String> OWN_DATA_PATHS = Set.of(
            "/api/auth/refresh-token");

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {
        try {
            String path = request.getRequestURI();
            if (OWN_DATA_PATHS.contains(path)) {
                MaskingContext.disable();
            } else {
                MaskingContext.enable();
            }
            filterChain.doFilter(request, response);
        } finally {
            MaskingContext.clear();
        }
    }
}
