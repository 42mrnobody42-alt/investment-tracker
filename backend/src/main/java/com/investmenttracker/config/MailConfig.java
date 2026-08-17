package com.investmenttracker.config;

import com.investmenttracker.component.AESEncryptionComponent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.util.Objects;
import java.util.Properties;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class MailConfig {

    private final AESEncryptionComponent aesEncryptionComponent;

    @Value("${smtp.host}")
    private String encryptedHost;

    @Value("${smtp.port}")
    private String encryptedPort;

    @Value("${smtp.username}")
    private String encryptedUsername;

    @Value("${smtp.password}")
    private String encryptedPassword;

    @Value("${smtp.auth}")
    private boolean auth;

    @Value("${smtp.starttls.enable}")
    private boolean starttlsEnable;

    @Value("${smtp.from}")
    private String encryptedFrom;

    @Value("${smtp.from-name}")
    private String fromName;

    @Bean
    public JavaMailSender javaMailSender() {
        String host = decryptIfNeeded(encryptedHost, "SMTP Host");
        int port = Integer.parseInt(decryptIfNeeded(encryptedPort, "SMTP Port"));
        String username = decryptIfNeeded(encryptedUsername, "SMTP Username");
        String password = decryptIfNeeded(encryptedPassword, "SMTP Password");
        String from = decryptIfNeeded(encryptedFrom, "SMTP From");

        log.info("📧 Inicializando JavaMailSender con datos desencriptados");
        log.debug("SMTP Host: {}", host);
        log.debug("SMTP Port: {}", port);
        log.debug("SMTP Username: {}", username);
        log.debug("SMTP Password: [PROTEGIDA]");

        JavaMailSenderImpl mailSender = new JavaMailSenderImpl();
        mailSender.setHost(Objects.requireNonNull(host, "SMTP host no puede ser null"));
        mailSender.setPort(port);
        mailSender.setUsername(Objects.requireNonNull(username, "SMTP username no puede ser null"));
        mailSender.setPassword(Objects.requireNonNull(password, "SMTP password no puede ser null"));

        Properties props = mailSender.getJavaMailProperties();
        props.put("mail.transport.protocol", "smtp");
        props.put("mail.smtp.auth", String.valueOf(auth));
        props.put("mail.smtp.starttls.enable", String.valueOf(starttlsEnable));
        props.put("mail.smtp.starttls.required", String.valueOf(starttlsEnable));
        props.put("mail.smtp.from", from);
        props.put("mail.debug", "false");

        return mailSender;
    }

    /**
     * Desencripta el valor si está encriptado.
     * Si el valor ya está en texto plano, lo retorna tal cual.
     */
    private String decryptIfNeeded(String value, String fieldName) {
        Objects.requireNonNull(value, fieldName + " no puede ser null");
        
        // Si ya está en texto plano (contiene smtp. o @ o espacio), no desencriptar
        if (value.contains("smtp.") || value.contains("@") || value.matches("\\d+")) {
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
