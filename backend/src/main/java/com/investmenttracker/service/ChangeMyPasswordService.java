package com.investmenttracker.service;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.investmenttracker.component.LoginComponent;
import com.investmenttracker.component.SecurityLoginComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.enums.SuccessfulCode;
import com.investmenttracker.model.request.ChangePasswordRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChangeMyPasswordService {

    private final UserRepository userRepository;
    private final SecurityLoginComponent securityLoginComponent;
    private final LoginComponent loginComponent;

    @Transactional
    public SuccessResponse changePassword(ChangePasswordRequest request, String authenticatedUsername) {
        log.info("Usuario {} - Procesando cambio de contraseña propia", authenticatedUsername);

        // 1. Validar campos no vacíos
        validateNotEmptyFields(request);

        // 2. Buscar usuario
        User user = findAndValidateUser(request);

        // 3. Validar que el username autenticado coincida con el de la petición
        validateUsernameMatch(request, authenticatedUsername);

        // 4. Validar email
        validateEmail(request, user);

        // 5. Validar contraseña actual
        validateCurrentPassword(request, user);

        // 6. Validar que las contraseñas nuevas coincidan
        validateNewPasswordsMatch(request);

        // 7. Validar criterios de la nueva contraseña
        validatePasswordCriteria(request);

        // 8. Validar que la nueva contraseña NO sea igual a la actual
        validateNewPasswordDifferent(request, user);

        // 9. Encriptar y actualizar
        String newPassword = Objects.requireNonNull(request.getNuevoPassword(), "nuevoPassword no puede ser null");
        String encryptedPassword = securityLoginComponent.encryptPassword(newPassword);
        user.setPasswordHash(Objects.requireNonNull(encryptedPassword, "encryptedPassword no puede ser null"));
        userRepository.save(user);
        log.info("Usuario {} - Contraseña actualizada en BD", authenticatedUsername);

        // 10. Resetear intentos fallidos
        loginComponent.resetFailedAttempts(user);

        // 11. Verificar actualización
        verifyPasswordUpdate(user.getId(), newPassword);

        log.info("Usuario {} - Cambio de contraseña exitoso", authenticatedUsername);

        return SuccessResponse.builder()
                .code(SuccessfulCode.PASSWORD_CHANGED.getCode())
                .message(SuccessfulCode.PASSWORD_CHANGED.getMessage())
                .timestamp(LocalDateTime.now())
                .build();
    }

    private void validateUsernameMatch(ChangePasswordRequest request, String authenticatedUsername) {
        if (authenticatedUsername == null || !authenticatedUsername.equals(request.getUsername())) {
            log.warn("Usuario autenticado '{}' intentó cambiar contraseña de '{}'",
                    authenticatedUsername, request.getUsername());
            throw new AuthenticationException(ErrorCode.INVALID_CREDENTIALS,
                    "No puedes cambiar la contraseña de otro usuario");
        }
    }

    private void validateNotEmptyFields(ChangePasswordRequest request) {
        if (request.getUsername() == null || request.getUsername().trim().isEmpty() ||
                request.getEmail() == null || request.getEmail().trim().isEmpty() ||
                request.getActualPassword() == null || request.getActualPassword().trim().isEmpty() ||
                request.getNuevoPassword() == null || request.getNuevoPassword().trim().isEmpty() ||
                request.getRepetirNuevoPassword() == null || request.getRepetirNuevoPassword().trim().isEmpty()) {
            throw new AuthenticationException(ErrorCode.EMPTY_FIELDS);
        }
    }

    private User findAndValidateUser(ChangePasswordRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> {
                    log.warn("Usuario no encontrado: {}", request.getUsername());
                    return new AuthenticationException(ErrorCode.USER_NOT_FOUND);
                });

        if (!user.getActivo()) {
            log.warn("Usuario deshabilitado: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.ACCOUNT_DISABLED);
        }

        return user;
    }

    private void validateEmail(ChangePasswordRequest request, User user) {
        String requestEmail = request.getEmail().toLowerCase().trim();
        String userEmail = user.getEmail().toLowerCase().trim();
        if (!requestEmail.equals(userEmail)) {
            log.warn("Email no coincide para usuario: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.INVALID_CREDENTIALS,
                    "El email no coincide con el registrado");
        }
    }

    private void validateCurrentPassword(ChangePasswordRequest request, User user) {
        String actualPassword = Objects.requireNonNull(request.getActualPassword(), "actualPassword no puede ser null");
        if (!securityLoginComponent.verifyPassword(actualPassword, user.getPasswordHash())) {
            log.warn("Contraseña actual incorrecta para usuario: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.CURRENT_PASSWORD_INCORRECT);
        }
    }

    private void validateNewPasswordsMatch(ChangePasswordRequest request) {
        String nuevoPassword = Objects.requireNonNull(request.getNuevoPassword(), "nuevoPassword no puede ser null");
        String repetirPassword = Objects.requireNonNull(request.getRepetirNuevoPassword(),
                "repetirNuevoPassword no puede ser null");
        if (!securityLoginComponent.passwordsMatch(nuevoPassword, repetirPassword)) {
            throw new AuthenticationException(ErrorCode.PASSWORDS_DO_NOT_MATCH);
        }
    }

    private void validatePasswordCriteria(ChangePasswordRequest request) {
        String nuevoPassword = Objects.requireNonNull(request.getNuevoPassword(), "nuevoPassword no puede ser null");
        if (!securityLoginComponent.isValidPassword(nuevoPassword)) {
            throw new AuthenticationException(ErrorCode.PASSWORD_CRITERIA_NOT_MET,
                    "La contraseña debe tener al menos 8 caracteres, 1 mayúscula, 1 carácter especial. Sin comillas.");
        }
    }

    private void validateNewPasswordDifferent(ChangePasswordRequest request, User user) {
        String nuevoPassword = Objects.requireNonNull(request.getNuevoPassword(), "nuevoPassword no puede ser null");
        if (securityLoginComponent.verifyPassword(nuevoPassword, user.getPasswordHash())) {
            log.warn("La nueva contraseña es igual a la actual para usuario: {}", request.getUsername());
            throw new AuthenticationException(ErrorCode.SAME_PASSWORD);
        }
    }

    private void verifyPasswordUpdate(UUID userId, String expectedPassword) {
        User updatedUser = userRepository.findById(Objects.requireNonNull(userId, "userId no puede ser null"))
                .orElseThrow(() -> new AuthenticationException(ErrorCode.UPDATE_VALIDATION_ERROR));

        if (!securityLoginComponent.verifyPassword(expectedPassword, updatedUser.getPasswordHash())) {
            log.error("La contraseña actualizada no coincide para usuario ID: {}", userId);
            throw new AuthenticationException(ErrorCode.UPDATE_VALIDATION_ERROR);
        }
    }
}
