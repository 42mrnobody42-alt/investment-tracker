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
import org.springframework.security.access.AccessDeniedException;
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
     * Solo permitido para usuarios autenticados con rol ADMIN
     */
    @Transactional
    public SuccessResponse restartPassword(RestartPasswordRequest request, String adminUsername) {
        log.info("ADMIN {} - Procesando restablecimiento de contraseña para usuario: {}", 
                 adminUsername, request.getUsername());
        
        // 0. Validar que quien ejecuta es ADMIN
        validateAdminRole(adminUsername);
        
        // 1. Validar campos no vacíos
        validateNotEmptyFields(request);
        
        // 2. Validar que las contraseñas coincidan
        validatePasswordsMatch(request.getNuevoPassword(), request.getRepetirNuevoPassword());
        
        // 3. Validar criterios de la contraseña
        validatePasswordCriteria(request.getNuevoPassword());
        
        // 4. Buscar y validar usuario objetivo
        User targetUser = findAndValidateUser(request);
        
        // 5. Encriptar y actualizar contraseña
        String encryptedPassword = securityLoginComponent.encryptPassword(request.getNuevoPassword());
        targetUser.setPasswordHash(encryptedPassword);
        userRepository.save(targetUser);
        log.info("ADMIN {} - Contraseña actualizada para usuario: {}", adminUsername, targetUser.getUsername());
        
        // 6. Verificar que se guardó correctamente
        verifyPasswordUpdate(targetUser.getId(), request.getNuevoPassword());
        
        log.info("ADMIN {} - Restablecimiento de contraseña exitoso para: {}", 
                 adminUsername, targetUser.getUsername());
        
        return SuccessResponse.builder()
            .code("BIZ-0001")
            .message("Contraseña actualizada exitosamente por administrador")
            .timestamp(LocalDateTime.now())
            .build();
    }

    /**
     * Valida que el admin autenticado tenga rol ADMIN
     */
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
     * Busca el usuario objetivo y valida sus datos
     */
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

    /**
     * Verifica que la contraseña se haya actualizado correctamente en la BD
     */
    private void verifyPasswordUpdate(java.util.UUID userId, String expectedPassword) {
        User updatedUser = userRepository.findById(userId)
            .orElseThrow(() -> new AuthenticationException(ErrorCode.UPDATE_VALIDATION_ERROR));
        
        if (!securityLoginComponent.verifyPassword(expectedPassword, updatedUser.getPasswordHash())) {
            log.error("La contraseña actualizada no coincide para usuario ID: {}", userId);
            throw new AuthenticationException(ErrorCode.UPDATE_VALIDATION_ERROR);
        }
        
        log.info("Verificación de contraseña exitosa para usuario ID: {}", userId);
    }
}
