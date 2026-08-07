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
    public ResponseEntity<SuccessResponse> restartPassword(@Valid @RequestBody RestartPasswordRequest request) {
        SuccessResponse response = restartUserPasswordService.restartPassword(request);
        return ResponseEntity.ok(response);
    }
}
