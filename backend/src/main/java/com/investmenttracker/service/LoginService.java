package com.investmenttracker.service;

import com.investmenttracker.component.LoginComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.response.LoginResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class LoginService {

    private final LoginComponent loginComponent;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    /**
     * Procesa el login del usuario
     */
    @Transactional
    public LoginResponse login(LoginRequest request) {
        String username = request.getUsername();
        log.info("Intento de login para usuario: {}", username);
        
        // 1. Verificar si está bloqueado por intentos fallidos (caché)
        if (loginComponent.isUserLocked(username)) {
            LoginComponent.LockInfo lockInfo = loginComponent.getLockInfo(username);
            throw new AuthenticationException(
                ErrorCode.ACCOUNT_LOCKED,
                String.format("Cuenta bloqueada temporalmente. Intente en %d minutos", 
                              lockInfo.lockedUntilSeconds() / 60)
            );
        }
        
        // 2. Buscar usuario
        User user = loginComponent.findUserByUsername(username)
            .orElseThrow(() -> {
                log.warn("Usuario no encontrado: {}", username);
                return new AuthenticationException(ErrorCode.INVALID_CREDENTIALS);
            });
        
        // 3. Verificar si está deshabilitado (DB)
        if (!user.getActivo()) {
            log.warn("Usuario {} está deshabilitado", username);
            throw new AuthenticationException(ErrorCode.ACCOUNT_DISABLED);
        }
        
        // 4. Validar contraseña
        if (!validatePassword(request.getPassword(), user.getPasswordHash())) {
            loginComponent.recordFailedAttempt(username);
            
            LoginComponent.LockInfo lockInfo = loginComponent.getLockInfo(username);
            
            if (lockInfo.locked()) {
                throw new AuthenticationException(
                    ErrorCode.MAX_ATTEMPTS_EXCEEDED,
                    String.format("Máximo de intentos excedido. Cuenta bloqueada por %d minutos",
                                  lockInfo.lockedUntilSeconds() / 60)
                );
            }
            
            throw new AuthenticationException(
                ErrorCode.INVALID_CREDENTIALS,
                String.format("Usuario o contraseña inválidos. Intentos restantes: %d", 
                              lockInfo.remainingAttempts())
            );
        }
        
        // 5. Login exitoso - resetear intentos
        loginComponent.resetFailedAttempts(user);
        
        // 6. Generar JWT
        String token = jwtService.generateToken(user);
        
        // 7. Construir respuesta
        String roles = user.getRoles().stream()
            .map(role -> role.getNombre())
            .collect(Collectors.joining(", "));
        
        log.info("Login exitoso para usuario: {} con roles: {}", user.getUsername(), roles);
        
        return LoginResponse.builder()
            .token(token)
            .tokenType("Bearer")
            .expiresIn(jwtService.getExpirationTime())
            .username(user.getUsername())
            .email(user.getEmail())
            .nombreCompleto(user.getNombreCompleto())
            .build();
    }

    /**
     * Valida la contraseña contra el hash BCrypt almacenado
     */
    private boolean validatePassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }
}
