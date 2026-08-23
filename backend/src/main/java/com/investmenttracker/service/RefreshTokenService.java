package com.investmenttracker.service;

import com.investmenttracker.component.RefreshTokenComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.response.LoginResponse;
import com.investmenttracker.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Objects;

@Service
@RequiredArgsConstructor
@Slf4j
public class RefreshTokenService {

    private final RefreshTokenComponent refreshTokenComponent;
    private final JwtService jwtService;
    private final UserRepository userRepository;

    /**
     * Refresca el access token usando el refresh token
     */
    public LoginResponse refreshAccessToken(String refreshToken) {
        Objects.requireNonNull(refreshToken, "Refresh token no puede ser null");
        
        // Validar refresh token y obtener username
        String username = refreshTokenComponent.validateAndGetUsername(refreshToken);
        
        if (username == null) {
            log.warn("Refresh token inválido o expirado");
            throw new AuthenticationException(ErrorCode.TOKEN_EXPIRED);
        }
        
        // Buscar usuario
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new AuthenticationException(ErrorCode.USER_NOT_FOUND));
        
        // Generar nuevo access token
        String newAccessToken = jwtService.generateToken(user);
        
        log.info("Access token renovado para usuario: {}", username);
        
        return LoginResponse.builder()
            .token(newAccessToken)
            .tokenType("Bearer")
            .expiresIn(jwtService.getExpirationTime())
            .refreshToken(refreshToken)
            .refreshTokenExpiresIn((long) java.time.Duration.ofHours(1).toMillis())
            .username(user.getUsername())
            .email(user.getEmail())
            .nombreCompleto(user.getNombreCompleto())
            .build();
    }
}
