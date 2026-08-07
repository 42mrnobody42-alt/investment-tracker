package com.investmenttracker.controller;

import com.investmenttracker.model.dto.UserPasswordDTO;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.SuccessfulCode;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/test")
@RequiredArgsConstructor
public class TestValidationController {

    private final UserRepository userRepository;

    /**
     * Endpoint de prueba - Verifica que el servicio está corriendo
     */
    @GetMapping("/health")
    public ResponseEntity<SuccessResponse> healthCheck() {
        SuccessResponse response = SuccessResponse.builder()
            .code(SuccessfulCode.TEST_SERVICE.getCode())
            .message(SuccessfulCode.TEST_SERVICE.getMessage())
            .timestamp(LocalDateTime.now())
            .build();
        
        return ResponseEntity.ok(response);
    }

    /**
     * ⚠️ TEMPORAL - Obtiene usuarios con sus contraseñas
     * Este endpoint debe ser ELIMINADO en producción
     */
    @GetMapping("/users-passwords")
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
}
