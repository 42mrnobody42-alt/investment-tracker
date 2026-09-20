package com.investmenttracker.service;

import java.util.Objects;

import org.springframework.stereotype.Service;

import com.investmenttracker.component.RefreshTokenComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.response.LoginResponse;
import com.investmenttracker.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class RefreshTokenService {

    private final RefreshTokenComponent refreshTokenComponent;
    private final JwtService jwtService;
    private final UserRepository userRepository;

    /**
     * Refresca el access token usando el refresh token.
     * Solo retorna el nuevo access token y el refresh token vigente.
     */
    public LoginResponse refreshAccessToken(String refreshToken) {
        Objects.requireNonNull(refreshToken, "Refresh token no puede ser null");

        String username = refreshTokenComponent.validateAndGetUsername(refreshToken);

        if (username == null) {
            log.warn("Refresh token inválido o expirado");
            throw new AuthenticationException(ErrorCode.TOKEN_EXPIRED);
        }

        User user = userRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new AuthenticationException(ErrorCode.USER_NOT_FOUND));

        String newAccessToken = jwtService.generateToken(user);

        log.info("Access token renovado para usuario: {}", username);

        return LoginResponse.builder()
                .token(newAccessToken)
                .refreshToken(refreshToken)
                .build();
    }
}
