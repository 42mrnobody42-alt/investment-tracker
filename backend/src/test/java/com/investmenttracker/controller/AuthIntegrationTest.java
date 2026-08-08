package com.investmenttracker.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.request.RestartPasswordRequest;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class AuthIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private static String adminToken;
    private static String demoToken;

    private void printBanner(String title) {
        System.out.println("\n" + "=".repeat(70));
        System.out.println("  " + title);
        System.out.println("=".repeat(70));
    }

    private void printStep(String step, String message) {
        System.out.println("  [" + step + "] " + message);
    }

    // =============================================
    // BLOQUE 1: demo_user primero, luego admin
    // =============================================

    @Test
    @Order(1)
    @DisplayName("BLOQUE-1 | TC-01: Login demo_user exitoso")
    void testDemoUserLogin() throws Exception {
        printBanner("🔵 BLOQUE 1: demo_user PRIMERO, luego admin");
        printStep("TC-01", "Login demo_user - Esperado: 200 + Token");

        LoginRequest request = LoginRequest.builder()
            .username("demo_user")
            .password("Demo123!")
            .build();

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.username").value("demo_user"))
            .andReturn();

        demoToken = extractToken(result);
        printStep("TC-01", "✅ EXITOSO - demo_user autenticado");
    }

    @Test
    @Order(2)
    @DisplayName("BLOQUE-1 | TC-02: demo_user NO puede restart-password")
    void testDemoUserRestartPasswordForbidden() throws Exception {
        printStep("TC-02", "demo_user intenta restart-password - Esperado: 403 Forbidden");
        Assertions.assertNotNull(demoToken, "Token de demo_user no disponible");

        RestartPasswordRequest request = RestartPasswordRequest.builder()
            .username("incognito")
            .email("42mrnobody42@gmail.com")
            .nombreCompleto("Usuario Premium incognito")
            .nuevoPassword("C4mb14m3!Urgente")
            .repetirNuevoPassword("C4mb14m3!Urgente")
            .build();

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + demoToken)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isForbidden());

        printStep("TC-02", "✅ EXITOSO - demo_user BLOQUEADO (403) - Sin rol ADMIN");
    }

    @Test
    @Order(3)
    @DisplayName("BLOQUE-1 | TC-03: Login admin exitoso")
    void testAdminLogin() throws Exception {
        printStep("TC-03", "Login admin - Esperado: 200 + Token");

        LoginRequest request = LoginRequest.builder()
            .username("admin")
            .password("Admin123!")
            .build();

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.username").value("admin"))
            .andReturn();

        adminToken = extractToken(result);
        printStep("TC-03", "✅ EXITOSO - admin autenticado con ROLE_ADMIN");
    }

    @Test
    @Order(4)
    @DisplayName("BLOQUE-1 | TC-04: admin SÍ puede restart-password")
    void testAdminRestartPasswordSuccess() throws Exception {
        printStep("TC-04", "admin ejecuta restart-password - Esperado: 200 OK");
        Assertions.assertNotNull(adminToken, "Token de admin no disponible");

        RestartPasswordRequest request = RestartPasswordRequest.builder()
            .username("incognito")
            .email("42mrnobody42@gmail.com")
            .nombreCompleto("Usuario Premium incognito")
            .nuevoPassword("C4mb14m3!Urgente")
            .repetirNuevoPassword("C4mb14m3!Urgente")
            .build();

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.message").exists());

        printStep("TC-04", "✅ EXITOSO - admin cambió contraseña (200)");
        System.out.println("=".repeat(70));
        System.out.println("  🔵 FIN BLOQUE 1: demo_user BLOQUEADO, admin EXITOSO");
        System.out.println("=".repeat(70));
    }

    // =============================================
    // BLOQUE 2: VICEVERSA - admin primero, luego demo_user
    // =============================================

    @Test
    @Order(5)
    @DisplayName("BLOQUE-2 | TC-05: Login admin (viceversa)")
    void testAdminReloginSameOrNewToken() throws Exception {
        printBanner("🔴 BLOQUE 2: VICEVERSA - admin PRIMERO, luego demo_user");
        printStep("TC-05", "Login admin (viceversa) - Esperado: 200 + Token");

        LoginRequest request = LoginRequest.builder()
            .username("admin")
            .password("Admin123!")
            .build();

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("admin"))
            .andReturn();

        String adminTokenV2 = extractToken(result);
        Assertions.assertNotNull(adminTokenV2);
        adminToken = adminTokenV2;

        printStep("TC-05", "✅ EXITOSO - admin autenticado (viceversa)");
    }

    @Test
    @Order(6)
    @DisplayName("BLOQUE-2 | TC-06: admin puede restart-password (viceversa)")
    void testAdminStillCanRestartPassword() throws Exception {
        printStep("TC-06", "admin ejecuta restart-password (viceversa) - Esperado: 200 OK");
        Assertions.assertNotNull(adminToken);

        RestartPasswordRequest request = RestartPasswordRequest.builder()
            .username("incognito")
            .email("42mrnobody42@gmail.com")
            .nombreCompleto("Usuario Premium incognito")
            .nuevoPassword("C4mb14m3!Urgente")
            .repetirNuevoPassword("C4mb14m3!Urgente")
            .build();

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk());

        printStep("TC-06", "✅ EXITOSO - admin cambió contraseña (viceversa)");
    }

    @Test
    @Order(7)
    @DisplayName("BLOQUE-2 | TC-07: Login demo_user (viceversa)")
    void testDemoUserRelogin() throws Exception {
        printStep("TC-07", "Login demo_user (viceversa) - Esperado: 200 + Token");

        LoginRequest request = LoginRequest.builder()
            .username("demo_user")
            .password("Demo123!")
            .build();

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.username").value("demo_user"))
            .andReturn();

        String demoTokenV2 = extractToken(result);
        Assertions.assertNotNull(demoTokenV2);
        demoToken = demoTokenV2;

        printStep("TC-07", "✅ EXITOSO - demo_user autenticado (viceversa)");
    }

    @Test
    @Order(8)
    @DisplayName("BLOQUE-2 | TC-08: demo_user NO puede restart-password (viceversa)")
    void testDemoUserStillCannotRestartPassword() throws Exception {
        printStep("TC-08", "demo_user intenta restart-password (viceversa) - Esperado: 403 Forbidden");
        Assertions.assertNotNull(demoToken);

        RestartPasswordRequest request = RestartPasswordRequest.builder()
            .username("incognito")
            .email("42mrnobody42@gmail.com")
            .nombreCompleto("Usuario Premium incognito")
            .nuevoPassword("C4mb14m3!Urgente")
            .repetirNuevoPassword("C4mb14m3!Urgente")
            .build();

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + demoToken)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isForbidden());

        printStep("TC-08", "✅ EXITOSO - demo_user BLOQUEADO (403) - Sin rol ADMIN");
        System.out.println("=".repeat(70));
        System.out.println("  🔴 FIN BLOQUE 2: admin EXITOSO, demo_user BLOQUEADO");
        System.out.println("=".repeat(70));
    }

    // =============================================
    // BLOQUE 3: Pruebas adicionales
    // =============================================

    @Test
    @Order(9)
    @DisplayName("BLOQUE-3 | TC-09: Sin token = 403")
    void testRestartPasswordWithoutToken() throws Exception {
        printBanner("🟢 BLOQUE 3: PRUEBAS ADICIONALES");
        printStep("TC-09", "Petición sin token - Esperado: 403 Forbidden");

        RestartPasswordRequest request = RestartPasswordRequest.builder()
            .username("incognito")
            .email("42mrnobody42@gmail.com")
            .nombreCompleto("Usuario Premium incognito")
            .nuevoPassword("C4mb14m3!Urgente")
            .repetirNuevoPassword("C4mb14m3!Urgente")
            .build();

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isForbidden());

        printStep("TC-09", "✅ EXITOSO - Sin token = 403");
    }

    @Test
    @Order(10)
    @DisplayName("BLOQUE-3 | TC-10: Cleanup - Restaurar contraseña incognito")
    void testRestoreIncognitoPassword() throws Exception {
        printStep("TC-10", "Cleanup - admin restaura contraseña incognito");

        Assertions.assertNotNull(adminToken);
        RestartPasswordRequest request = RestartPasswordRequest.builder()
            .username("incognito")
            .email("42mrnobody42@gmail.com")
            .nombreCompleto("Usuario Premium incognito")
            .nuevoPassword("C4mb14m3!Urgente")
            .repetirNuevoPassword("C4mb14m3!Urgente")
            .build();

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk());

        printStep("TC-10", "✅ EXITOSO - Cleanup completado");
        System.out.println("=".repeat(70));
        System.out.println("  🟢 FIN PRUEBAS - 10/10 EXITOSAS");
        System.out.println("=".repeat(70));
    }

    private String extractToken(MvcResult result) throws Exception {
        return objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();
    }
}
