package com.investmenttracker.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.dto.PaisDTO;
import com.investmenttracker.model.entity.Pais;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.response.ProfileResponse;
import com.investmenttracker.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class GetMyProfileService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public ProfileResponse getProfile(String authenticatedUsername) {
        log.info("Usuario {} - Consultando perfil propio", authenticatedUsername);

        User user = userRepository.findByUsernameIgnoreCase(authenticatedUsername)
                .orElseThrow(() -> {
                    log.warn("Usuario autenticado no encontrado en BD: {}", authenticatedUsername);
                    return new AuthenticationException(ErrorCode.USER_NOT_FOUND);
                });

        return buildProfileResponse(user);
    }

    static ProfileResponse buildProfileResponse(User user) {
        PaisDTO paisDTO = null;
        Pais pais = user.getPais();
        if (pais != null) {
            paisDTO = PaisDTO.builder()
                    .id(pais.getId())
                    .nombre(pais.getNombre())
                    .codigoIso(pais.getCodigoIso())
                    .indicativoCelular(pais.getIndicativoCelular())
                    .build();
        }

        return ProfileResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .nombreCompleto(user.getNombreCompleto())
                .celular(user.getCelular())
                .pais(paisDTO)
                .activo(user.getActivo())
                .ultimoLogin(user.getUltimoLogin())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
