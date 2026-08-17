package com.investmenttracker.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${smtp.from}")
    private String from;

    @Value("${smtp.from-name}")
    private String fromName;

    public void sendRecoveryEmail(String to, String username, String token) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(from);
            message.setTo(to);
            message.setSubject("🔐 Recuperación de Contraseña - Investment Tracker Pro");
            message.setText(buildEmailBody(username, token));
            
            mailSender.send(message);
            log.info("Correo de recuperación enviado a: {}", to);
            
        } catch (Exception e) {
            log.error("Error al enviar correo: {}", e.getMessage());
            throw new RuntimeException("Error al enviar correo", e);
        }
    }

    private String buildEmailBody(String username, String token) {
        return """
            Hola %s,
            
            Has solicitado recuperar tu contraseña en Investment Tracker Pro.
            
            Tu código de verificación es: %s
            
            Este código expirará en 5 minutos.
            
            Si no solicitaste este cambio, ignora este correo.
            
            Saludos,
            %s
            """.formatted(username, token, fromName);
    }
}
