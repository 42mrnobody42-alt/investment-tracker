package com.investmenttracker.service;

import com.investmenttracker.component.AESEncryptionComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.request.EncryptionRequest;
import com.investmenttracker.model.response.EncryptionResponse;
import com.investmenttracker.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EncryptionService {

    private final AESEncryptionComponent aesEncryptionComponent;
    private final UserRepository userRepository;

    public EncryptionResponse encryptText(EncryptionRequest request, String adminUsername) {
        String plainText = validateAndGetText(request);
        validateAdminUser(adminUsername);
        
        String encrypted = aesEncryptionComponent.encrypt(plainText);
        
        return EncryptionResponse.builder()
            .textoOriginal(plainText)
            .textoEncriptado(encrypted)
            .build();
    }

    public EncryptionResponse decryptText(EncryptionRequest request, String adminUsername) {
        String encryptedText = validateAndGetText(request);
        validateAdminUser(adminUsername);
        
        String decrypted = aesEncryptionComponent.decrypt(encryptedText);
        
        return EncryptionResponse.builder()
            .textoEncriptado(encryptedText)
            .textoDesencriptado(decrypted)
            .build();
    }

    private String validateAndGetText(EncryptionRequest request) {
        if (request == null) {
            throw new AuthenticationException(ErrorCode.TEXT_CANNOT_BE_NULL);
        }
        
        String text = request.getCadena_string_a_encriptar();
        
        if (text == null || text.trim().isEmpty()) {
            throw new AuthenticationException(ErrorCode.TEXT_CANNOT_BE_NULL);
        }
        
        return text;
    }

    private void validateAdminUser(String adminUsername) {
        User admin = userRepository.findByUsername(adminUsername)
            .orElseThrow(() -> {
                log.warn("Admin no encontrado: {}", adminUsername);
                return new AuthenticationException(ErrorCode.USER_NOT_FOUND);
            });
        
        boolean isAdmin = admin.getRoles().stream()
            .anyMatch(role -> "ROLE_ADMIN".equals(role.getNombre()));
        
        if (!isAdmin) {
            log.warn("Usuario {} sin ROLE_ADMIN intentó acceder a encryption", adminUsername);
            throw new AuthenticationException(ErrorCode.ACCESS_DENIED);
        }
        
        log.debug("Rol ADMIN verificado para: {}", adminUsername);
    }
}
