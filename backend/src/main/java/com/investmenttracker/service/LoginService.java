package com.investmenttracker.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.investmenttracker.component.LoginComponent;
import com.investmenttracker.component.RefreshTokenComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.response.LoginResponse;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class LoginService {

    private final LoginComponent loginComponent;
    private final JwtService jwtService;
    private final RefreshTokenComponent refreshTokenComponent;
    private final AuditContextService auditContextService;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Transactional
    public LoginResponse login(LoginRequest request) {
        String username = request.getUsername();
        log.info("Intento de login para usuario: {}", username);

        if (loginComponent.isUserLocked(username)) {
            LoginComponent.LockInfo lockInfo = loginComponent.getLockInfo(username);
            throw new AuthenticationException(
                    ErrorCode.ACCOUNT_LOCKED,
                    String.format("Cuenta bloqueada temporalmente. Intente en %d minutos",
                            lockInfo.lockedUntilSeconds() / 60));
        }

        User user = loginComponent.findUserByUsername(username)
                .orElseThrow(() -> {
                    log.warn("Usuario no encontrado: {}", username);
                    return new AuthenticationException(ErrorCode.INVALID_CREDENTIALS);
                });

        if (!user.getActivo()) {
            throw new AuthenticationException(ErrorCode.ACCOUNT_DISABLED);
        }

        if (!validatePassword(request.getPassword(), user.getPasswordHash())) {
            loginComponent.recordFailedAttempt(username);
            LoginComponent.LockInfo lockInfo = loginComponent.getLockInfo(username);

            if (lockInfo.locked()) {
                throw new AuthenticationException(
                        ErrorCode.MAX_ATTEMPTS_EXCEEDED,
                        String.format("Máximo de intentos excedido. Cuenta bloqueada por %d minutos",
                                lockInfo.lockedUntilSeconds() / 60));
            }

            throw new AuthenticationException(
                    ErrorCode.INVALID_CREDENTIALS,
                    String.format("Usuario o contraseña inválidos. Intentos restantes: %d",
                            lockInfo.remainingAttempts()));
        }

        // AUDITORÍA: forzar el usuario que se está logueando
        auditContextService.setCurrentUser(user.getUsername());

        loginComponent.resetFailedAttempts(user);

        // Generar tokens
        String accessToken = jwtService.generateToken(user);
        String refreshToken = refreshTokenComponent.generateRefreshToken(user.getUsername());

        log.info("Login exitoso para usuario: {}", user.getUsername());

        return LoginResponse.builder()
                .token(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    private boolean validatePassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }
}
