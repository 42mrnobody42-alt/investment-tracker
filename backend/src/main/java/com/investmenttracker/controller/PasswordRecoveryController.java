package com.investmenttracker.controller;

import com.investmenttracker.model.request.PasswordRecoveryRequest;
import com.investmenttracker.model.request.TokenVerificationRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.service.PasswordRecoveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth/recovery")
@RequiredArgsConstructor
public class PasswordRecoveryController {

    private final PasswordRecoveryService passwordRecoveryService;

    @PostMapping("/request")
    public ResponseEntity<SuccessResponse> requestRecovery(@RequestBody PasswordRecoveryRequest request) {
        SuccessResponse response = passwordRecoveryService.requestRecovery(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify")
    public ResponseEntity<SuccessResponse> verifyToken(@RequestBody TokenVerificationRequest request) {
        SuccessResponse response = passwordRecoveryService.verifyTokenAndChangePassword(request);
        return ResponseEntity.ok(response);
    }
}
