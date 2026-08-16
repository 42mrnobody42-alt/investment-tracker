package com.investmenttracker.controller;

import com.investmenttracker.model.request.EncryptionRequest;
import com.investmenttracker.model.response.EncryptionResponse;
import com.investmenttracker.service.EncryptionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Objects;

@RestController
@RequestMapping("/api/encryption")
@RequiredArgsConstructor
@Slf4j
public class EncryptionController {

    private final EncryptionService encryptionService;

    @PostMapping("/encrypt")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EncryptionResponse> encrypt(@RequestBody EncryptionRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String adminUsername = Objects.requireNonNull(authentication.getName(), "Username no puede ser null");
        
        EncryptionResponse response = encryptionService.encryptText(request, adminUsername);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/decrypt")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EncryptionResponse> decrypt(@RequestBody EncryptionRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String adminUsername = Objects.requireNonNull(authentication.getName(), "Username no puede ser null");
        
        EncryptionResponse response = encryptionService.decryptText(request, adminUsername);
        return ResponseEntity.ok(response);
    }
}
