package com.investmenttracker.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.investmenttracker.model.request.PasswordRecoveryRequest;
import com.investmenttracker.model.request.TokenVerificationRequest;
import com.investmenttracker.service.PasswordRecoveryService;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Objects;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class PasswordRecoveryIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private PasswordRecoveryService passwordRecoveryService;

    private static final String USERNAME = "incognito";
    private static final String EMAIL = "42mrnobody42@gmail.com";
    private static final String NEW_PASSWORD = "NuevoPass123!";

    private void printBanner(String title) {
        System.out.println("\n" + "=".repeat(70));
        System.out.println("  " + title);
        System.out.println("=".repeat(70));
    }

    private void printStep(String step, String message) {
        System.out.println("  [" + step + "] " + message);
    }

    private void printSubStep(String message) {
        System.out.println("     ↳ " + message);
    }

    private String toJson(Object obj) {
        try {
            return Objects.requireNonNull(objectMapper.writeValueAsString(obj), "JSON no puede ser null");
        } catch (Exception e) {
            throw new RuntimeException("Error serializando JSON", e);
        }
    }

    @Test
    @Order(1)
    @DisplayName("REC-01: Solicitar recuperación - usuario incognito")
    void testRequestRecovery() throws Exception {
        printBanner("🔐 PRUEBAS DE RECUPERACIÓN DE CONTRASEÑA (2FA SMTP)");
        printStep("REC-01", "Solicitar recuperación para incognito");
        printSubStep("Usuario: " + USERNAME);
        printSubStep("Email: " + EMAIL);
        printSubStep("Nueva contraseña: " + NEW_PASSWORD);

        PasswordRecoveryRequest request = PasswordRecoveryRequest.builder()
            .username(USERNAME)
            .email(EMAIL)
            .nuevoPassword(NEW_PASSWORD)
            .build();

        MvcResult result = mockMvc.perform(post("/api/auth/recovery/request")
                .contentType(MediaType.APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value("REC-0001"))
            .andReturn();

        printSubStep("✅ Respuesta: " + result.getResponse().getContentAsString());
        printStep("REC-01", "✅ Correo de recuperación solicitado");
    }

    @Test
    @Order(2)
    @DisplayName("REC-02: Verificar token REAL y cambiar contraseña")
    void testVerifyTokenAndChangePassword() throws Exception {
        printStep("REC-02", "Verificar token real y cambiar contraseña");
        
        // Obtener el token REAL generado por el servicio
        String realToken = passwordRecoveryService.getTokenForTest(USERNAME);
        assertNotNull(realToken, "El token no debe ser null");
        printSubStep("Token real del servicio: " + realToken);

        TokenVerificationRequest request = TokenVerificationRequest.builder()
            .username(USERNAME)
            .email(EMAIL)
            .token(realToken)
            .nuevoPassword(NEW_PASSWORD)
            .build();

        mockMvc.perform(post("/api/auth/recovery/verify")
                .contentType(MediaType.APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value("REC-0002"))
            .andExpect(jsonPath("$.message").value("Contraseña actualizada exitosamente"));

        printStep("REC-02", "✅ Contraseña actualizada con token real");
    }

    @Test
    @Order(3)
    @DisplayName("REC-03: Login con la nueva contraseña")
    void testLoginWithNewPassword() throws Exception {
        printStep("REC-03", "Login con la nueva contraseña");
        printSubStep("Usuario: " + USERNAME + " | Password: " + NEW_PASSWORD);

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"" + USERNAME + "\",\"password\":\"" + NEW_PASSWORD + "\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.username").value(USERNAME));

        printStep("REC-03", "✅ Login exitoso con nueva contraseña");
    }

    @Test
    @Order(4)
    @DisplayName("REC-04: Restaurar contraseña original (cleanup)")
    void testRestoreOriginalPassword() throws Exception {
        printStep("REC-04", "Restaurar contraseña original de incognito");
        
        MvcResult adminLogin = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"admin\",\"password\":\"Admin123!\"}"))
            .andExpect(status().isOk())
            .andReturn();

        String adminToken = objectMapper.readTree(adminLogin.getResponse().getContentAsString())
            .get("token").asText();

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content("{\"username\":\"incognito\",\"email\":\"42mrnobody42@gmail.com\",\"nombreCompleto\":\"Usuario Premium incognito\",\"nuevoPassword\":\"C4mb14m3!Urgente\",\"repetirNuevoPassword\":\"C4mb14m3!Urgente\"}"))
            .andExpect(status().isOk());

        printStep("REC-04", "✅ Contraseña original restaurada");
        System.out.println("=".repeat(70));
        System.out.println("  🔐 FIN PRUEBAS DE RECUPERACIÓN");
        System.out.println("=".repeat(70));
    }
}
