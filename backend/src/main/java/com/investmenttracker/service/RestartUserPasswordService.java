package com.investmenttracker.service;

import com.investmenttracker.component.SecurityLoginComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.request.RestartPasswordRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class RestartUserPasswordService {

    private final UserRepository userRepository;
    private final SecurityLoginComponent securityLoginComponent;

    /**
     * Procesa el restablecimiento de contraseña
     */
    @Transactional
    public SuccessResponse restartPassword(RestartPasswordRequest request) {
        log.info("Procesando restablecimiento de contraseña para usuario: {}", request.getUsername());
        
        // 1. Validar campos no vacíos
        validateNotEmptyFields(request);
        
        // 2. Validar que las contraseñas coincidan
        validatePasswordsMatch(request.getNuevoPassword(), request.getRepetirNuevoPassword());
        
        // 3. Validar criterios de la contraseña
        validatePasswordCriteria(request.getNuevoPassword());
        
        // 4. Buscar y validar usuario (username, email, nombreCompleto)
        User user = findAndValidateUser(request);
        
        // 5. Encriptar y actualizar contraseña
        String encryptedPassword = securityLoginComponent.encryptPassword(request.getNuevoPassword());
        user.setPasswordHash(encryptedPassword);
        userRepository.save(user);
        log.info("Contraseña actualizada en BD para usuario: {}", request.getUsername());
        
        // 6. Verificar que se guardó correctamente
        verifyPasswordUpdate(user.getId(), request.getNuevoPassword());
        
        log.info("Restablecimiento de contraseña exitoso para usuario: {}", request.getUsername());
        
        return SuccessResponse.builder()
            .code("BIZ-0001")
            .message("Contraseña actualizada exitosamente")
            .timestamp(LocalDateTime.now())
            .build();
    }

    /**
     * Valida que ningún campo obligatorio esté vacío
     */
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

    /**
     * Valida que las contraseñas coincidan (caseSensitive)
     */
    private void validatePasswordsMatch(String password1, String password2) {
        if (!securityLoginComponent.passwordsMatch(password1, password2)) {
            throw new AuthenticationException(ErrorCode.PASSWORDS_DO_NOT_MATCH);
        }
    }

    /**
     * Valida que la contraseña cumpla con los criterios de seguridad
     */
    private void validatePasswordCriteria(String password) {
        if (!securityLoginComponent.isValidPassword(password)) {
            throw new AuthenticationException(ErrorCode.PASSWORD_CRITERIA_NOT_MET);
        }
    }

    /**
     * Busca el usuario y valida sus datos (username exacto, email y nombre ignorando mayúsculas)
     */
    private User findAndValidateUser(RestartPasswordRequest request) {
        // Buscar usuario por username exacto (caseSensitive)
        User user = userRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> {
                log.warn("Usuario no encontrado: {}", request.getUsername());
                return new AuthenticationException(ErrorCode.USER_NOT_FOUND);
            });
        
        // Validar email ignorando mayúsculas/minúsculas
        String requestEmail = request.getEmail().toLowerCase().trim();
        String userEmail = user.getEmail().toLowerCase().trim();
        if (!requestEmail.equals(userEmail)) {
            log.warn("Email no coincide para usuario: {} | Request: {} | BD: {}", 
                     request.getUsername(), requestEmail, userEmail);
            throw new AuthenticationException(ErrorCode.USER_NOT_FOUND);
        }
        
        // Validar nombre completo ignorando mayúsculas/minúsculas
        String requestNombre = request.getNombreCompleto().toLowerCase().trim();
        String userNombre = user.getNombreCompleto().toLowerCase().trim();
        if (!requestNombre.equals(userNombre)) {
            log.warn("Nombre completo no coincide para usuario: {} | Request: {} | BD: {}", 
                     request.getUsername(), requestNombre, userNombre);
            throw new AuthenticationException(ErrorCode.USER_NOT_FOUND);
        }
        
        log.debug("Usuario validado correctamente: {}", request.getUsername());
        return user;
    }

    /**
     * Verifica que la contraseña se haya actualizado correctamente en la BD
     */
    private void verifyPasswordUpdate(java.util.UUID userId, String expectedPassword) {
        User updatedUser = userRepository.findById(userId)
            .orElseThrow(() -> new AuthenticationException(ErrorCode.UPDATE_VALIDATION_ERROR));
        
        if (!securityLoginComponent.verifyPassword(expectedPassword, updatedUser.getPasswordHash())) {
            log.error("La contraseña actualizada no coincide con la esperada para usuario ID: {}", userId);
            throw new AuthenticationException(ErrorCode.UPDATE_VALIDATION_ERROR);
        }
        
        log.info("Verificación de contraseña exitosa para usuario ID: {}", userId);
    }
}
