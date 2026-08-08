package com.investmenttracker.controller;

import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.request.RestartPasswordRequest;
import com.investmenttracker.model.response.LoginResponse;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.service.LoginService;
import com.investmenttracker.service.RestartUserPasswordService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final LoginService loginService;
    private final RestartUserPasswordService restartUserPasswordService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = loginService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/restart-password")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse> restartPassword(@Valid @RequestBody RestartPasswordRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        // Doble verificación de rol ADMIN
        boolean isAdmin = authentication.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .anyMatch(auth -> auth.equals("ROLE_ADMIN"));
        
        if (!isAdmin) {
            return ResponseEntity.status(403).build();
        }
        
        String adminUsername = authentication.getName();
        SuccessResponse response = restartUserPasswordService.restartPassword(request, adminUsername);
        return ResponseEntity.ok(response);
    }
}
