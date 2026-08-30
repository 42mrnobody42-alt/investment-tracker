package com.investmenttracker.controller;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Objects;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;

import com.investmenttracker.model.request.ChangePasswordRequest;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class ChangeMyPasswordIntegrationTest extends BaseIntegrationTest {

    private String demoToken;
    private String adminToken;
    private static final String USERNAME = "demo_user";
    private static final String EMAIL = "demo@investment-tracker.com";
    private static final String CURRENT_PASSWORD = "Demo123!";
    private static final String NEW_PASSWORD = "DemoNueva123!";

    /**
     * Importante NUNCA se debe usar @BeforEach ni @AfterEach para obtener tokens,
     * ya que se reinicia el estado de la base de datos y se invalidan los tokens.
     * Por eso se usa @BeforeAll para obtener los tokens una sola vez antes de todas
     * las pruebas.
     * 
     * @throws Exception
     */
    @BeforeAll
    void setUpOnce() throws Exception {
        clearBlacklist();

        demoToken = loginAndGetToken(USERNAME, CURRENT_PASSWORD);
        assertNotNull(demoToken, "Token demo no puede ser null");

        adminToken = loginAndGetToken("admin", "Admin123!");
        assertNotNull(adminToken, "Token admin no puede ser null");

        printBanner("🔑 PRUEBAS DE CAMBIO DE CONTRASEÑA (CHANGE MY PASSWORD)");
        printStep("SETUP", "Tokens obtenidos al inicio y estado limpiado");
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
        printStep("CMP-01", "✅ Token obtenido en @BeforeAll");
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
                .content(Objects.requireNonNull(toJson(
                        new com.investmenttracker.model.request.LoginRequest(USERNAME, NEW_PASSWORD)),
                        "JSON no puede ser null")))
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

        ChangePasswordRequest request = buildRequest(USERNAME, "wrong@email.com", NEW_PASSWORD, "OtraNueva123!",
                "OtraNueva123!");

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

        ChangePasswordRequest request = buildRequest(USERNAME, EMAIL, NEW_PASSWORD, "OtraNueva123!",
                "OtraNueva123!");

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
        printStep("CMP-11", "Restaurar contraseña original de demo_user");

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + adminToken)
                .content(Objects.requireNonNull(toJson(
                        new com.investmenttracker.model.request.RestartPasswordRequest(
                                USERNAME,
                                EMAIL,
                                "Usuario Demo",
                                CURRENT_PASSWORD,
                                CURRENT_PASSWORD)),
                        "JSON no puede ser null")))
                .andExpect(status().isOk());

        printStep("CMP-11", "✅ Contraseña original restaurada");
        System.out.println("=".repeat(70));
        System.out.println("  🔑 FIN PRUEBAS DE CAMBIO DE CONTRASEÑA");
        System.out.println("=".repeat(70));
    }
}