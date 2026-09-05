package com.investmenttracker.controller;

import com.investmenttracker.model.request.RegisterConfirmRequest;
import com.investmenttracker.model.request.RegisterRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.service.RegisterService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth/register")
@RequiredArgsConstructor
public class RegisterController {

    private final RegisterService registerService;

    @PostMapping("/request")
    public ResponseEntity<SuccessResponse> requestRegistration(@RequestBody RegisterRequest request) {
        SuccessResponse response = registerService.requestRegistration(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/confirm")
    public ResponseEntity<SuccessResponse> confirmRegistration(@RequestBody RegisterConfirmRequest request) {
        SuccessResponse response = registerService.confirmRegistration(request);
        return ResponseEntity.ok(response);
    }
}
