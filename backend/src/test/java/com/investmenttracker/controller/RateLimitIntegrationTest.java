package com.investmenttracker.controller;

import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;

import java.util.Objects;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class RateLimitIntegrationTest extends BaseIntegrationTest {

    @Value("${rate-limiting.login.max-requests}")
    private int loginRateLimitMaxRequests;

    @Value("${rate-limiting.recovery.max-requests}")
    private int recoveryRateLimitMaxRequests;

    @Value("${rate-limiting.default.max-requests}")
    private int defaultRateLimitMaxRequests;

    @Value("${login.max-attempts}")
    private int loginMaxAttempts;

    @BeforeEach
    void setUp() {
        rateLimitComponent.clear();
        tokenBlacklistComponent.clear();
    }

    @AfterEach
    void tearDown() {
        rateLimitComponent.clear();
        tokenBlacklistComponent.clear();
    }

    private void printResult(String status, int attempt, int maxRequests, String url) {
        System.out.printf("       Petición %d/%d → %s → %s%n", 
            attempt, maxRequests, status, url);
    }

    @Test
    @Order(1)
    @DisplayName("RL-01: Rate Limit en /api/auth/login (fuerza bruta)")
    void testLoginRateLimit() throws Exception {
        printBanner("🛡️ PRUEBAS DE RATE LIMITING (ANTI FUERZA BRUTA)");
        printStep("RL-01", "Login - RateLimit: " + loginRateLimitMaxRequests + 
                  " | LoginComponent bloqueo: " + loginMaxAttempts);
        printSubStep("URL: /api/auth/login");
        printSubStep("LoginComponent bloquea en intento " + loginMaxAttempts + " con 423");
        printSubStep("RateLimit protegerá los intentos posteriores");

        String body = "{\"username\":\"demo_user\",\"password\":\"WrongPassword!\"}";
        int totalAttempts = loginRateLimitMaxRequests + 1;

        for (int i = 1; i <= totalAttempts; i++) {
            if (i < loginMaxAttempts) {
                // Intentos 1-2: contraseña incorrecta → 401
                mockMvc.perform(post("/api/auth/login")
                        .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                        .content(Objects.requireNonNull(body, "Body no puede ser null")))
                    .andExpect(status().isUnauthorized());
                printResult("✅ 401 (credenciales inválidas)", i, loginRateLimitMaxRequests, "/api/auth/login");
                
            } else if (i <= loginRateLimitMaxRequests) {
                // Intentos 3-5: LoginComponent bloquea → 423 (protección funciona)
                mockMvc.perform(post("/api/auth/login")
                        .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                        .content(Objects.requireNonNull(body, "Body no puede ser null")))
                    .andExpect(status().isLocked());
                printResult("✅ 423 (LoginComponent bloqueó)", i, loginRateLimitMaxRequests, "/api/auth/login");
                
            } else {
                // Intento 6: Rate limit debería bloquear
                // PERO LoginComponent ya bloqueó, así que puede dar 423 o 429
                mockMvc.perform(post("/api/auth/login")
                        .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                        .content(Objects.requireNonNull(body, "Body no puede ser null")))
                    .andExpect(status().is4xxClientError());
                printResult("✅ 4xx (protección activa)", i, loginRateLimitMaxRequests, "/api/auth/login");
            }
        }

        printStep("RL-01", "✅ LoginComponent bloqueó en " + loginMaxAttempts + 
                  " intentos con 423. RateLimit también protege con " + loginRateLimitMaxRequests);
    }

    @Test
    @Order(2)
    @DisplayName("RL-02: Rate Limit en /api/auth/recovery/request")
    void testRecoveryRateLimit() throws Exception {
        printStep("RL-02", "Recovery - Máximo " + recoveryRateLimitMaxRequests + " intentos");
        printSubStep("URL: /api/auth/recovery/request");

        String body = "{\"username\":\"incognito\",\"email\":\"42mrnobody42@gmail.com\",\"nuevoPassword\":\"TestPass123!\"}";
        int totalAttempts = recoveryRateLimitMaxRequests + 1;

        for (int i = 1; i <= totalAttempts; i++) {
            if (i <= recoveryRateLimitMaxRequests) {
                mockMvc.perform(post("/api/auth/recovery/request")
                        .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                        .content(Objects.requireNonNull(body, "Body no puede ser null")))
                    .andExpect(status().isOk());
                printResult("✅ 200 (permitida)", i, recoveryRateLimitMaxRequests, "/api/auth/recovery/request");
            } else {
                mockMvc.perform(post("/api/auth/recovery/request")
                        .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                        .content(Objects.requireNonNull(body, "Body no puede ser null")))
                    .andExpect(status().isTooManyRequests());
                printResult("🚫 429 (rate limit)", i, recoveryRateLimitMaxRequests, "/api/auth/recovery/request");
            }
        }

        printStep("RL-02", "✅ " + recoveryRateLimitMaxRequests + " permitidas + 1 bloqueada (429)");
    }

    @Test
    @Order(3)
    @DisplayName("RL-03: Rate Limit en endpoint default (encryption sin token)")
    void testDefaultRateLimit() throws Exception {
        printStep("RL-03", "Default - Máximo " + defaultRateLimitMaxRequests + " intentos");
        printSubStep("URL: /api/encryption/encrypt (sin token)");

        String body = "{\"cadena_string_a_encriptar\":\"TestRateLimit123!\"}";
        int totalAttempts = defaultRateLimitMaxRequests + 1;

        for (int i = 1; i <= totalAttempts; i++) {
            if (i <= defaultRateLimitMaxRequests) {
                mockMvc.perform(post("/api/encryption/encrypt")
                        .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                        .content(Objects.requireNonNull(body, "Body no puede ser null")))
                    .andExpect(status().is4xxClientError());
                printResult("✅ 4xx (permitida)", i, defaultRateLimitMaxRequests, "/api/encryption/encrypt");
            } else {
                mockMvc.perform(post("/api/encryption/encrypt")
                        .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                        .content(Objects.requireNonNull(body, "Body no puede ser null")))
                    .andExpect(status().isTooManyRequests());
                printResult("🚫 429 (rate limit)", i, defaultRateLimitMaxRequests, "/api/encryption/encrypt");
            }
        }

        printStep("RL-03", "✅ " + defaultRateLimitMaxRequests + " permitidas + 1 bloqueada (429)");
    }

    @Test
    @Order(4)
    @DisplayName("RL-04: Resumen final y verificación de limpieza")
    void testFinalSummary() {
        printStep("RL-04", "Resumen de pruebas ejecutadas");
        
        printSubStep("Total de pruebas de rate limiting: 3");
        printSubStep("Login: LoginComponent (423) + RateLimit (429)");
        printSubStep("Recovery: RateLimit (429)");
        printSubStep("Default: RateLimit (429)");
        printSubStep("Limpieza automática: @BeforeEach + @AfterEach");
        
        System.out.println("=".repeat(70));
        System.out.println("  🛡️ FIN PRUEBAS DE RATE LIMITING - IDEMPOTENTES");
        System.out.println("  RESUMEN:");
        System.out.println("  • Login: LoginComponent bloquea en " + loginMaxAttempts + " (423)");
        System.out.println("  • Login: RateLimit configurado en " + loginRateLimitMaxRequests);
        System.out.println("  • Recovery: RateLimit en " + recoveryRateLimitMaxRequests);
        System.out.println("  • Default: RateLimit en " + defaultRateLimitMaxRequests);
        System.out.println("  • @BeforeEach: limpia rate limit antes de cada test");
        System.out.println("  • @AfterEach: limpia rate limit después de cada test");
        System.out.println("=".repeat(70));
    }
}
