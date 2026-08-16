package com.investmenttracker.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.investmenttracker.model.request.EncryptionRequest;
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
class EncryptionIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private static String adminToken;
    private static String demoToken;
    private static String encryptedText;

    private void printBanner(String title) {
        System.out.println("\n" + "=".repeat(70));
        System.out.println("  " + title);
        System.out.println("=".repeat(70));
    }

    private void printStep(String step, String message) {
        System.out.println("  [" + step + "] " + message);
    }

    private String toJson(Object obj) {
        try {
            return Objects.requireNonNull(objectMapper.writeValueAsString(obj));
        } catch (Exception e) {
            throw new RuntimeException("Error serializando JSON", e);
        }
    }

    private String extractToken(MvcResult result) throws Exception {
        return Objects.requireNonNull(
            objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText());
    }

    @Test
    @Order(1)
    @DisplayName("EC-01: Login admin para pruebas")
    void testAdminLogin() throws Exception {
        printBanner("🔐 PRUEBAS DE ENCRIPTACIÓN/DESENCRIPTACIÓN AES");
        printStep("EC-01", "Login admin");
        
        MvcResult result = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"admin\",\"password\":\"Admin123!\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists())
            .andReturn();
        
        adminToken = extractToken(result);
        printStep("EC-01", "✅ Token admin obtenido");
    }

    @Test
    @Order(2)
    @DisplayName("EC-02: Encriptar texto exitosamente")
    void testEncryptSuccess() throws Exception {
        printStep("EC-02", "Encriptar 'MiPasswordSecreto123!'");
        
        EncryptionRequest request = EncryptionRequest.builder()
            .cadena_string_a_encriptar("MiPasswordSecreto123!")
            .build();
        
        MvcResult result = mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(toJson(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.textoEncriptado").exists())
            .andExpect(jsonPath("$.textoEncriptado").isNotEmpty())
            .andReturn();
        
        encryptedText = objectMapper.readTree(result.getResponse().getContentAsString())
            .get("textoEncriptado").asText();
        
        printStep("EC-02", "✅ Texto encriptado: " + encryptedText.substring(0, 30) + "...");
    }

    @Test
    @Order(3)
    @DisplayName("EC-03: Desencriptar texto exitosamente")
    void testDecryptSuccess() throws Exception {
        printStep("EC-03", "Desencriptar el texto anterior");
        
        EncryptionRequest request = EncryptionRequest.builder()
            .cadena_string_a_encriptar(encryptedText)
            .build();
        
        MvcResult result = mockMvc.perform(post("/api/encryption/decrypt")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(toJson(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.textoDesencriptado").value("MiPasswordSecreto123!"))
            .andReturn();
        
        printStep("EC-03", "✅ Texto desencriptado correctamente");
    }

    @Test
    @Order(4)
    @DisplayName("EC-04: Encriptar con texto null - debe fallar")
    void testEncryptNullText() throws Exception {
        printStep("EC-04", "Encriptar texto null → 400/500");
        
        mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content("{}"))
            .andExpect(status().isBadRequest());
        
        printStep("EC-04", "✅ Texto null rechazado");
    }

    @Test
    @Order(5)
    @DisplayName("EC-05: Encriptar sin token - debe dar 403")
    void testEncryptWithoutToken() throws Exception {
        printStep("EC-05", "Sin token → 403");
        
        EncryptionRequest request = EncryptionRequest.builder()
            .cadena_string_a_encriptar("Test123!")
            .build();
        
        mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(MediaType.APPLICATION_JSON)
                .content(toJson(request)))
            .andExpect(status().isForbidden());
        
        printStep("EC-05", "✅ Sin token = 403");
    }

    @Test
    @Order(6)
    @DisplayName("EC-06: Login demo_user y verificar que NO puede encriptar")
    void testDemoUserCannotEncrypt() throws Exception {
        printStep("EC-06", "Login demo_user y probar encriptación → 403");
        
        MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"username\":\"demo_user\",\"password\":\"Demo123!\"}"))
            .andExpect(status().isOk())
            .andReturn();
        
        demoToken = extractToken(loginResult);
        
        EncryptionRequest request = EncryptionRequest.builder()
            .cadena_string_a_encriptar("TestDemo!")
            .build();
        
        mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + demoToken)
                .content(toJson(request)))
            .andExpect(status().isForbidden());
        
        printStep("EC-06", "✅ demo_user BLOQUEADO (403) - No tiene ROLE_ADMIN");
        System.out.println("=".repeat(70));
        System.out.println("  🔐 FIN PRUEBAS DE ENCRIPTACIÓN");
        System.out.println("=".repeat(70));
    }
}
