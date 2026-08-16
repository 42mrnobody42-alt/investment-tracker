package com.investmenttracker.config;

import com.investmenttracker.component.AESEncryptionComponent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import java.util.Objects;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class EncryptedDataSourceConfig {

    private final AESEncryptionComponent aesEncryptionComponent;

    @Value("${spring.datasource.url}")
    private String encryptedUrl;

    @Value("${spring.datasource.username}")
    private String encryptedUsername;

    @Value("${spring.datasource.password}")
    private String encryptedPassword;

    @Value("${spring.datasource.driver-class-name}")
    private String driverClassName;

    @Bean
    @Primary
    public DataSource dataSource() {
        String decryptedUrl = decryptIfNeeded(encryptedUrl, "URL");
        String decryptedUsername = decryptIfNeeded(encryptedUsername, "Username");
        String decryptedPassword = decryptIfNeeded(encryptedPassword, "Password");

        log.info("🔓 Inicializando DataSource con datos desencriptados");
        log.debug("URL desencriptada: {}", decryptedUrl);
        log.debug("Username desencriptado: {}", decryptedUsername);
        log.debug("Password desencriptada: [PROTEGIDA]");

        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName(Objects.requireNonNull(driverClassName, "driverClassName no puede ser null"));
        dataSource.setUrl(decryptedUrl);
        dataSource.setUsername(decryptedUsername);
        dataSource.setPassword(decryptedPassword);
        
        return dataSource;
    }

    /**
     * Desencripta el valor si es necesario.
     * Si el valor ya está en texto plano (contiene "jdbc:" o es corto), se asume que no está encriptado.
     */
    private String decryptIfNeeded(String value, String fieldName) {
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalStateException("El valor de " + fieldName + " no puede ser null o vacío");
        }
        
        // Si ya está en texto plano (ej: contiene "jdbc:" o "postgresql"), no desencriptar
        if (value.contains("jdbc:") || value.contains("postgresql") || value.equals("investor")) {
            log.debug("{} ya está en texto plano", fieldName);
            return value;
        }
        
        try {
            String decrypted = aesEncryptionComponent.decrypt(value);
            log.debug("{} desencriptado correctamente", fieldName);
            return decrypted;
        } catch (Exception e) {
            log.error("No se pudo desencriptar {}: {}", fieldName, e.getMessage());
            throw new IllegalStateException("Error al desencriptar " + fieldName, e);
        }
    }
}
