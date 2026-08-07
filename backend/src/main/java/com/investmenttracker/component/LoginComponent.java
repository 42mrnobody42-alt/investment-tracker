package com.investmenttracker.component;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.LockLevel;
import com.investmenttracker.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Component
@RequiredArgsConstructor
@Slf4j
public class LoginComponent {

    private final UserRepository userRepository;

    // Caché en memoria para control de intentos fallidos
    private final Map<String, LoginAttempt> attemptsCache = new ConcurrentHashMap<>();

    /**
     * Busca un usuario por username
     */
    @Transactional(readOnly = true)
    public Optional<User> findUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    /**
     * Verifica si el usuario está bloqueado (en caché)
     */
    public boolean isUserLocked(String username) {
        LoginAttempt attempt = attemptsCache.get(username);
        if (attempt == null) {
            return false;
        }

        // Verificar bloqueo permanente
        if (attempt.getLockLevel() == LockLevel.PERMANENT) {
            return true;
        }

        // Verificar bloqueo temporal
        if (attempt.getLockedUntil() != null) {
            if (LocalDateTime.now().isBefore(attempt.getLockedUntil())) {
                return true;
            }
            // Bloqueo expirado, limpiar
            attemptsCache.remove(username);
        }

        return false;
    }

    /**
     * Verifica si el usuario está deshabilitado (en DB)
     */
    @Transactional(readOnly = true)
    public boolean isUserDisabled(String username) {
        return userRepository.findByUsername(username)
                .map(user -> !user.getActivo())
                .orElse(false);
    }

    /**
     * Registra un intento fallido
     */
    public void recordFailedAttempt(String username) {
        LoginAttempt attempt = attemptsCache.computeIfAbsent(username, k -> new LoginAttempt());
        attempt.incrementFailedAttempts();

        log.debug("Usuario {} - Intento fallido {}/3", username, attempt.getFailedAttempts());

        if (attempt.getFailedAttempts() >= 3) {
            applyLock(username, attempt);
        }
    }

    /**
     * Resetea intentos fallidos después de login exitoso
     */
    @Transactional
    public void resetFailedAttempts(User user) {
        attemptsCache.remove(user.getUsername());
        user.setUltimoLogin(LocalDateTime.now());
        userRepository.save(user);
        log.debug("Intentos reseteados para usuario {}", user.getUsername());
    }

    /**
     * Aplica bloqueo progresivo
     */
    private void applyLock(String username, LoginAttempt attempt) {
        LockLevel currentLevel = attempt.getLockLevel();
        LockLevel nextLevel = currentLevel.next();

        attempt.setLockLevel(nextLevel);
        attempt.setFailedAttempts(0);

        if (nextLevel == LockLevel.PERMANENT) {
            attempt.setLockedUntil(null);
            // Deshabilitar usuario en DB
            userRepository.findByUsername(username).ifPresent(user -> {
                user.setActivo(false);
                userRepository.save(user);
            });
            log.warn("Usuario {} bloqueado PERMANENTEMENTE", username);
        } else {
            attempt.setLockedUntil(LocalDateTime.now().plusMinutes(nextLevel.getDurationMinutes()));
            log.warn("Usuario {} bloqueado por {} minutos (nivel {})",
                    username, nextLevel.getDurationMinutes(), nextLevel.getLevel());
        }
    }

    /**
     * Obtiene información del bloqueo actual
     */
    public LockInfo getLockInfo(String username) {
        LoginAttempt attempt = attemptsCache.get(username);

        if (attempt != null && attempt.getLockedUntil() != null
                && LocalDateTime.now().isBefore(attempt.getLockedUntil())) {
            long secondsRemaining = java.time.Duration.between(
                    LocalDateTime.now(), attempt.getLockedUntil()).getSeconds();
            return new LockInfo(true, secondsRemaining, 0);
        }

        int remainingAttempts = 3;
        if (attempt != null) {
            remainingAttempts = Math.max(0, 3 - attempt.getFailedAttempts());
        }

        return new LockInfo(false, 0, remainingAttempts);
    }

    /**
     * Clase interna para almacenar intentos en caché
     */
    private static class LoginAttempt {
        private int failedAttempts = 0;
        private LockLevel lockLevel = LockLevel.NONE;
        private LocalDateTime lockedUntil;

        public int getFailedAttempts() {
            return failedAttempts;
        }

        public void setFailedAttempts(int failedAttempts) {
            this.failedAttempts = failedAttempts;
        }

        public void incrementFailedAttempts() {
            this.failedAttempts++;
        }

        public LockLevel getLockLevel() {
            return lockLevel;
        }

        public void setLockLevel(LockLevel lockLevel) {
            this.lockLevel = lockLevel;
        }

        public LocalDateTime getLockedUntil() {
            return lockedUntil;
        }

        public void setLockedUntil(LocalDateTime lockedUntil) {
            this.lockedUntil = lockedUntil;
        }
    }

    /**
     * Clase interna para información de bloqueo
     */
    public record LockInfo(boolean locked, long lockedUntilSeconds, int remainingAttempts) {
    }
}
