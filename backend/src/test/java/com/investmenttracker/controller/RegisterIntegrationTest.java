package com.investmenttracker.controller;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

import com.investmenttracker.config.TestConfig;
import com.investmenttracker.model.enums.Plan;
import com.investmenttracker.model.request.RegisterConfirmRequest;
import com.investmenttracker.model.request.RegisterRequest;
import com.investmenttracker.service.RegisterService;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class RegisterIntegrationTest extends BaseIntegrationTest {

        @Autowired
        private TestConfig testConfig;

        @Autowired
        private RegisterService registerService;

        private static final String PAIS_ID = "10000000-0001-0001-0001-000000000002";
        private static final long CELULAR_BASE = 3101234567L;

        private String adminToken;

        @BeforeAll
        void setupAdminToken() throws Exception {
                adminToken = loginAndGetToken("admin", "Admin123!");
                assertNotNull(adminToken, "Admin token no puede ser null");
        }

        @BeforeEach
        void cleanupUsers() throws Exception {
                String[] testUsers = {
                                testConfig.getRegisterUsernameFree(),
                                testConfig.getRegisterUsernamePremium(),
                                "test_mismatch",
                                "test_weak",
                                "test_expired",
                                "test_invalid"
                };
                for (String username : testUsers) {
                        try {
                                MvcResult result = mockMvc.perform(delete("/api/test/delete-user/" + username)
                                                .header("Authorization", "Bearer " + adminToken))
                                                .andReturn();
                                if (result.getResponse().getStatus() == 200) {
                                        printStep("CLEANUP", "Eliminado: " + username);
                                } else {
                                        printStep("CLEANUP", "Usuario no encontrado (ignorado): " + username);
                                }
                        } catch (Exception e) {
                                printStep("CLEANUP", "Error al limpiar " + username + ": " + e.getMessage());
                        }
                }
        }

        // =============================================
        // TEST DATA BUILDERS
        // =============================================

        private RegisterRequest buildRegisterRequest(String username, String email, Plan plan, long celularSuffix) {
                long celular = CELULAR_BASE + celularSuffix;
                return RegisterRequest.builder()
                                .username(username)
                                .email(email)
                                .nombreCompleto(testConfig.getRegisterNombre())
                                .password(testConfig.getRegisterPassword())
                                .repeatPassword(testConfig.getRegisterPassword())
                                .celular(celular)
                                .paisId(UUID.fromString(PAIS_ID))
                                .plan(plan)
                                .build();
        }

        private RegisterConfirmRequest buildConfirmRequest(String username, String email, Plan plan, String token,
                        long celularSuffix) {
                long celular = CELULAR_BASE + celularSuffix;
                return RegisterConfirmRequest.builder()
                                .username(username)
                                .email(email)
                                .nombreCompleto(testConfig.getRegisterNombre())
                                .celular(celular)
                                .paisId(UUID.fromString(PAIS_ID))
                                .plan(plan)
                                .token(token)
                                .build();
        }

        // =============================================
        // 1. REGISTRO FREE - FLUJO COMPLETO
        // =============================================
        @Test
        @Order(1)
        @DisplayName("REG-01: Registrar usuario FREE (flujo completo)")
        void testRegisterFreeFullFlow() throws Exception {
                printBanner("🔵 PRUEBAS DE REGISTRO - USUARIO FREE");
                String username = testConfig.getRegisterUsernameFree();
                String email = testConfig.getRegisterEmailFree();
                Plan plan = Plan.FREE;
                long celularSuffix = 1;

                // PASO 1: Solicitar registro
                printStep("REG-01.1", "Solicitar registro para " + username);
                RegisterRequest request = buildRegisterRequest(username, email, plan, celularSuffix);
                mockMvc.perform(post("/api/auth/register/request")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(request)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.code").value("REG-0001"));
                printSubStep("✅ Solicitud exitosa");

                // PASO 2: Obtener token real
                String realToken = registerService.getTokenForTest(username);
                assertNotNull(realToken, "El token no debe ser null");
                printSubStep("Token real: " + realToken);

                // PASO 3: Confirmar registro
                printStep("REG-01.2", "Confirmar registro con token real");
                RegisterConfirmRequest confirmRequest = buildConfirmRequest(username, email, plan, realToken,
                                celularSuffix);
                mockMvc.perform(post("/api/auth/register/confirm")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(confirmRequest)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.code").value("REG-0002"));
                printSubStep("✅ Registro confirmado");

                // PASO 4: Login
                printStep("REG-01.3", "Login con " + username);
                MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("{\"username\":\"" + username + "\",\"password\":\""
                                                + testConfig.getRegisterPassword() + "\"}"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.token").exists())
                                .andExpect(jsonPath("$.username").value(username))
                                .andExpect(jsonPath("$.celular").exists())
                                .andExpect(jsonPath("$.pais").exists())
                                .andReturn();
                printSubStep("✅ Login exitoso");

                // PASO 5: Borrado lógico
                printStep("REG-01.4", "Borrado lógico de " + username);
                String userToken = objectMapper.readTree(loginResult.getResponse().getContentAsString()).get("token")
                                .asText();
                mockMvc.perform(post("/api/auth/delete-account")
                                .header("Authorization", "Bearer " + userToken)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("{\"username\":\"" + username + "\"}"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.code").value("REG-0003"));
                printSubStep("✅ Cuenta desactivada");

                // PASO 6: Borrado definitivo
                printStep("REG-01.5", "Borrado definitivo de " + username);
                mockMvc.perform(delete("/api/test/delete-user/" + username)
                                .header("Authorization", "Bearer " + adminToken))
                                .andExpect(status().isOk());
                printSubStep("✅ Usuario eliminado en cascada");

                printStep("REG-01", "✅ Flujo completo FREE exitoso");
                System.out.println("=".repeat(70));
                System.out.println("  🔵 FIN REGISTRO FREE");
                System.out.println("=".repeat(70));
        }

        // =============================================
        // 2. REGISTRO PREMIUM - FLUJO COMPLETO
        // =============================================
        @Test
        @Order(2)
        @DisplayName("REG-02: Registrar usuario PREMIUM (flujo completo)")
        void testRegisterPremiumFullFlow() throws Exception {
                printBanner("🟢 PRUEBAS DE REGISTRO - USUARIO PREMIUM");
                String username = testConfig.getRegisterUsernamePremium();
                String email = testConfig.getRegisterEmailPremium();
                Plan plan = Plan.PREMIUM;
                long celularSuffix = 2;

                // PASO 1: Solicitar registro
                printStep("REG-02.1", "Solicitar registro para " + username);
                RegisterRequest request = buildRegisterRequest(username, email, plan, celularSuffix);
                mockMvc.perform(post("/api/auth/register/request")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(request)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.code").value("REG-0001"));
                printSubStep("✅ Solicitud exitosa");

                // PASO 2: Obtener token real
                String realToken = registerService.getTokenForTest(username);
                assertNotNull(realToken, "El token no debe ser null");
                printSubStep("Token real: " + realToken);

                // PASO 3: Confirmar registro
                printStep("REG-02.2", "Confirmar registro con token real");
                RegisterConfirmRequest confirmRequest = buildConfirmRequest(username, email, plan, realToken,
                                celularSuffix);
                mockMvc.perform(post("/api/auth/register/confirm")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(confirmRequest)))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.code").value("REG-0002"));
                printSubStep("✅ Registro confirmado");

                // PASO 4: Login
                printStep("REG-02.3", "Login con " + username);
                MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("{\"username\":\"" + username + "\",\"password\":\""
                                                + testConfig.getRegisterPassword() + "\"}"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.token").exists())
                                .andExpect(jsonPath("$.username").value(username))
                                .andExpect(jsonPath("$.celular").exists())
                                .andExpect(jsonPath("$.pais").exists())
                                .andReturn();
                printSubStep("✅ Login exitoso");

                // PASO 5: Borrado lógico
                printStep("REG-02.4", "Borrado lógico de " + username);
                String userToken = objectMapper.readTree(loginResult.getResponse().getContentAsString()).get("token")
                                .asText();
                mockMvc.perform(post("/api/auth/delete-account")
                                .header("Authorization", "Bearer " + userToken)
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("{\"username\":\"" + username + "\"}"))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.code").value("REG-0003"));
                printSubStep("✅ Cuenta desactivada");

                // PASO 6: Borrado definitivo
                printStep("REG-02.5", "Borrado definitivo de " + username);
                mockMvc.perform(delete("/api/test/delete-user/" + username)
                                .header("Authorization", "Bearer " + adminToken))
                                .andExpect(status().isOk());
                printSubStep("✅ Usuario eliminado en cascada");

                printStep("REG-02", "✅ Flujo completo PREMIUM exitoso");
                System.out.println("=".repeat(70));
                System.out.println("  🟢 FIN REGISTRO PREMIUM");
                System.out.println("=".repeat(70));
        }

        // =============================================
        // 3. CASOS DE FALLO
        // =============================================
        @Test
        @Order(3)
        @DisplayName("REG-03: Registro - campos vacíos")
        void testRegisterEmptyFields() throws Exception {
                printBanner("🔴 CASOS DE FALLO - REGISTRO");
                printStep("REG-03", "Registro con campos vacíos → 400");

                RegisterRequest request = RegisterRequest.builder()
                                .username("")
                                .email("")
                                .nombreCompleto("")
                                .password("")
                                .repeatPassword("")
                                .celular(null)
                                .paisId(null)
                                .plan(null)
                                .build();

                mockMvc.perform(post("/api/auth/register/request")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(request)))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.code").value("VAL-005"));
                printStep("REG-03", "✅ Campos vacíos rechazados");
                System.out.println("=".repeat(70));
        }

        @Test
        @Order(4)
        @DisplayName("REG-04: Registro - contraseñas no coinciden")
        void testRegisterPasswordsDoNotMatch() throws Exception {
                printStep("REG-04", "Contraseñas no coinciden → 400");

                RegisterRequest request = buildRegisterRequest(
                                "test_mismatch",
                                "test_mismatch@email.com",
                                Plan.FREE,
                                3);
                request.setRepeatPassword("Different123!");

                mockMvc.perform(post("/api/auth/register/request")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(request)))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.code").value("REG-008"));
                printStep("REG-04", "✅ Contraseñas diferentes rechazadas");
                // Limpiar
                mockMvc.perform(delete("/api/test/delete-user/test_mismatch")
                                .header("Authorization", "Bearer " + adminToken));
        }

        @Test
        @Order(5)
        @DisplayName("REG-05: Registro - contraseña débil")
        void testRegisterWeakPassword() throws Exception {
                printStep("REG-05", "Contraseña débil → 400");

                RegisterRequest request = buildRegisterRequest(
                                "test_weak",
                                "test_weak@email.com",
                                Plan.FREE,
                                4);
                request.setPassword("weak");
                request.setRepeatPassword("weak");

                mockMvc.perform(post("/api/auth/register/request")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(request)))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.code").value("PWD-002"));
                printStep("REG-05", "✅ Contraseña débil rechazada");
                // Limpiar
                mockMvc.perform(delete("/api/test/delete-user/test_weak")
                                .header("Authorization", "Bearer " + adminToken));
        }

        @Test
        @Order(6)
        @DisplayName("REG-06: Registro - username ya existe")
        void testRegisterUsernameExists() throws Exception {
                printStep("REG-06", "Username ya existe → 409");

                RegisterRequest request = buildRegisterRequest(
                                "demo_user",
                                "new_email@email.com",
                                Plan.FREE,
                                5);

                mockMvc.perform(post("/api/auth/register/request")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(request)))
                                .andExpect(status().isConflict())
                                .andExpect(jsonPath("$.code").value("REG-001"));
                printStep("REG-06", "✅ Username duplicado rechazado");
        }

        @Test
        @Order(7)
        @DisplayName("REG-07: Registro - email ya existe")
        void testRegisterEmailExists() throws Exception {
                printStep("REG-07", "Email ya existe → 409");

                RegisterRequest request = buildRegisterRequest(
                                "new_user",
                                "demo@investment-tracker.com",
                                Plan.FREE,
                                6);

                mockMvc.perform(post("/api/auth/register/request")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(request)))
                                .andExpect(status().isConflict())
                                .andExpect(jsonPath("$.code").value("REG-002"));
                printStep("REG-07", "✅ Email duplicado rechazado");
                System.out.println("=".repeat(70));
        }

        @Test
        @Order(8)
        @DisplayName("REG-08: Registro - token inválido")
        void testRegisterInvalidToken() throws Exception {
                printStep("REG-08", "Confirmación con token inválido → 400");

                String username = "test_invalid";
                String email = "test_invalid@email.com";
                Plan plan = Plan.FREE;
                long celularSuffix = 7;

                RegisterRequest request = buildRegisterRequest(username, email, plan, celularSuffix);
                mockMvc.perform(post("/api/auth/register/request")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(request)))
                                .andExpect(status().isOk());

                RegisterConfirmRequest confirmRequest = buildConfirmRequest(username, email, plan, "999999",
                                celularSuffix);
                mockMvc.perform(post("/api/auth/register/confirm")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(toJson(confirmRequest)))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.code").value("REG-005"));
                printStep("REG-08", "✅ Token inválido rechazado");
                // Limpiar
                mockMvc.perform(delete("/api/test/delete-user/" + username)
                                .header("Authorization", "Bearer " + adminToken));
        }

        // =============================================
        // CLEANUP FINAL
        // =============================================
        @AfterAll
        void finalCleanup() throws Exception {
                printBanner("🧹 LIMPIEZA FINAL");
                String[] testUsers = {
                                testConfig.getRegisterUsernameFree(),
                                testConfig.getRegisterUsernamePremium(),
                                "test_mismatch",
                                "test_weak",
                                "test_expired",
                                "test_invalid"
                };
                for (String username : testUsers) {
                        try {
                                MvcResult result = mockMvc.perform(delete("/api/test/delete-user/" + username)
                                                .header("Authorization", "Bearer " + adminToken))
                                                .andReturn();
                                if (result.getResponse().getStatus() == 200) {
                                        printStep("CLEANUP", "Eliminado: " + username);
                                } else {
                                        printStep("CLEANUP", "Usuario no encontrado (ignorado): " + username);
                                }
                        } catch (Exception e) {
                                printStep("CLEANUP", "Error al limpiar " + username + ": " + e.getMessage());
                        }
                }
                System.out.println("=".repeat(70));
                System.out.println("  🧹 FIN LIMPIEZA");
                System.out.println("=".repeat(70));
        }
}
