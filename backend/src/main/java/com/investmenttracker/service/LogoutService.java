package com.investmenttracker.service;

import com.investmenttracker.component.TokenBlacklistComponent;
import com.investmenttracker.model.response.SuccessResponse;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Slf4j
public class LogoutService {

    private final com.investmenttracker.service.JwtService jwtService;
    private final TokenBlacklistComponent tokenBlacklistComponent;

    public SuccessResponse logout(String token) {
        Objects.requireNonNull(token, "Token no puede ser null");
        
        String jwt = token.replace("Bearer ", "").trim();
        
        try {
            Claims claims = jwtService.extractAllClaims(jwt);
            Date expirationDate = claims.getExpiration();
            
            LocalDateTime expirationDateTime = expirationDate.toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDateTime();
            
            tokenBlacklistComponent.addToBlacklist(jwt, expirationDateTime);
            
            String username = claims.getSubject();
            log.info("Logout exitoso para usuario: {}", username);
            
            return SuccessResponse.builder()
                .code("AUTH-0001")
                .message("Sesión cerrada exitosamente")
                .timestamp(LocalDateTime.now())
                .build();
                
        } catch (Exception e) {
            log.error("Error al procesar logout: {}", e.getMessage());
            throw new IllegalArgumentException("Token inválido para logout");
        }
    }
}
