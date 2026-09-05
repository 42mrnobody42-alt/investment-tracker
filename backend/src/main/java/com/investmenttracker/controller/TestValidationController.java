package com.investmenttracker.controller;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.investmenttracker.model.dto.UserPasswordDTO;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.SuccessfulCode;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.UserRepository;
import com.investmenttracker.service.RegisterService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/test")
@RequiredArgsConstructor
public class TestValidationController {

    private final UserRepository userRepository;
    private final RegisterService registerService;

    @GetMapping("/health")
    public ResponseEntity<SuccessResponse> healthCheck() {
        SuccessResponse response = SuccessResponse.builder()
                .code(SuccessfulCode.TEST_SERVICE.getCode())
                .message(SuccessfulCode.TEST_SERVICE.getMessage())
                .timestamp(LocalDateTime.now())
                .build();
        return ResponseEntity.ok(response);
    }

    @GetMapping("/users-passwords")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse> getUsersWithPasswords() {
        List<User> users = userRepository.findAll();

        List<UserPasswordDTO> userList = users.stream()
                .map(user -> UserPasswordDTO.builder()
                        .id(user.getId())
                        .username(user.getUsername())
                        .email(user.getEmail())
                        .passwordHash(user.getPasswordHash())
                        .passwordDecrypted("BCrypt - No reversible")
                        .nombreCompleto(user.getNombreCompleto())
                        .build())
                .collect(Collectors.toList());

        SuccessResponse response = SuccessResponse.builder()
                .code(SuccessfulCode.OPERATION_SUCCESS.getCode())
                .message("Usuarios obtenidos (SOLO DESARROLLO)")
                .timestamp(LocalDateTime.now())
                .data(userList)
                .build();

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/delete-user/{username}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse> deleteUserPermanently(@PathVariable String username) {
        registerService.deleteUserPermanently(username);
        return ResponseEntity.ok(SuccessResponse.builder()
                .code(SuccessfulCode.OPERATION_SUCCESS.getCode())
                .message("Usuario '" + username + "' eliminado definitivamente")
                .timestamp(LocalDateTime.now())
                .build());
    }
}
