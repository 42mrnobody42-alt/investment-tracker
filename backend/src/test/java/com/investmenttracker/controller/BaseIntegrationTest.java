package com.investmenttracker.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.investmenttracker.component.TokenBlacklistComponent;
import com.investmenttracker.component.RateLimitComponent;
import com.investmenttracker.config.TestConfig;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Objects;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

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

    @BeforeEach
    void clearBlacklist() {
        tokenBlacklistComponent.clear();
        rateLimitComponent.clear();
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
