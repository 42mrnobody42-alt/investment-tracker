package com.investmenttracker.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.investmenttracker.model.request.ChangePasswordRequest;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Objects;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class ChangeMyPasswordIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private static String demoToken;
    private static final String USERNAME = "demo_user";
    private static final String EMAIL = "demo@investment-tracker.com";
    private static final String CURRENT_PASSWORD = "Demo123!";
    private static final String NEW_PASSWORD = "DemoNueva123!";

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

    private String extractToken(MvcResult result) throws Exception {
        return Objects.requireNonNull(
            objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText(),
            "Token no puede ser null");
    }

    private ChangePasswordRequest buildRequest(String username, String email, 
                                                String actualPassword, 
                                                String nuevoPassword, 
                                                String repetirPassword) {
        return ChangePasswordRequest.builder()
            .username(username)
            .email(email)
            .actualPassword(actualPassword)
            .nuevoPassword(nuevoPassword)
            .repetirNuevoPassword(repetirPassword)
            .build();
    }

    @Test
    @Order(1)
    @DisplayName("CMP-01: Login demo_user para obtener token")
    void testLoginForToken() throws Exception {
        printBanner("🔑 PRUEBAS DE CAMBIO DE CONTRASEÑA (CHANGE MY PASSWORD)");
        printStep("CMP-01", "Login demo_user");
        
        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"username\":\"demo_user\",\"password\":\"Demo123!\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andReturn();
        
        demoToken = extractToken(result);
        printStep("CMP-01", "✅ Token obtenido");
    }

    @Test
    @Order(2)
    @DisplayName("CMP-02: Cambio de contraseña EXITOSO")
    void testChangePasswordSuccess() throws Exception {
        printStep("CMP-02", "Cambiar contraseña con datos correctos → 200");
        printSubStep("Usuario: " + USERNAME);
        printSubStep("Contraseña actual: " + CURRENT_PASSWORD);
        printSubStep("Nueva contraseña: " + NEW_PASSWORD);

        ChangePasswordRequest request = buildRequest(USERNAME, EMAIL, CURRENT_PASSWORD, NEW_PASSWORD, NEW_PASSWORD);

        mockMvc.perform(post("/api/auth/change-my-pass")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + demoToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.code").value("AUTH-0003"))
            .andExpect(jsonPath("$.message").value("Contraseña actualizada exitosamente"));

        printStep("CMP-02", "✅ Contraseña actualizada correctamente");
    }

    @Test
    @Order(3)
    @DisplayName("CMP-03: Login con NUEVA contraseña")
    void testLoginWithNewPassword() throws Exception {
        printStep("CMP-03", "Login con la nueva contraseña");
        printSubStep("Usuario: " + USERNAME + " | Password: " + NEW_PASSWORD);

        mockMvc.perform(post("/api/auth/login")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"username\":\"" + USERNAME + "\",\"password\":\"" + NEW_PASSWORD + "\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.username").value(USERNAME));

        printStep("CMP-03", "✅ Login exitoso con nueva contraseña");
    }

    @Test
    @Order(4)
    @DisplayName("CMP-04: Contraseña actual INCORRECTA")
    void testWrongCurrentPassword() throws Exception {
        printStep("CMP-04", "Contraseña actual incorrecta → 400");
        
        ChangePasswordRequest request = buildRequest(USERNAME, EMAIL, "WrongPassword!", NEW_PASSWORD, NEW_PASSWORD);

        mockMvc.perform(post("/api/auth/change-my-pass")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + demoToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.code").value("PWD-003"));

        printStep("CMP-04", "✅ Contraseña actual incorrecta rechazada");
    }

    @Test
    @Order(5)
    @DisplayName("CMP-05: Campos vacíos")
    void testEmptyFields() throws Exception {
        printStep("CMP-05", "Campos vacíos → 400");
        
        ChangePasswordRequest request = buildRequest("", "", "", "", "");

        mockMvc.perform(post("/api/auth/change-my-pass")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + demoToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
            .andExpect(status().isBadRequest());

        printStep("CMP-05", "✅ Campos vacíos rechazados");
    }

    @Test
    @Order(6)
    @DisplayName("CMP-06: Contraseñas nuevas NO coinciden")
    void testNewPasswordsMismatch() throws Exception {
        printStep("CMP-06", "Contraseñas nuevas no coinciden → 400");
        
        ChangePasswordRequest request = buildRequest(USERNAME, EMAIL, NEW_PASSWORD, "Nueva123!", "Diferente123!");

        mockMvc.perform(post("/api/auth/change-my-pass")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + demoToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.code").value("PWD-001"));

        printStep("CMP-06", "✅ Contraseñas diferentes rechazadas");
    }

    @Test
    @Order(7)
    @DisplayName("CMP-07: Nueva contraseña sin mayúscula")
    void testNewPasswordNoUpperCase() throws Exception {
        printStep("CMP-07", "Nueva contraseña sin mayúscula → 400");
        
        ChangePasswordRequest request = buildRequest(USERNAME, EMAIL, NEW_PASSWORD, "password123!", "password123!");

        mockMvc.perform(post("/api/auth/change-my-pass")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + demoToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.code").value("PWD-002"));

        printStep("CMP-07", "✅ Sin mayúscula rechazada");
    }

    @Test
    @Order(8)
    @DisplayName("CMP-08: Email incorrecto")
    void testWrongEmail() throws Exception {
        printStep("CMP-08", "Email incorrecto → 401");
        
        ChangePasswordRequest request = buildRequest(USERNAME, "wrong@email.com", NEW_PASSWORD, "OtraNueva123!", "OtraNueva123!");

        mockMvc.perform(post("/api/auth/change-my-pass")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + demoToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
            .andExpect(status().isUnauthorized());

        printStep("CMP-08", "✅ Email incorrecto rechazado");
    }

    @Test
    @Order(9)
    @DisplayName("CMP-09: Sin token")
    void testWithoutToken() throws Exception {
        printStep("CMP-09", "Sin token → 403");
        
        ChangePasswordRequest request = buildRequest(USERNAME, EMAIL, NEW_PASSWORD, "OtraNueva123!", "OtraNueva123!");

        mockMvc.perform(post("/api/auth/change-my-pass")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
            .andExpect(status().isForbidden());

        printStep("CMP-09", "✅ Sin token = 403");
    }

    @Test
    @Order(10)
    @DisplayName("CMP-10: Nueva contraseña igual a la actual")
    void testSamePassword() throws Exception {
        printStep("CMP-10", "Nueva contraseña igual a la actual → 400");
        
        ChangePasswordRequest request = buildRequest(USERNAME, EMAIL, NEW_PASSWORD, NEW_PASSWORD, NEW_PASSWORD);

        mockMvc.perform(post("/api/auth/change-my-pass")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + demoToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.code").value("PWD-004"));

        printStep("CMP-10", "✅ Contraseña igual rechazada");
    }

    @Test
    @Order(11)
    @DisplayName("CMP-11: Cleanup - Restaurar contraseña original")
    void testRestoreOriginalPassword() throws Exception {
        printStep("CMP-11", "Restaurar contraseña original");
        
        // Login admin
        MvcResult adminLogin = mockMvc.perform(post("/api/auth/login")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"username\":\"admin\",\"password\":\"Admin123!\"}"))
            .andExpect(status().isOk())
            .andReturn();

        String adminToken = extractToken(adminLogin);

        // Restaurar contraseña de demo_user
        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + adminToken)
                .content("{\"username\":\"demo_user\",\"email\":\"demo@investment-tracker.com\",\"nombreCompleto\":\"Usuario Demo\",\"nuevoPassword\":\"Demo123!\",\"repetirNuevoPassword\":\"Demo123!\"}"))
            .andExpect(status().isOk());

        printStep("CMP-11", "✅ Contraseña original restaurada");
        System.out.println("=".repeat(70));
        System.out.println("  🔑 FIN PRUEBAS DE CAMBIO DE CONTRASEÑA");
        System.out.println("=".repeat(70));
    }
}
