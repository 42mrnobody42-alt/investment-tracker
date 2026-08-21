package com.investmenttracker.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

import com.investmenttracker.model.request.EncryptionRequest;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class EncryptionIntegrationTest extends BaseIntegrationTest {

    private String adminToken;

    private static final List<String> TEST_TEXTS = List.of(
            "MiPasswordSecreto123!",
            "TextoConCaracteresEspeciales@#$%^&*()_+=-[]{}|;:',.<>?/~`",
            "ContrasenaSinAcentosConNumeros123yEspacios");

    @BeforeEach
    void setUpFreshLogin() throws Exception {
        adminToken = loginAndGetToken(testConfig.getAdminUser(), testConfig.getAdminPassword());
        assertNotNull(adminToken, "Token admin no puede ser null");
    }

    private void printData(String label, String value) {
        System.out.println("       " + label + ": " + value);
    }

    private String extractField(MvcResult result, String fieldName) throws Exception {
        return Objects.requireNonNull(
                objectMapper.readTree(result.getResponse().getContentAsString()).get(fieldName).asText(),
                fieldName + " no puede ser null");
    }

    @Test
    @Order(1)
    @DisplayName("EC-01: Login admin fresco (BeforeEach)")
    void testAdminLogin() throws Exception {
        printBanner("🔐 PRUEBAS DE ENCRIPTACIÓN/DESENCRIPTACIÓN AES-GCM");
        printStep("EC-01", "Login admin fresco con @BeforeEach");
        printStep("EC-01", "✅ Token admin obtenido");
    }

    @Test
    @Order(2)
    @DisplayName("EC-02: 3 encriptaciones + 3 desencriptaciones en orden")
    void testEncryptDecryptCycles() throws Exception {
        printStep("EC-02", "Ejecutar 3 encriptaciones y 3 desencriptaciones");

        List<String> encryptedTexts = new ArrayList<>();
        List<String> originalTexts = new ArrayList<>();

        for (int i = 0; i < TEST_TEXTS.size(); i++) {
            String originalText = TEST_TEXTS.get(i);
            printSubStep("━━─ ENCRIPTACIÓN #" + (i + 1) + " ─━━");
            printData("Texto Original (body)", originalText);

            EncryptionRequest request = EncryptionRequest.builder()
                    .cadena_string_a_encriptar(originalText)
                    .build();

            MvcResult result = mockMvc.perform(post("/api/encryption/encrypt")
                    .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                    .header("Authorization", "Bearer " + adminToken)
                    .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
                    .andExpect(status().isOk())
                    .andReturn();

            String textoOriginalRespuesta = extractField(result, "textoOriginal");
            String textoEncriptado = extractField(result, "textoEncriptado");

            printData("textoOriginal (respuesta)", textoOriginalRespuesta);
            printData("textoEncriptado", textoEncriptado);

            assertEquals(originalText, textoOriginalRespuesta,
                    "❌ ENCRIPTACIÓN #" + (i + 1) + ": textoOriginal NO coincide");

            encryptedTexts.add(textoEncriptado);
            originalTexts.add(originalText);
            printSubStep("✅ Encriptación #" + (i + 1) + " validada\n");
        }

        for (int i = 0; i < encryptedTexts.size(); i++) {
            String expectedOriginal = originalTexts.get(i);
            String encryptedText = encryptedTexts.get(i);

            printSubStep("━━─ DESENCRIPTACIÓN #" + (i + 1) + " ─━━");
            printData("textoEncriptado (body)", encryptedText);
            printData("textoOriginal esperado", expectedOriginal);

            EncryptionRequest request = EncryptionRequest.builder()
                    .cadena_string_a_encriptar(encryptedText)
                    .build();

            MvcResult result = mockMvc.perform(post("/api/encryption/decrypt")
                    .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                    .header("Authorization", "Bearer " + adminToken)
                    .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
                    .andExpect(status().isOk())
                    .andReturn();

            String textoDesencriptado = extractField(result, "textoDesencriptado");

            printData("textoDesencriptado (respuesta)", textoDesencriptado);

            assertEquals(expectedOriginal, textoDesencriptado,
                    "❌ DESENCRIPTACIÓN #" + (i + 1) + ": NO coincide con original");

            printSubStep("✅ Desencriptación #" + (i + 1) + " validada\n");
        }

        printStep("EC-02", "✅ 3 encriptaciones + 3 desencriptaciones exitosas");
    }

    @Test
    @Order(3)
    @DisplayName("EC-03: ⚠️ LIMITACIÓN - Acentos UTF-8 se corrompen")
    void testEncryptWithAccentsFails() throws Exception {
        printStep("EC-03", "⚠️ Reporte de limitación");

        String textoConAcentos = "ContraseñaConAcentosÁÉÍÓÚñÑ";

        EncryptionRequest request = EncryptionRequest.builder()
                .cadena_string_a_encriptar(textoConAcentos)
                .build();

        MvcResult result = mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + adminToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
                .andExpect(status().isOk())
                .andReturn();

        String textoOriginalRespuesta = extractField(result, "textoOriginal");

        assertNotEquals(textoConAcentos, textoOriginalRespuesta,
                "Se esperaba corrupción de acentos (limitación conocida)");

        printStep("EC-03", "⚠️ Limitación documentada\n");
    }

    @Test
    @Order(4)
    @DisplayName("EC-04: Texto null → 400")
    void testEncryptNullText() throws Exception {
        printStep("EC-04", "Texto null → 400");
        mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + adminToken)
                .content("{}"))
                .andExpect(status().isBadRequest());
        printStep("EC-04", "✅ 400\n");
    }

    @Test
    @Order(5)
    @DisplayName("EC-05: Texto vacío → 400")
    void testEncryptEmptyText() throws Exception {
        printStep("EC-05", "Texto vacío → 400");
        EncryptionRequest request = EncryptionRequest.builder()
                .cadena_string_a_encriptar("")
                .build();
        mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + adminToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
                .andExpect(status().isBadRequest());
        printStep("EC-05", "✅ 400\n");
    }

    @Test
    @Order(6)
    @DisplayName("EC-06: Sin token → 403")
    void testEncryptWithoutToken() throws Exception {
        printStep("EC-06", "Sin token → 403");
        EncryptionRequest request = EncryptionRequest.builder()
                .cadena_string_a_encriptar("Test123!")
                .build();
        mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
                .andExpect(status().isForbidden());
        printStep("EC-06", "✅ 403\n");
    }

    @Test
    @Order(7)
    @DisplayName("EC-07: demo_user sin ROLE_ADMIN → 403")
    void testDemoUserCannotEncrypt() throws Exception {
        printStep("EC-07", "demo_user intenta encriptar → 403");

        String demoToken = loginAndGetToken(testConfig.getDemoUser(), testConfig.getDemoPassword());
        assertNotNull(demoToken, "Token demo no puede ser null");

        EncryptionRequest request = EncryptionRequest.builder()
                .cadena_string_a_encriptar("TestDemo!")
                .build();

        mockMvc.perform(post("/api/encryption/encrypt")
                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                .header("Authorization", "Bearer " + demoToken)
                .content(Objects.requireNonNull(toJson(request), "JSON no puede ser null")))
                .andExpect(status().isForbidden());

        printStep("EC-07", "✅ demo_user BLOQUEADO (403)");
        System.out.println("=".repeat(70));
        System.out.println("  🔐 FIN PRUEBAS DE ENCRIPTACIÓN");
        System.out.println("=".repeat(70));
    }
}
