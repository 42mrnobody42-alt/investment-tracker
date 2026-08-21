package com.investmenttracker.component;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class RateLimitComponent {

    // Mapa: clave (IP:endpoint) -> intentos
    private final Map<String, RateLimitEntry> rateLimitMap = new ConcurrentHashMap<>();

    /**
     * Verifica si la petición está dentro del límite permitido
     * @return true si está permitido, false si está bloqueado
     */
    public boolean isAllowed(String key, int maxRequests, int windowSeconds) {
        RateLimitEntry entry = rateLimitMap.computeIfAbsent(key, k -> new RateLimitEntry());
        
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime windowStart = now.minusSeconds(windowSeconds);
        
        // Limpiar intentos fuera de la ventana
        entry.removeOldAttempts(windowStart);
        
        if (entry.getAttemptCount() >= maxRequests) {
            log.warn("Rate limit excedido para: {} ({} intentos en {} segundos)", 
                     key, entry.getAttemptCount(), windowSeconds);
            return false;
        }
        
        entry.addAttempt(now);
        return true;
    }

    /**
     * Obtiene el tiempo restante de bloqueo en segundos
     */
    public long getBlockRemainingSeconds(String key) {
        RateLimitEntry entry = rateLimitMap.get(key);
        if (entry == null || entry.getAttempts().isEmpty()) {
            return 0;
        }
        
        LocalDateTime oldestAttempt = entry.getAttempts().get(0);
        return Math.max(0, java.time.Duration.between(
            LocalDateTime.now(), oldestAttempt.plusSeconds(60)).getSeconds());
    }

    /**
     * Limpia todas las entradas (para testing)
     */
    public void clear() {
        rateLimitMap.clear();
        log.debug("Rate limit limpiado completamente");
    }

    /**
     * Obtiene el número de entradas activas
     */
    public int getActiveEntries() {
        return rateLimitMap.size();
    }

    /**
     * Clase interna para almacenar intentos
     */
    private static class RateLimitEntry {
        private final java.util.List<LocalDateTime> attempts = 
            new java.util.concurrent.CopyOnWriteArrayList<>();

        public void addAttempt(LocalDateTime time) {
            attempts.add(time);
        }

        public void removeOldAttempts(LocalDateTime windowStart) {
            attempts.removeIf(attempt -> attempt.isBefore(windowStart));
        }

        public int getAttemptCount() {
            return attempts.size();
        }

        public java.util.List<LocalDateTime> getAttempts() {
            return attempts;
        }
    }
}
