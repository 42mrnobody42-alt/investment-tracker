package com.investmenttracker.service;

import com.investmenttracker.component.SecurityLoginComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.enums.SuccessfulCode;
import com.investmenttracker.model.request.PasswordRecoveryRequest;
import com.investmenttracker.model.request.TokenVerificationRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordRecoveryService {

    private final UserRepository userRepository;
    private final SecurityLoginComponent securityLoginComponent;
    private final EmailService emailService;

    @Value("${password-recovery.token-ttl-minutes}")
    private int tokenTtlMinutes;

    @Value("${password-recovery.max-attempts-per-hour}")
    private int maxAttemptsPerHour;

    @Value("${password-recovery.lock-duration-hours}")
    private int lockDurationHours;

    // Caché: username -> RecoveryAttempt
    private final Map<String, RecoveryAttempt> recoveryCache = new ConcurrentHashMap<>();

    /**
     * Paso 1: Solicitar recuperación - envía token por email
     */
    @Transactional
    public SuccessResponse requestRecovery(PasswordRecoveryRequest request) {
        validateNotEmptyFields(request);
        validateAttempts(request.getUsername());
        
        User user = findAndValidateUser(request);
        
        String token = generateToken();
        String userEmail = user.getEmail();
        
        // Guardar en caché
        recoveryCache.put(request.getUsername(), RecoveryAttempt.builder()
            .token(token)
            .expiresAt(LocalDateTime.now().plusMinutes(tokenTtlMinutes))
            .newPassword(request.getNuevoPassword())
            .attempts(1)
            .build());
        
        // Enviar correo
        try {
            emailService.sendRecoveryEmail(userEmail, user.getUsername(), token);
        } catch (Exception e) {
            recoveryCache.remove(request.getUsername());
            throw new AuthenticationException(ErrorCode.RECOVERY_EMAIL_SEND_ERROR);
        }
        
        log.info("Token de recuperación enviado a: {}", userEmail);
        
        return SuccessResponse.builder()
            .code(SuccessfulCode.RECOVERY_EMAIL_SENT.getCode())
            .message(SuccessfulCode.RECOVERY_EMAIL_SENT.getMessage())
            .timestamp(LocalDateTime.now())
            .build();
    }

    /**
     * Paso 2: Verificar token y cambiar contraseña
     */
    @Transactional
    public SuccessResponse verifyTokenAndChangePassword(TokenVerificationRequest request) {
        validateTokenRequestFields(request);
        
        RecoveryAttempt attempt = recoveryCache.get(request.getUsername());
        
        if (attempt == null) {
            throw new AuthenticationException(ErrorCode.RECOVERY_TOKEN_EXPIRED);
        }
        
        // Validar expiración
        if (LocalDateTime.now().isAfter(attempt.getExpiresAt())) {
            recoveryCache.remove(request.getUsername());
            throw new AuthenticationException(ErrorCode.RECOVERY_TOKEN_EXPIRED);
        }
        
        // Validar token
        if (!attempt.getToken().equals(request.getToken())) {
            recoveryCache.remove(request.getUsername());
            throw new AuthenticationException(ErrorCode.RECOVERY_TOKEN_INVALID);
        }
        
        // Validar usuario y email
        User user = userRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> new AuthenticationException(ErrorCode.USER_NOT_FOUND));
        
        if (!user.getEmail().equalsIgnoreCase(request.getEmail())) {
            throw new AuthenticationException(ErrorCode.RECOVERY_USER_MISMATCH);
        }
        
        // Cambiar contraseña
        String encryptedPassword = securityLoginComponent.encryptPassword(attempt.getNewPassword());
        user.setPasswordHash(encryptedPassword);
        userRepository.save(user);
        
        // Limpiar caché
        recoveryCache.remove(request.getUsername());
        
        log.info("Contraseña actualizada para usuario: {}", user.getUsername());
        
        return SuccessResponse.builder()
            .code(SuccessfulCode.RECOVERY_PASSWORD_CHANGED.getCode())
            .message(SuccessfulCode.RECOVERY_PASSWORD_CHANGED.getMessage())
            .timestamp(LocalDateTime.now())
            .build();
    }

    private void validateNotEmptyFields(PasswordRecoveryRequest request) {
        if (request.getUsername() == null || request.getUsername().trim().isEmpty() ||
            request.getEmail() == null || request.getEmail().trim().isEmpty() ||
            request.getNuevoPassword() == null || request.getNuevoPassword().trim().isEmpty()) {
            throw new AuthenticationException(ErrorCode.EMPTY_FIELDS);
        }
    }

    private void validateTokenRequestFields(TokenVerificationRequest request) {
        if (request.getUsername() == null || request.getUsername().trim().isEmpty() ||
            request.getEmail() == null || request.getEmail().trim().isEmpty() ||
            request.getToken() == null || request.getToken().trim().isEmpty() ||
            request.getNuevoPassword() == null || request.getNuevoPassword().trim().isEmpty()) {
            throw new AuthenticationException(ErrorCode.EMPTY_FIELDS);
        }
    }

    private void validateAttempts(String username) {
        RecoveryAttempt attempt = recoveryCache.get(username);
        if (attempt != null && attempt.getAttempts() >= maxAttemptsPerHour) {
            throw new AuthenticationException(ErrorCode.RECOVERY_MAX_ATTEMPTS_EXCEEDED);
        }
    }

    private User findAndValidateUser(PasswordRecoveryRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> new AuthenticationException(ErrorCode.RECOVERY_USER_MISMATCH));
        
        if (!user.getEmail().equalsIgnoreCase(request.getEmail())) {
            throw new AuthenticationException(ErrorCode.RECOVERY_USER_MISMATCH);
        }
        
        return user;
    }

    /**
     * SOLO PARA TESTING - Obtener token actual del caché
     */
    public String getTokenForTest(String username) {
        RecoveryAttempt attempt = recoveryCache.get(username);
        return attempt != null ? attempt.getToken() : null;
    }

    private String generateToken() {
        SecureRandom random = new SecureRandom();
        int token = random.nextInt(900000) + 100000; // 6 dígitos
        return String.valueOf(token);
    }

    // Clase interna
    @lombok.Builder
    @lombok.Data
    private static class RecoveryAttempt {
        private String token;
        private LocalDateTime expiresAt;
        private String newPassword;
        private int attempts;
    }
}
