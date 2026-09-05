package com.investmenttracker.service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.investmenttracker.component.SecurityLoginComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.Role;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.enums.Plan;
import com.investmenttracker.model.enums.SuccessfulCode;
import com.investmenttracker.model.request.RegisterConfirmRequest;
import com.investmenttracker.model.request.RegisterRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.PaisRepository;
import com.investmenttracker.repository.RoleRepository;
import com.investmenttracker.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class RegisterService {

    private final UserRepository userRepository;
    private final PaisRepository paisRepository;
    private final RoleRepository roleRepository;
    private final SecurityLoginComponent securityLoginComponent;
    private final EmailService emailService;

    private final Map<String, RegistrationAttempt> registrationCache = new ConcurrentHashMap<>();
    private static final int TOKEN_TTL_MINUTES = 5;

    /**
     * Paso 1: Solicitar registro - validaciones y envío de token por email
     */
    public SuccessResponse requestRegistration(RegisterRequest request) {
        validateNotEmptyFields(request);

        // 1. Validar que las contraseñas coincidan
        validatePasswordsMatch(request.getPassword(), request.getRepeatPassword());

        // 2. Validar criterios de la contraseña
        validatePasswordCriteria(request.getPassword());

        // 3. Validar unicidad de username, email, y (pais_id, celular)
        validateUniqueness(request);

        // 4. Validar que el país exista
        UUID paisId = Objects.requireNonNull(request.getPaisId(), "paisId no puede ser null");
        if (!paisRepository.existsById(paisId)) {
            throw new AuthenticationException(ErrorCode.PAIS_NOT_FOUND);
        }
        log.debug("País validado con ID: {}", paisId);

        // 5. Generar token y guardar en caché
        String token = generateToken();
        registrationCache.put(request.getUsername(), RegistrationAttempt.builder()
                .email(request.getEmail())
                .nombreCompleto(request.getNombreCompleto())
                .password(request.getPassword())
                .celular(request.getCelular())
                .paisId(paisId)
                .plan(request.getPlan())
                .token(token)
                .expiresAt(LocalDateTime.now().plusMinutes(TOKEN_TTL_MINUTES))
                .build());

        // 6. Enviar correo de confirmación
        try {
            emailService.sendRegistrationEmail(request.getEmail(), request.getUsername(), token);
        } catch (Exception e) {
            registrationCache.remove(request.getUsername());
            throw new AuthenticationException(ErrorCode.RECOVERY_EMAIL_SEND_ERROR);
        }

        log.info("Correo de confirmación enviado a: {}", request.getEmail());

        return SuccessResponse.builder()
                .code(SuccessfulCode.REGISTRATION_EMAIL_SENT.getCode())
                .message(SuccessfulCode.REGISTRATION_EMAIL_SENT.getMessage())
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * Paso 2: Confirmar registro - verificar token y crear usuario
     */
    @Transactional
    public SuccessResponse confirmRegistration(RegisterConfirmRequest request) {
        log.debug("Iniciando confirmación para usuario: {}", request.getUsername());
        validateConfirmFields(request);

        RegistrationAttempt attempt = registrationCache.get(request.getUsername());
        if (attempt == null) {
            log.warn("No se encontró intento de registro para: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.REGISTRATION_TOKEN_EXPIRED);
        }
        log.debug("Intento encontrado para: {}", request.getUsername());

        if (LocalDateTime.now().isAfter(attempt.getExpiresAt())) {
            registrationCache.remove(request.getUsername());
            log.warn("Token expirado para: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.REGISTRATION_TOKEN_EXPIRED);
        }

        if (!attempt.getToken().equals(request.getToken())) {
            registrationCache.remove(request.getUsername());
            log.warn("Token inválido para: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.REGISTRATION_TOKEN_INVALID);
        }

        if (!attempt.getEmail().equalsIgnoreCase(request.getEmail()) ||
                !attempt.getCelular().equals(request.getCelular()) ||
                !attempt.getPaisId().equals(request.getPaisId()) ||
                attempt.getPlan() != request.getPlan()) {
            registrationCache.remove(request.getUsername());
            log.warn("Datos no coinciden para: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.REGISTRATION_CONFIRM_MISMATCH);
        }

        log.debug("Validando unicidad para: {}", request.getUsername());
        validateUniqueness(request.getUsername(), request.getEmail(), request.getPaisId(), request.getCelular());

        log.debug("Creando usuario para: {}", request.getUsername());
        User newUser = createUser(request, attempt);

        registrationCache.remove(request.getUsername());

        log.info("Usuario registrado exitosamente: {}", newUser.getUsername());

        return SuccessResponse.builder()
                .code(SuccessfulCode.REGISTRATION_COMPLETED.getCode())
                .message(SuccessfulCode.REGISTRATION_COMPLETED.getMessage())
                .timestamp(LocalDateTime.now())
                .build();
    }

    /**
     * Borrado lógico de cuenta (cambiar activo = false)
     */
    @Transactional
    public SuccessResponse deleteAccount(String username) {
        User user = userRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new AuthenticationException(ErrorCode.USER_NOT_FOUND));

        user.setActivo(false);
        userRepository.save(user);

        log.info("Cuenta desactivada para usuario: {}", username);

        return SuccessResponse.builder()
                .code(SuccessfulCode.ACCOUNT_DELETED.getCode())
                .message(SuccessfulCode.ACCOUNT_DELETED.getMessage())
                .timestamp(LocalDateTime.now())
                .build();
    }

    // ============ VALIDACIONES PRIVADAS ============

    private void validateNotEmptyFields(RegisterRequest request) {
        if (request.getUsername() == null || request.getUsername().trim().isEmpty() ||
                request.getEmail() == null || request.getEmail().trim().isEmpty() ||
                request.getPassword() == null || request.getPassword().trim().isEmpty() ||
                request.getRepeatPassword() == null || request.getRepeatPassword().trim().isEmpty() ||
                request.getCelular() == null ||
                request.getPaisId() == null ||
                request.getPlan() == null) {
            throw new AuthenticationException(ErrorCode.EMPTY_FIELDS);
        }
    }

    private void validateConfirmFields(RegisterConfirmRequest request) {
        if (request.getUsername() == null || request.getUsername().trim().isEmpty() ||
                request.getEmail() == null || request.getEmail().trim().isEmpty() ||
                request.getToken() == null || request.getToken().trim().isEmpty() ||
                request.getCelular() == null ||
                request.getPaisId() == null ||
                request.getPlan() == null) {
            throw new AuthenticationException(ErrorCode.EMPTY_FIELDS);
        }
    }

    private void validatePasswordsMatch(String password, String repeatPassword) {
        if (!securityLoginComponent.passwordsMatch(password, repeatPassword)) {
            throw new AuthenticationException(ErrorCode.REGISTRATION_PASSWORD_DOES_NOT_MATCH);
        }
    }

    private void validatePasswordCriteria(String password) {
        if (!securityLoginComponent.isValidPassword(password)) {
            throw new AuthenticationException(ErrorCode.PASSWORD_CRITERIA_NOT_MET);
        }
    }

    private void validateUniqueness(RegisterRequest request) {
        validateUniqueness(request.getUsername(), request.getEmail(), request.getPaisId(), request.getCelular());
    }

    private void validateUniqueness(String username, String email, UUID paisId, Long celular) {
        // Username
        if (userRepository.existsByUsername(username)) {
            throw new AuthenticationException(ErrorCode.REGISTRATION_USERNAME_EXISTS);
        }

        // Email (case-insensitive: lower)
        if (userRepository.findByEmailIgnoreCase(email).isPresent()) {
            throw new AuthenticationException(ErrorCode.REGISTRATION_EMAIL_EXISTS);
        }

        // (pais_id, celular)
        if (userRepository.existsByPaisIdAndCelular(paisId, celular)) {
            throw new AuthenticationException(ErrorCode.REGISTRATION_PAIS_CELULAR_EXISTS);
        }
    }

    @SuppressWarnings("null")
    private User createUser(RegisterConfirmRequest request, RegistrationAttempt attempt) {
        String roleName = request.getPlan().getRoleName();
        Role role = roleRepository.findByNombre(roleName)
                .orElseThrow(() -> {
                    log.error("Rol no encontrado: {}", roleName);
                    return new AuthenticationException(ErrorCode.INTERNAL_ERROR);
                });

        String encryptedPassword = securityLoginComponent.encryptPassword(attempt.getPassword());

        String username = Objects.requireNonNull(request.getUsername(), "username no puede ser null");
        String email = Objects.requireNonNull(request.getEmail(), "email no puede ser null").toLowerCase().trim();
        String nombreCompleto = Objects.requireNonNull(attempt.getNombreCompleto(), "nombreCompleto no puede ser null");
        Long celular = Objects.requireNonNull(request.getCelular(), "celular no puede ser null");
        UUID paisId = Objects.requireNonNull(request.getPaisId(), "paisId no puede ser null");

        User user = User.builder()
                .username(username)
                .passwordHash(encryptedPassword)
                .email(email)
                .nombreCompleto(nombreCompleto)
                .celular(celular)
                .pais(paisRepository.getReferenceById(paisId))
                .activo(true)
                .build();

        user.getRoles().add(role);

        try {
            return Objects.requireNonNull(userRepository.save(user), "El usuario guardado no puede ser null");
        } catch (Exception e) {
            log.error("Error al guardar usuario en BD: {}", e.getMessage(), e);
            throw e;
        }
    }

    /**
     * Borrado definitivo (SOLO PARA PRUEBAS) - elimina usuario y todas sus
     * dependencias en cascada
     */
    @SuppressWarnings("null")
    @Transactional
    public void deleteUserPermanently(String username) {
        User user = userRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new AuthenticationException(ErrorCode.USER_NOT_FOUND));
        userRepository.delete(user);
        log.info("Usuario eliminado definitivamente (cascada): {}", username);
    }

    /**
     * SOLO PARA TESTING - Obtener token actual del caché
     */
    public String getTokenForTest(String username) {
        RegistrationAttempt attempt = registrationCache.get(username);
        return attempt != null ? attempt.getToken() : null;
    }

    private String generateToken() {
        SecureRandom random = new SecureRandom();
        int token = random.nextInt(900000) + 100000;
        return String.valueOf(token);
    }

    // ============ INNER CLASS ============

    @lombok.Builder
    @lombok.Data
    private static class RegistrationAttempt {
        private String email;
        private String nombreCompleto; // <-- Agregar esta línea
        private String password;
        private Long celular;
        private UUID paisId;
        private Plan plan;
        private String token;
        private LocalDateTime expiresAt;
    }
}
