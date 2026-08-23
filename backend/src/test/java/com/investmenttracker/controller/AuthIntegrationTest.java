package com.investmenttracker.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Objects;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

import com.investmenttracker.model.request.EncryptionRequest;
import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.request.RestartPasswordRequest;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class AuthIntegrationTest extends BaseIntegrationTest {

        private static String adminToken;
        private static String demoToken;
        private static final String PWD_VALIDA = "C4mb14m3!Urgente";

        private MockHttpServletRequestBuilder postJson(String url, String token, Object request) {
                Objects.requireNonNull(url, "URL no puede ser null");
                MediaType mediaType = Objects.requireNonNull(MediaType.APPLICATION_JSON, "MediaType no puede ser null");
                String jsonContent = Objects.requireNonNull(toJson(request), "Contenido no puede ser null");
                MockHttpServletRequestBuilder builder = post(url)
                                .contentType(mediaType)
                                .content(jsonContent);
                if (token != null) {
                        String authHeader = Objects.requireNonNull("Bearer " + token, "Auth header no puede ser null");
                        builder.header("Authorization", authHeader);
                }
                return Objects.requireNonNull(builder, "RequestBuilder no puede ser null");
        }

        private void perform(MockHttpServletRequestBuilder builder, int expectedStatus) throws Exception {
                Objects.requireNonNull(builder, "RequestBuilder no puede ser null");
                mockMvc.perform(builder).andExpect(status().is(expectedStatus));
        }

        private RestartPasswordRequest buildRestartRequest(String username, String email,
                        String nombreCompleto,
                        String nuevoPassword,
                        String repetirPassword) {
                return RestartPasswordRequest.builder()
                                .username(username).email(email).nombreCompleto(nombreCompleto)
                                .nuevoPassword(nuevoPassword).repetirNuevoPassword(repetirPassword)
                                .build();
        }

        private String extractToken(MvcResult result) throws Exception {
                return Objects.requireNonNull(
                                objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText(),
                                "Token no puede ser null");
        }

        // BLOQUE 0: VALIDACIONES
        @Test
        @Order(1)
        @DisplayName("TC-00: Login admin")
        void t00() throws Exception {
                printBanner("🟡 BLOQUE 0: VALIDACIONES");
                printStep("TC-00", "Login admin");
                LoginRequest r = LoginRequest.builder().username("admin").password("Admin123!").build();
                MvcResult result = mockMvc.perform(Objects.requireNonNull(postJson("/api/auth/login", null, r)))
                                .andExpect(status().isOk()).andExpect(jsonPath("$.username").value("admin"))
                                .andReturn();
                adminToken = extractToken(result);
                printStep("TC-00", "✅ EXITOSO");
        }

        @Test
        @Order(2)
        @DisplayName("TC-01: Caso feliz")
        void t01() throws Exception {
                printStep("TC-01", "Caso FELIZ");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                200);
                printStep("TC-01", "✅ 200");
        }

        @Test
        @Order(3)
        @DisplayName("TC-02: Campos vacíos")
        void t02() throws Exception {
                printStep("TC-02", "Vacíos");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("", "", "", "", "")), 400);
                printStep("TC-02", "✅ 400");
        }

        @Test
        @Order(4)
        @DisplayName("TC-03: Username vacío")
        void t03() throws Exception {
                printStep("TC-03", "Username vacío");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                400);
                printStep("TC-03", "✅ 400");
        }

        @Test
        @Order(5)
        @DisplayName("TC-04: Email vacío")
        void t04() throws Exception {
                printStep("TC-04", "Email vacío");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "", "Usuario Premium incognito", PWD_VALIDA,
                                                PWD_VALIDA)),
                                400);
                printStep("TC-04", "✅ 400");
        }

        @Test
        @Order(6)
        @DisplayName("TC-05: Nombre vacío")
        void t05() throws Exception {
                printStep("TC-05", "Nombre vacío");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "", PWD_VALIDA, PWD_VALIDA)),
                                400);
                printStep("TC-05", "✅ 400");
        }

        @Test
        @Order(7)
        @DisplayName("TC-06: No coinciden")
        void t06() throws Exception {
                printStep("TC-06", "No coinciden");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, "Diferente123!")),
                                400);
                printStep("TC-06", "✅ 400");
        }

        @Test
        @Order(8)
        @DisplayName("TC-07: Sin mayúscula")
        void t07() throws Exception {
                printStep("TC-07", "Sin mayúscula");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                "c4mb14m3!urgente", "c4mb14m3!urgente")),
                                400);
                printStep("TC-07", "✅ 400");
        }

        @Test
        @Order(9)
        @DisplayName("TC-08: Sin especial")
        void t08() throws Exception {
                printStep("TC-08", "Sin especial");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                "C4mb14m3Urgente", "C4mb14m3Urgente")),
                                400);
                printStep("TC-08", "✅ 400");
        }

        @Test
        @Order(10)
        @DisplayName("TC-09: Muy corta")
        void t09() throws Exception {
                printStep("TC-09", "< 8 caracteres");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                "C4m3!Ur", "C4m3!Ur")),
                                400);
                printStep("TC-09", "✅ 400");
        }

        @Test
        @Order(11)
        @DisplayName("TC-10: Comillas dobles")
        void t10() throws Exception {
                printStep("TC-10", "Comillas dobles");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                "C4mb\"14m3!Urgente", "C4mb\"14m3!Urgente")),
                                400);
                printStep("TC-10", "✅ 400");
        }

        @Test
        @Order(12)
        @DisplayName("TC-11: Comillas simples")
        void t11() throws Exception {
                printStep("TC-11", "Comillas simples");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                "C4mb'14m3!Urgente", "C4mb'14m3!Urgente")),
                                400);
                printStep("TC-11", "✅ 400");
        }

        @Test
        @Order(13)
        @DisplayName("TC-12: Email incorrecto")
        void t12() throws Exception {
                printStep("TC-12", "Email incorrecto");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "wrong@email.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                404);
                printStep("TC-12", "✅ 404");
        }

        @Test
        @Order(14)
        @DisplayName("TC-13: Nombre incorrecto")
        void t13() throws Exception {
                printStep("TC-13", "Nombre incorrecto");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Nombre Incorrecto",
                                                PWD_VALIDA, PWD_VALIDA)),
                                404);
                printStep("TC-13", "✅ 404");
        }

        @Test
        @Order(15)
        @DisplayName("TC-14: No existe")
        void t14() throws Exception {
                printStep("TC-14", "No existe");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("no_existe", "no@email.com", "No Existe", PWD_VALIDA, PWD_VALIDA)),
                                404);
                printStep("TC-14", "✅ 404");
        }

        @Test
        @Order(16)
        @DisplayName("TC-15: Email case")
        void t15() throws Exception {
                printStep("TC-15", "Email CASE");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42MRNOBODY42@GMAIL.COM", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                200);
                printStep("TC-15", "✅ 200");
                System.out.println("=".repeat(70));
                System.out.println("  🟡 FIN BLOQUE 0");
                System.out.println("=".repeat(70));
        }

        // BLOQUE 1: demo_user PRIMERO, luego admin
        @Test
        @Order(17)
        @DisplayName("TC-16: Login demo")
        void t16() throws Exception {
                printBanner("🔵 BLOQUE 1: demo_user PRIMERO");
                printStep("TC-16", "Login demo_user");
                LoginRequest r = LoginRequest.builder().username("demo_user").password("Demo123!").build();
                MvcResult result = mockMvc.perform(Objects.requireNonNull(postJson("/api/auth/login", null, r)))
                                .andExpect(status().isOk()).andExpect(jsonPath("$.username").value("demo_user"))
                                .andReturn();
                demoToken = extractToken(result);
                printStep("TC-16", "✅ EXITOSO");
        }

        @Test
        @Order(18)
        @DisplayName("TC-17: demo NO puede")
        void t17() throws Exception {
                printStep("TC-17", "demo_user restart-pass → 403");
                perform(postJson("/api/auth/restart-password", demoToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                403);
                printStep("TC-17", "✅ 403");
        }

        @Test
        @Order(19)
        @DisplayName("TC-18: Login admin")
        void t18() throws Exception {
                printStep("TC-18", "Login admin");
                LoginRequest r = LoginRequest.builder().username("admin").password("Admin123!").build();
                MvcResult result = mockMvc.perform(Objects.requireNonNull(postJson("/api/auth/login", null, r)))
                                .andExpect(status().isOk()).andExpect(jsonPath("$.username").value("admin"))
                                .andReturn();
                adminToken = extractToken(result);
                printStep("TC-18", "✅ EXITOSO");
        }

        @Test
        @Order(20)
        @DisplayName("TC-19: admin SÍ puede")
        void t19() throws Exception {
                printStep("TC-19", "admin restart-pass → 200");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                200);
                printStep("TC-19", "✅ 200");
                System.out.println("=".repeat(70));
                System.out.println("  🔵 FIN BLOQUE 1");
                System.out.println("=".repeat(70));
        }

        // BLOQUE 2: VICEVERSA
        @Test
        @Order(21)
        @DisplayName("TC-20: Login admin v2")
        void t20() throws Exception {
                printBanner("🔴 BLOQUE 2: VICEVERSA");
                printStep("TC-20", "Login admin");
                LoginRequest r = LoginRequest.builder().username("admin").password("Admin123!").build();
                MvcResult result = mockMvc.perform(Objects.requireNonNull(postJson("/api/auth/login", null, r)))
                                .andExpect(status().isOk()).andExpect(jsonPath("$.username").value("admin"))
                                .andReturn();
                adminToken = extractToken(result);
                printStep("TC-20", "✅");
        }

        @Test
        @Order(22)
        @DisplayName("TC-21: admin puede v2")
        void t21() throws Exception {
                printStep("TC-21", "admin restart-pass → 200");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                200);
                printStep("TC-21", "✅ 200");
        }

        @Test
        @Order(23)
        @DisplayName("TC-22: Login demo v2")
        void t22() throws Exception {
                printStep("TC-22", "Login demo_user");
                LoginRequest r = LoginRequest.builder().username("demo_user").password("Demo123!").build();
                MvcResult result = mockMvc.perform(Objects.requireNonNull(postJson("/api/auth/login", null, r)))
                                .andExpect(status().isOk()).andExpect(jsonPath("$.username").value("demo_user"))
                                .andReturn();
                demoToken = extractToken(result);
                printStep("TC-22", "✅");
        }

        @Test
        @Order(24)
        @DisplayName("TC-23: demo NO puede v2")
        void t23() throws Exception {
                printStep("TC-23", "demo_user restart-pass → 403");
                perform(postJson("/api/auth/restart-password", demoToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                403);
                printStep("TC-23", "✅ 403");
                System.out.println("=".repeat(70));
                System.out.println("  🔴 FIN BLOQUE 2");
                System.out.println("=".repeat(70));
        }

        // BLOQUE 3: ADICIONALES
        @Test
        @Order(25)
        @DisplayName("TC-24: Sin token")
        void t24() throws Exception {
                printBanner("🟢 BLOQUE 3: ADICIONALES");
                printStep("TC-24", "Sin token → 403");
                perform(postJson("/api/auth/restart-password", null,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                403);
                printStep("TC-24", "✅ 403");
        }

        @Test
        @Order(26)
        @DisplayName("TC-25: Cleanup")
        void t25() throws Exception {
                printStep("TC-25", "Cleanup");
                perform(postJson("/api/auth/restart-password", adminToken,
                                buildRestartRequest("incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                                                PWD_VALIDA, PWD_VALIDA)),
                                200);
                printStep("TC-25", "✅");
                System.out.println("=".repeat(70));
                System.out.println("  🏁 FIN");
                System.out.println("=".repeat(70));
        }

        // BLOQUE 4: LOGOUT COMBINADO (login + logout + verificación en un solo test)
        @Test
        @Order(27)
        @DisplayName("BLOQUE-4 | TC-26: Login + Logout + Token invalidado")
        void testLoginLogoutAndVerifyTokenInvalidated() throws Exception {
                printBanner("🟣 BLOQUE 4: PRUEBAS DE LOGOUT");
                printStep("TC-26", "Login admin para obtener token");
                LoginRequest r = LoginRequest.builder().username("admin").password("Admin123!").build();
                MockHttpServletRequestBuilder loginBuilder = postJson("/api/auth/login", null, r);
                MvcResult result = mockMvc.perform(Objects.requireNonNull(loginBuilder))
                                .andExpect(status().isOk())
                                .andReturn();
                String logoutToken = extractToken(result);
                printStep("TC-26", "✅ Token obtenido");

                printStep("TC-27", "Logout con token válido → 200");
                mockMvc.perform(post("/api/auth/logout")
                                .header("Authorization", "Bearer " + logoutToken))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.message").value("Sesión cerrada exitosamente"));
                printStep("TC-27", "✅ Logout exitoso");

                printStep("TC-28", "Usar token después de logout → 401");
                EncryptionRequest encRequest = EncryptionRequest.builder()
                                .cadena_string_a_encriptar("TestPostLogout123!")
                                .build();
                MockHttpServletRequestBuilder encBuilder = postJson("/api/encryption/encrypt", logoutToken, encRequest);
                mockMvc.perform(Objects.requireNonNull(encBuilder))
                                .andExpect(status().isUnauthorized());
                printStep("TC-28", "✅ Token invalidado (401)");
        }

        // Logout sin token
        @Test
        @Order(28)
        @DisplayName("BLOQUE-4 | TC-29: Logout sin token")
        void testLogoutWithoutToken() throws Exception {
                printStep("TC-29", "Logout sin token → 400");
                mockMvc.perform(post("/api/auth/logout"))
                                .andExpect(status().isBadRequest());
                printStep("TC-29", "✅ Sin token = 400");
        }

        // Logout con token inválido
        @Test
        @Order(29)
        @DisplayName("BLOQUE-4 | TC-30: Logout con token inválido")
        void testLogoutWithInvalidToken() throws Exception {
                printStep("TC-30", "Logout con token inválido → 4xx");
                mockMvc.perform(post("/api/auth/logout")
                                .header("Authorization", "Bearer token-invalido-123"))
                                .andExpect(status().is4xxClientError());
                printStep("TC-30", "✅ Token inválido rechazado");
                System.out.println("=".repeat(70));
                System.out.println("  🟣 FIN BLOQUE 4: LOGOUT");
                System.out.println("=".repeat(70));
        }

        @AfterEach
        void cleanUpAfterTest() {
                clearBlacklist();
        }

    }
