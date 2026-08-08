package com.investmenttracker.service;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.investmenttracker.component.LoginComponent;
import com.investmenttracker.component.SecurityLoginComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.request.RestartPasswordRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class RestartUserPasswordService {

    private final UserRepository userRepository;
    private final SecurityLoginComponent securityLoginComponent;
    private final LoginComponent loginComponent;

    @Transactional
    public SuccessResponse restartPassword(RestartPasswordRequest request, String adminUsername) {
        String nuevoPassword = Objects.requireNonNull(request.getNuevoPassword(), "nuevoPassword no puede ser null");
        String repetirPassword = Objects.requireNonNull(request.getRepetirNuevoPassword(),
                "repetirNuevoPassword no puede ser null");

        log.info("ADMIN {} - Procesando restablecimiento de contraseña para usuario: {}",
                adminUsername, request.getUsername());

        validateAdminRole(adminUsername);
        validateNotEmptyFields(request);
        validatePasswordsMatch(nuevoPassword, repetirPassword);
        validatePasswordCriteria(Objects.requireNonNull(nuevoPassword, "nuevoPassword no puede ser null"));

        User targetUser = findAndValidateUser(request);

        String encryptedPassword = securityLoginComponent
                .encryptPassword(Objects.requireNonNull(nuevoPassword, "nuevoPassword no puede ser null"));
        targetUser.setPasswordHash(Objects.requireNonNull(encryptedPassword, "encryptedPassword no puede ser null"));
        userRepository.save(targetUser);
        log.info("ADMIN {} - Contraseña actualizada para usuario: {}", adminUsername, targetUser.getUsername());

        // Resetear intentos fallidos del usuario objetivo
        loginComponent.resetFailedAttempts(targetUser);
        log.info("ADMIN {} - Intentos fallidos reseteados para usuario: {}", adminUsername, targetUser.getUsername());

        verifyPasswordUpdate(targetUser.getId(), nuevoPassword);

        log.info("ADMIN {} - Restablecimiento de contraseña exitoso para: {}",
                adminUsername, targetUser.getUsername());

        return SuccessResponse.builder()
                .code("BIZ-0001")
                .message("Contraseña actualizada exitosamente por administrador")
                .timestamp(LocalDateTime.now())
                .build();
    }

    private void validateAdminRole(String adminUsername) {
        User adminUser = userRepository.findByUsername(adminUsername)
                .orElseThrow(() -> new AccessDeniedException("Acceso denegado"));

        boolean isAdmin = adminUser.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equals(role.getNombre()));

        if (!isAdmin) {
            log.warn("Usuario {} intentó acceder a restart-password sin rol ADMIN", adminUsername);
            throw new AccessDeniedException("Se requiere rol ADMIN para esta operación");
        }

        log.debug("Rol ADMIN verificado para usuario: {}", adminUsername);
    }

    private void validateNotEmptyFields(RestartPasswordRequest request) {
        if (securityLoginComponent.hasEmptyFields(
                request.getUsername(),
                request.getEmail(),
                request.getNombreCompleto(),
                request.getNuevoPassword(),
                request.getRepetirNuevoPassword())) {
            throw new AuthenticationException(ErrorCode.EMPTY_FIELDS);
        }
    }

    private void validatePasswordsMatch(String password1, String password2) {
        if (!securityLoginComponent.passwordsMatch(password1, password2)) {
            throw new AuthenticationException(ErrorCode.PASSWORDS_DO_NOT_MATCH);
        }
    }

    private void validatePasswordCriteria(String password) {
        if (!securityLoginComponent.isValidPassword(password)) {
            throw new AuthenticationException(ErrorCode.PASSWORD_CRITERIA_NOT_MET);
        }
    }

    private User findAndValidateUser(RestartPasswordRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> {
                    log.warn("Usuario objetivo no encontrado: {}", request.getUsername());
                    return new AuthenticationException(ErrorCode.USER_NOT_FOUND);
                });

        String requestEmail = request.getEmail().toLowerCase().trim();
        String userEmail = user.getEmail().toLowerCase().trim();
        if (!requestEmail.equals(userEmail)) {
            log.warn("Email no coincide para usuario: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.USER_NOT_FOUND);
        }

        String requestNombre = request.getNombreCompleto().toLowerCase().trim();
        String userNombre = user.getNombreCompleto().toLowerCase().trim();
        if (!requestNombre.equals(userNombre)) {
            log.warn("Nombre no coincide para usuario: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.USER_NOT_FOUND);
        }

        return user;
    }

    private void verifyPasswordUpdate(UUID userId, String expectedPassword) {
        User updatedUser = userRepository.findById(Objects.requireNonNull(userId, "userId no puede ser null"))
                .orElseThrow(() -> new AuthenticationException(ErrorCode.UPDATE_VALIDATION_ERROR));

        if (!securityLoginComponent.verifyPassword(expectedPassword, updatedUser.getPasswordHash())) {
            log.error("La contraseña actualizada no coincide para usuario ID: {}", userId);
            throw new AuthenticationException(ErrorCode.UPDATE_VALIDATION_ERROR);
        }

        log.info("Verificación de contraseña exitosa para usuario ID: {}", userId);
    }
}
