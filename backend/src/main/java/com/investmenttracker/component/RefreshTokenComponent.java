package com.investmenttracker.component;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class RefreshTokenComponent {

    @Value("${refresh-token.ttl-hours}")
    private int ttlHours;

    private final Map<String, RefreshTokenEntry> refreshTokens = new ConcurrentHashMap<>();

    /**
     * Genera un refresh token aleatorio
     */
    public String generateRefreshToken(String username) {
        byte[] randomBytes = new byte[64];
        new SecureRandom().nextBytes(randomBytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
        
        RefreshTokenEntry entry = RefreshTokenEntry.builder()
            .username(username)
            .createdAt(LocalDateTime.now())
            .lastAccessAt(LocalDateTime.now())
            .expiresAt(LocalDateTime.now().plusHours(ttlHours))
            .build();
        
        refreshTokens.put(token, entry);
        log.debug("Refresh token generado para usuario: {} (TTL: {} horas)", username, ttlHours);
        return token;
    }

    /**
     * Valida el refresh token y actualiza la última actividad
     */
    public String validateAndGetUsername(String refreshToken) {
        RefreshTokenEntry entry = refreshTokens.get(refreshToken);
        
        if (entry == null) {
            log.warn("Refresh token no encontrado");
            return null;
        }
        
        // Verificar expiración por inactividad
        if (LocalDateTime.now().isAfter(entry.getExpiresAt())) {
            log.warn("Refresh token expirado por inactividad para usuario: {}", entry.getUsername());
            refreshTokens.remove(refreshToken);
            return null;
        }
        
        // Actualizar última actividad (sesión deslizante)
        entry.setLastAccessAt(LocalDateTime.now());
        entry.setExpiresAt(LocalDateTime.now().plusHours(ttlHours));
        
        log.debug("Refresh token validado para usuario: {} (nueva expiración: {})", 
                  entry.getUsername(), entry.getExpiresAt());
        return entry.getUsername();
    }

    /**
     * Revoca el refresh token (logout)
     */
    public void revokeRefreshToken(String refreshToken) {
        refreshTokens.remove(refreshToken);
        log.debug("Refresh token revocado");
    }

    /**
     * Limpia tokens expirados
     */
    public void clearExpiredTokens() {
        LocalDateTime now = LocalDateTime.now();
        refreshTokens.entrySet().removeIf(entry -> now.isAfter(entry.getValue().getExpiresAt()));
    }

    /**
     * Limpia todos los tokens (testing)
     */

    /**
     * SOLO PARA TESTING - Expira inmediatamente un refresh token
     */
    public void expireForTest(String refreshToken) {
        RefreshTokenEntry entry = refreshTokens.get(refreshToken);
        if (entry != null) {
            entry.setExpiresAt(LocalDateTime.now().minusSeconds(1));
            log.debug("Refresh token expirado para testing: {}", refreshToken);
        }
    }
    public void clear() {
        refreshTokens.clear();
    }

    /**
     * Obtiene la cantidad de tokens activos
     */
    public int getActiveTokens() {
        return refreshTokens.size();
    }

    /**
     * Clase interna
     */
    @lombok.Builder
    @lombok.Data
    private static class RefreshTokenEntry {
        private String username;
        private LocalDateTime createdAt;
        private LocalDateTime lastAccessAt;
        private LocalDateTime expiresAt;
    }
}
