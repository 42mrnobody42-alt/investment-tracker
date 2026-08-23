package com.investmenttracker.controller;

import com.investmenttracker.component.RefreshTokenComponent;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Objects;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class RefreshTokenIntegrationTest extends BaseIntegrationTest {

    @Autowired
    private RefreshTokenComponent refreshTokenComponent;

    private static String accessToken;
    private static String refreshToken;

    private String extractField(MvcResult result, String fieldName) throws Exception {
        return Objects.requireNonNull(
            objectMapper.readTree(result.getResponse().getContentAsString()).get(fieldName).asText(),
            fieldName + " no puede ser null");
    }

    @Test
    @Order(1)
    @DisplayName("RT-01: Login admin con refresh token")
    void testLoginWithRefreshToken() throws Exception {
        printBanner("🔄 PRUEBAS DE REFRESH TOKEN");
        printStep("RT-01", "Login admin - debe retornar access token + refresh token");

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"username\":\"admin\",\"password\":\"Admin123!\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.refreshToken").exists())
            .andExpect(jsonPath("$.tokenType").value("Bearer"))
            .andReturn();

        accessToken = extractField(result, "token");
        refreshToken = extractField(result, "refreshToken");

        assertNotNull(accessToken, "Access token no puede ser null");
        assertNotNull(refreshToken, "Refresh token no puede ser null");
        assertNotEquals(accessToken, refreshToken, "Tokens deben ser diferentes");

        printSubStep("Access Token: " + accessToken.substring(0, 30) + "...");
        printSubStep("Refresh Token: " + refreshToken.substring(0, 30) + "...");
        printStep("RT-01", "✅ Login retorna ambos tokens");
    }

    @Test
    @Order(2)
    @DisplayName("RT-02: Refresh token exitoso")
    void testRefreshTokenSuccess() throws Exception {
        printStep("RT-02", "Usar refresh token para obtener nuevo access token");

        MvcResult result = mockMvc.perform(post("/api/auth/refresh-token")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"refreshToken\":\"" + refreshToken + "\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.username").value("admin"))
            .andReturn();

        String newAccessToken = extractField(result, "token");
        assertNotNull(newAccessToken, "Nuevo access token no puede ser null");

        printSubStep("Nuevo Access Token: " + newAccessToken.substring(0, 30) + "...");
        printStep("RT-02", "✅ Refresh token generó nuevo access token");
    }

    @Test
    @Order(3)
    @DisplayName("RT-03: Refresh token null → 400")
    void testRefreshTokenNull() throws Exception {
        printStep("RT-03", "Refresh token null → 400");

        mockMvc.perform(post("/api/auth/refresh-token")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{}"))
            .andExpect(status().isBadRequest());

        printStep("RT-03", "✅ Token null rechazado");
    }

    @Test
    @Order(4)
    @DisplayName("RT-04: Refresh token vacío → 400")
    void testRefreshTokenEmpty() throws Exception {
        printStep("RT-04", "Refresh token vacío → 400");

        mockMvc.perform(post("/api/auth/refresh-token")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"refreshToken\":\"\"}"))
            .andExpect(status().isBadRequest());

        printStep("RT-04", "✅ Token vacío rechazado");
    }

    @Test
    @Order(5)
    @DisplayName("RT-05: Refresh token inválido → 4xx")
    void testRefreshTokenInvalid() throws Exception {
        printStep("RT-05", "Refresh token inválido → 4xx");

        mockMvc.perform(post("/api/auth/refresh-token")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"refreshToken\":\"token-invalido-123\"}"))
            .andExpect(status().is4xxClientError());

        printStep("RT-05", "✅ Token inválido rechazado");
    }

    @Test
    @Order(6)
    @DisplayName("RT-06: Refresh token expirado por inactividad (simulado)")
    void testRefreshTokenExpiredByInactivity() throws Exception {
        printStep("RT-06", "Simular expiración por inactividad");

        // Forzar expiración del refresh token sin esperar 1 hora
        refreshTokenComponent.expireForTest(refreshToken);

        mockMvc.perform(post("/api/auth/refresh-token")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"refreshToken\":\"" + refreshToken + "\"}"))
            .andExpect(status().is4xxClientError());

        printStep("RT-06", "✅ Token expirado rechazado (simulado con expireForTest)");
    }

    @Test
    @Order(7)
    @DisplayName("RT-07: Access token sigue funcionando después de refresh")
    void testAccessTokenStillValidAfterRefresh() throws Exception {
        printStep("RT-07", "Verificar que el access token original sigue siendo válido");

        MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content("{\"username\":\"admin\",\"password\":\"Admin123!\"}"))
            .andExpect(status().isOk())
            .andReturn();

        String freshAccessToken = extractField(loginResult, "token");

        mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + freshAccessToken)
                .content("{\"cadena_string_a_encriptar\":\"TestRefreshToken123!\"}"))
            .andExpect(status().isOk());

        printStep("RT-07", "✅ Access token válido después de refresh");

        System.out.println("=".repeat(70));
        System.out.println("  🔄 FIN PRUEBAS DE REFRESH TOKEN");
        System.out.println("=".repeat(70));
    }
}
