package com.investmenttracker.component;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class TokenBlacklistComponent {

    // Mapa: token -> fecha de expiración
    private final Map<String, LocalDateTime> blacklist = new ConcurrentHashMap<>();

    /**
     * Agrega un token a la blacklist
     */
    public void addToBlacklist(String token, LocalDateTime expirationTime) {
        Objects.requireNonNull(token, "Token no puede ser null");
        blacklist.put(token, expirationTime);
        log.debug("Token agregado a blacklist. Total: {}", blacklist.size());
    }

    /**
     * Verifica si un token está en la blacklist
     */
    public boolean isBlacklisted(String token) {
        if (token == null) {
            return true;
        }
        
        LocalDateTime expiration = blacklist.get(token);
        if (expiration == null) {
            return false;
        }
        
        // Si el token expiró, eliminar de la blacklist
        if (LocalDateTime.now().isAfter(expiration)) {
            blacklist.remove(token);
            return false;
        }
        
        return true;
    }

    /**
     * Limpia tokens expirados de la blacklist
     */
    public void cleanupExpired() {
        LocalDateTime now = LocalDateTime.now();
        blacklist.entrySet().removeIf(entry -> now.isAfter(entry.getValue()));
        log.debug("Blacklist limpiada. Tokens activos: {}", blacklist.size());
    }

    /**
     * Retorna la cantidad de tokens en blacklist
     */

    /**
     * Limpia toda la blacklist (para testing)
     */
    public void clear() {
        blacklist.clear();
        log.debug("Blacklist limpiada completamente");
    }
    public int getBlacklistSize() {
        return blacklist.size();
    }
}
