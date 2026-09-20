package com.investmenttracker.service;

import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.Pais;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.enums.SuccessfulCode;
import com.investmenttracker.model.request.UpdateMyProfileRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.PaisRepository;
import com.investmenttracker.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class UpdateMyProfileService {

    private final UserRepository userRepository;
    private final PaisRepository paisRepository;

    @Transactional
    public SuccessResponse updateProfile(UpdateMyProfileRequest request, String authenticatedUsername) {
        log.info("Usuario {} - Procesando actualización de perfil propio", authenticatedUsername);

        // 1. Validar campos obligatorios (defensa en profundidad; @Valid ya lo hace)
        validateNotEmptyFields(request);

        String requestUsername = Objects.requireNonNull(
                request.getUsername(), "username no puede ser null");
        UUID requestId = Objects.requireNonNull(
                request.getId(), "id no puede ser null");
        UUID requestPaisId = Objects.requireNonNull(
                request.getPaisId(), "paisId no puede ser null");
        Long requestCelular = Objects.requireNonNull(
                request.getCelular(), "celular no puede ser null");
        String requestEmail = Objects.requireNonNull(
                request.getEmail(), "email no puede ser null");
        String requestNombre = Objects.requireNonNull(
                request.getNombreCompleto(), "nombreCompleto no puede ser null");

        // 2. Buscar usuario por username del request
        User user = userRepository.findByUsernameIgnoreCase(requestUsername)
                .orElseThrow(() -> {
                    log.warn("Usuario objetivo no encontrado: {}", requestUsername);
                    return new AuthenticationException(ErrorCode.USER_NOT_FOUND);
                });

        // 3. Validar que el username del JWT coincida con el usuario objetivo
        if (!authenticatedUsername.equals(user.getUsername())) {
            log.warn("Usuario autenticado '{}' intentó actualizar a '{}'",
                    authenticatedUsername, requestUsername);
            throw new AuthenticationException(ErrorCode.ACCESS_DENIED,
                    "No puedes actualizar el perfil de otro usuario");
        }

        // 4. Validar que el id coincida con el del usuario autenticado
        if (!Objects.equals(user.getId(), requestId)) {
            log.warn("El id '{}' no coincide con el usuario autenticado '{}'",
                    requestId, authenticatedUsername);
            throw new AuthenticationException(ErrorCode.ACCESS_DENIED,
                    "El id no coincide con el usuario autenticado");
        }

        // 5. Validar que el usuario esté activo
        if (!Boolean.TRUE.equals(user.getActivo())) {
            log.warn("Usuario deshabilitado: {}", authenticatedUsername);
            throw new AuthenticationException(ErrorCode.ACCOUNT_DISABLED);
        }

        // 6. Validar unicidad de email (solo si cambia; comparación case-insensitive)
        validateEmailUniqueness(requestEmail, user.getEmail());

        // 7. Validar unicidad de (paisId, celular) (solo si cambia)
        validatePaisCelularUniqueness(requestPaisId, requestCelular, user);

        // 8. Validar que el país exista y esté activo
        Pais pais = paisRepository.findById(requestPaisId)
                .orElseThrow(() -> new AuthenticationException(ErrorCode.PAIS_NOT_FOUND));
        if (!Boolean.TRUE.equals(pais.getActivo())) {
            throw new AuthenticationException(ErrorCode.PAIS_NOT_FOUND,
                    "El país seleccionado no está activo");
        }

        // 9. Actualizar campos editables.
        //    El email se guarda TAL CUAL se envía (solo trim), preservando el case original.
        String emailToSave = Objects.requireNonNull(requestEmail.trim(), "email no puede ser null");
        String nombreToSave = Objects.requireNonNull(requestNombre.trim(), "nombreCompleto no puede ser null");

        user.setEmail(emailToSave);
        user.setNombreCompleto(nombreToSave);
        user.setCelular(requestCelular);
        user.setPais(pais);
        userRepository.save(user);

        log.info("Usuario {} - Perfil actualizado exitosamente", authenticatedUsername);

        return SuccessResponse.builder()
                .code(SuccessfulCode.UPDATE_USER_DATA.getCode())
                .message(SuccessfulCode.UPDATE_USER_DATA.getMessage())
                .timestamp(LocalDateTime.now())
                .build();
    }

    private void validateNotEmptyFields(UpdateMyProfileRequest request) {
        if (request.getId() == null ||
                request.getUsername() == null || request.getUsername().trim().isEmpty() ||
                request.getEmail() == null || request.getEmail().trim().isEmpty() ||
                request.getNombreCompleto() == null || request.getNombreCompleto().trim().isEmpty() ||
                request.getPaisId() == null ||
                request.getCelular() == null) {
            throw new AuthenticationException(ErrorCode.EMPTY_FIELDS);
        }
    }

    /**
     * Valida que el nuevo email no esté en uso por otro usuario.
     * La comparación es case-insensitive tanto para "mismo email" como
     * para la búsqueda en BD. El valor se guardará después tal cual.
     */
    private void validateEmailUniqueness(String newEmail, String currentEmail) {
        String trimmedNew = Objects.requireNonNull(newEmail, "newEmail no puede ser null").trim();
        String trimmedCurrent = Objects.requireNonNull(currentEmail, "currentEmail no puede ser null").trim();

        if (trimmedNew.equalsIgnoreCase(trimmedCurrent)) {
            return;
        }

        if (userRepository.findByEmailIgnoreCase(trimmedNew).isPresent()) {
            log.warn("Email ya registrado (case-insensitive): {}", trimmedNew);
            throw new AuthenticationException(ErrorCode.REGISTRATION_EMAIL_EXISTS);
        }
    }

    /**
     * Valida que la combinación (paisId, celular) no esté en uso por otro usuario.
     * Si ninguno cambió, se omite la validación.
     */
    private void validatePaisCelularUniqueness(UUID newPaisId, Long newCelular, User currentUser) {
        UUID currentPaisId = currentUser.getPais() != null ? currentUser.getPais().getId() : null;
        Long currentCelular = currentUser.getCelular();

        boolean paisChanged = !Objects.equals(newPaisId, currentPaisId);
        boolean celularChanged = !Objects.equals(newCelular, currentCelular);

        if (!paisChanged && !celularChanged) {
            return;
        }

        if (userRepository.existsByPaisIdAndCelular(newPaisId, newCelular)) {
            log.warn("Combinación (paisId={}, celular={}) ya registrada", newPaisId, newCelular);
            throw new AuthenticationException(ErrorCode.REGISTRATION_PAIS_CELULAR_EXISTS);
        }
    }
}
