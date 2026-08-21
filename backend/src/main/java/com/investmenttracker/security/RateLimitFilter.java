package com.investmenttracker.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.investmenttracker.component.RateLimitComponent;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.response.ErrorResponse;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
@Slf4j
public class RateLimitFilter extends OncePerRequestFilter {

    private final RateLimitComponent rateLimitComponent;
    private final ObjectMapper objectMapper;

    @Value("${rate-limiting.enabled}")
    private boolean enabled;

    @Value("${rate-limiting.login.max-requests}")
    private int loginMaxRequests;

    @Value("${rate-limiting.login.window-seconds}")
    private int loginWindowSeconds;

    @Value("${rate-limiting.recovery.max-requests}")
    private int recoveryMaxRequests;

    @Value("${rate-limiting.recovery.window-seconds}")
    private int recoveryWindowSeconds;

    @Value("${rate-limiting.default.max-requests}")
    private int defaultMaxRequests;

    @Value("${rate-limiting.default.window-seconds}")
    private int defaultWindowSeconds;

    @Override
    protected boolean shouldNotFilter(@NonNull HttpServletRequest request) {
        String path = request.getRequestURI();
        // Excluir solo actuator y error, PERMITIR recovery para rate limit
        return path.startsWith("/actuator") || path.startsWith("/error");
    }

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain) throws ServletException, IOException {

        if (!enabled) {
            filterChain.doFilter(request, response);
            return;
        }

        String path = request.getRequestURI();
        String ip = getClientIp(request);
        log.debug("RateLimitFilter procesando: {} - IP: {}", path, ip);
        
        // Determinar límites según endpoint
        RateLimitConfig config = getRateLimitConfig(path);
        
        String key = ip + ":" + path;
        
        if (!rateLimitComponent.isAllowed(key, config.maxRequests(), config.windowSeconds())) {
            log.warn("Rate limit excedido para IP: {} en endpoint: {}", ip, path);
            
            ErrorResponse errorResponse = ErrorResponse.builder()
                .code(ErrorCode.RATE_LIMIT_EXCEEDED.getCode())
                .message(ErrorCode.RATE_LIMIT_EXCEEDED.getMessage())
                .timestamp(LocalDateTime.now())
                .build();
            
            response.setStatus(ErrorCode.RATE_LIMIT_EXCEEDED.getHttpStatus().value());
            response.setContentType("application/json");
            response.getWriter().write(objectMapper.writeValueAsString(errorResponse));
            return;
        }
        
        filterChain.doFilter(request, response);
    }

    private RateLimitConfig getRateLimitConfig(String path) {
        if (path.startsWith("/api/auth/login")) {
            return new RateLimitConfig(loginMaxRequests, loginWindowSeconds);
        }
        if (path.contains("recovery")) {
            return new RateLimitConfig(recoveryMaxRequests, recoveryWindowSeconds);
        }
        return new RateLimitConfig(defaultMaxRequests, defaultWindowSeconds);
    }

    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private record RateLimitConfig(int maxRequests, int windowSeconds) {}
}
