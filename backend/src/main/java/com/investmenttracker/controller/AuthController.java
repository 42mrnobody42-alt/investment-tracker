package com.investmenttracker.controller;

import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.request.RestartPasswordRequest;
import com.investmenttracker.model.response.LoginResponse;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.service.LoginService;
import com.investmenttracker.service.LogoutService;
import com.investmenttracker.service.RestartUserPasswordService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Collection;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final LoginService loginService;
    private final RestartUserPasswordService restartUserPasswordService;
    private final LogoutService logoutService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = loginService.login(request);
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
    public ResponseEntity<SuccessResponse> logout(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().build();
        }

        String token = authHeader.substring(7);
        SuccessResponse response = logoutService.logout(token);
        return ResponseEntity.ok(response);
    }
}
