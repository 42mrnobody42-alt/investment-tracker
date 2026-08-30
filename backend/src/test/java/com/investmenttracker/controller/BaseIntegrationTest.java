package com.investmenttracker.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

import java.util.Objects;

import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.investmenttracker.component.RateLimitComponent;
import com.investmenttracker.component.TokenBlacklistComponent;
import com.investmenttracker.config.TestConfig;

@SpringBootTest
@AutoConfigureMockMvc
public abstract class BaseIntegrationTest {

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper objectMapper;

    @Autowired
    protected TestConfig testConfig;

    @Autowired
    protected TokenBlacklistComponent tokenBlacklistComponent;

    @Autowired
    protected RateLimitComponent rateLimitComponent;

    @Autowired
    protected com.investmenttracker.component.RefreshTokenComponent refreshTokenComponent;

    /**
     * Limpia los estados globales antes de cada prueba para garantizar
     * independencia.
     * <p>
     * Se limpian la blacklist de tokens JWT y el rate limiter para evitar
     * interferencias
     * entre pruebas de autenticación y control de acceso.
     * <p>
     * <b>Nota importante:</b> Los refresh tokens NO se limpian automáticamente.
     * Esto es intencional para permitir que las pruebas de refresco de token
     * (como {@code RefreshTokenIntegrationTest}) puedan generar un refresh token
     * en una prueba y reutilizarlo en pruebas posteriores dentro de la misma suite,
     * verificando así su validez y renovación.
     * <p>
     * Si una prueba específica necesita limpiar los refresh tokens (por ejemplo,
     * para simular un logout completo o resetear el estado), debe llamar
     * explícitamente al método {@link #clearRefreshTokens()} desde el propio test.
     */
    @BeforeEach
    protected void clearBlacklist() {
        tokenBlacklistComponent.clear();
        rateLimitComponent.clear();
        // refreshTokenComponent.clear(); // <-- Eliminado
    }

    protected String loginAndGetToken(String username, String password) throws Exception {
        String body = String.format("{\"username\":\"%s\",\"password\":\"%s\"}", username, password);

        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content(Objects.requireNonNull(body, "Body no puede ser null")))
                .andReturn();

        return Objects.requireNonNull(
                objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText(),
                "Token no puede ser null");
    }

    protected String toJson(Object obj) {
        try {
            return Objects.requireNonNull(objectMapper.writeValueAsString(obj), "JSON no puede ser null");
        } catch (Exception e) {
            throw new RuntimeException("Error serializando JSON", e);
        }
    }

    protected void printBanner(String title) {
        System.out.println("\n" + "=".repeat(70));
        System.out.println("  " + title);
        System.out.println("=".repeat(70));
    }

    protected void printStep(String step, String message) {
        System.out.println("  [" + step + "] " + message);
    }

    protected void printSubStep(String message) {
        System.out.println("     ↳ " + message);
    }
}
