package com.investmenttracker.security;

import com.investmenttracker.component.TokenBlacklistComponent;
import com.investmenttracker.service.JwtService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthFilter extends OncePerRequestFilter {

    @NonNull
    private final JwtService jwtService;

    @NonNull
    private final UserDetailsService userDetailsService;

    @NonNull
    private final TokenBlacklistComponent tokenBlacklistComponent;

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String username;

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        jwt = authHeader.substring(7);

        // Verificar si el token está en la blacklist
        if (tokenBlacklistComponent.isBlacklisted(jwt)) {
            log.warn("Token en blacklist - acceso denegado");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"code\":\"AUTH-005\",\"message\":\"Token inválido o expirado\"}");
            return;
        }

        try {
            username = jwtService.extractUsername(jwt);

            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                if (jwtService.validateToken(jwt, username)) {
                    Claims claims = jwtService.extractAllClaims(jwt);
                    @SuppressWarnings("unchecked")
                    List<String> tokenRoles = claims.get("roles", List.class);

                    List<String> userRoles = userDetails.getAuthorities().stream()
                        .map(a -> a.getAuthority())
                        .collect(Collectors.toList());

                    if (!tokenRoles.containsAll(userRoles) || !userRoles.containsAll(tokenRoles)) {
                        log.warn("Roles del token no coinciden con BD para usuario: {}", username);
                        filterChain.doFilter(request, response);
                        return;
                    }

                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                    );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);

                    log.debug("JWT validado para usuario: {} con roles: {}", username, userRoles);
                } else {
                    log.warn("Token inválido o expirado para usuario: {}", username);
                }
            }
        } catch (Exception e) {
            log.error("Error al procesar JWT: {}", e.getMessage());
        }

        filterChain.doFilter(request, response);
    }
}
