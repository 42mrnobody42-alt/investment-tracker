package com.investmenttracker.component;

import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.enums.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Objects;

@Component
@Slf4j
public class AESEncryptionComponent {

    @Value("${encryption.secret-key}")
    private String secretKeyBase64;

    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int GCM_IV_LENGTH = 12;
    private static final int GCM_TAG_LENGTH = 128;

    private SecretKeySpec getKeySpec() {
        byte[] keyBytes = Base64.getDecoder().decode(
            Objects.requireNonNull(secretKeyBase64, "Clave no puede ser null")
        );
        
        if (keyBytes.length != 16 && keyBytes.length != 24 && keyBytes.length != 32) {
            log.error("Longitud de clave inválida: {} bytes (debe ser 16, 24 o 32)", keyBytes.length);
            throw new AuthenticationException(ErrorCode.ENCRYPT_ERROR);
        }
        
        return new SecretKeySpec(keyBytes, ALGORITHM);
    }

    public String encrypt(String plainText) {
        if (plainText == null || plainText.isEmpty()) {
            throw new AuthenticationException(ErrorCode.TEXT_CANNOT_BE_NULL);
        }

        try {
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            byte[] iv = new byte[GCM_IV_LENGTH];
            new SecureRandom().nextBytes(iv);
            GCMParameterSpec gcmSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            
            cipher.init(Cipher.ENCRYPT_MODE, getKeySpec(), gcmSpec);
            byte[] encryptedBytes = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            
            byte[] combined = new byte[iv.length + encryptedBytes.length];
            System.arraycopy(iv, 0, combined, 0, iv.length);
            System.arraycopy(encryptedBytes, 0, combined, iv.length, encryptedBytes.length);
            
            String result = Base64.getEncoder().encodeToString(combined);
            log.debug("Texto encriptado exitosamente (longitud: {})", result.length());
            return result;
        } catch (AuthenticationException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error al encriptar: {}", e.getMessage());
            throw new AuthenticationException(ErrorCode.ENCRYPT_ERROR);
        }
    }

    public String decrypt(String encryptedText) {
        if (encryptedText == null || encryptedText.isEmpty()) {
            throw new AuthenticationException(ErrorCode.TEXT_CANNOT_BE_NULL);
        }

        try {
            byte[] combined = Base64.getDecoder().decode(encryptedText);
            
            if (combined.length <= GCM_IV_LENGTH) {
                throw new IllegalArgumentException("Texto encriptado inválido");
            }
            
            byte[] iv = new byte[GCM_IV_LENGTH];
            byte[] ciphertext = new byte[combined.length - GCM_IV_LENGTH];
            System.arraycopy(combined, 0, iv, 0, GCM_IV_LENGTH);
            System.arraycopy(combined, GCM_IV_LENGTH, ciphertext, 0, ciphertext.length);
            
            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            GCMParameterSpec gcmSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.DECRYPT_MODE, getKeySpec(), gcmSpec);
            
            byte[] decryptedBytes = cipher.doFinal(ciphertext);
            String result = new String(decryptedBytes, StandardCharsets.UTF_8);
            
            log.debug("Texto desencriptado exitosamente");
            return result;
        } catch (AuthenticationException e) {
            throw e;
        } catch (Exception e) {
            log.error("Error al desencriptar: {}", e.getMessage());
            throw new AuthenticationException(ErrorCode.DECRYPT_ERROR);
        }
    }
}
