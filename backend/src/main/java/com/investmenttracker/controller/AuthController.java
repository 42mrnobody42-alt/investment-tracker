package com.investmenttracker.controller;

import java.util.Collection;
import java.util.Map;
import java.util.Objects;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.investmenttracker.model.request.ChangePasswordRequest;
import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.request.RestartPasswordRequest;
import com.investmenttracker.model.response.LoginResponse;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.service.ChangeMyPasswordService;
import com.investmenttracker.service.LoginService;
import com.investmenttracker.service.LogoutService;
import com.investmenttracker.service.RefreshTokenService;
import com.investmenttracker.service.RestartUserPasswordService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final LoginService loginService;
    private final RestartUserPasswordService restartUserPasswordService;
    private final LogoutService logoutService;
    private final RefreshTokenService refreshTokenService;
    private final ChangeMyPasswordService changeMyPasswordService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = loginService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<LoginResponse> refreshToken(@RequestBody(required = false) Map<String, String> body) {
        if (body == null || body.get("refreshToken") == null || body.get("refreshToken").trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        String refreshToken = body.get("refreshToken");
        LoginResponse response = refreshTokenService.refreshAccessToken(refreshToken);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/restart-password")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse> restartPassword(@Valid @RequestBody RestartPasswordRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();

        boolean isAdmin = false;
        for (GrantedAuthority authority : authorities) {
            if ("ROLE_ADMIN".equals(authority.getAuthority())) {
                isAdmin = true;
                break;
            }
        }

        if (!isAdmin) {
            return ResponseEntity.status(403).build();
        }

        String adminUsername = authentication.getName();
        if (adminUsername == null) {
            return ResponseEntity.status(401).build();
        }

        SuccessResponse response = restartUserPasswordService.restartPassword(request, adminUsername);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<SuccessResponse> logout(
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @RequestBody(required = false) Map<String, String> body) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().build();
        }

        String token = authHeader.substring(7);
        SuccessResponse response = logoutService.logout(token);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/change-my-pass")
    public ResponseEntity<SuccessResponse> changeMyPassword(@Valid @RequestBody ChangePasswordRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String authenticatedUsername = Objects.requireNonNull(authentication.getName(), "Username no puede ser null");

        SuccessResponse response = changeMyPasswordService.changePassword(request, authenticatedUsername);
        return ResponseEntity.ok(response);
    }
}
