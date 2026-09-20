package com.investmenttracker.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Objects;
import java.util.UUID;

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
import org.springframework.test.web.servlet.MvcResult;

import com.investmenttracker.model.request.UpdateMyProfileRequest;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class ProfileIntegrationTest extends BaseIntegrationTest {

        private static final String PAIS_ID_ORIGINAL = "10000000-0001-0001-0001-000000000002"; // Colombia
        private static final long CELULAR_ORIGINAL = 3001234567L;

        private String demoToken;
        private UUID demoUserId;

        @BeforeAll
        void setUpTokens() throws Exception {
                printBanner("👤 PRUEBAS DE PERFIL - SETUP");
                demoToken = loginAndGetToken("demo_user", "Demo123!");

                // Obtener id real de demo_user
                MvcResult result = mockMvc.perform(get("/api/auth/get-my-profile")
                                .header("Authorization", "Bearer " + demoToken))
                                .andExpect(status().isOk())
                                .andReturn();
                String idStr = objectMapper.readTree(result.getResponse().getContentAsString()).get("id").asText();
                demoUserId = UUID.fromString(idStr);
                printStep("SETUP", "demo_user id: " + demoUserId);
        }

        // =============================================
        // GET MY PROFILE
        // =============================================

        @Test
        @Order(1)
        @DisplayName("PRO-01: get-my-profile exitoso (demo_user)")
        void testGetMyProfile() throws Exception {
                printBanner("🟢 GET MY PROFILE");
                printStep("PRO-01", "Consultar perfil propio");

                mockMvc.perform(get("/api/auth/get-my-profile")
                                .header("Authorization", "Bearer " + demoToken))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.id").value(demoUserId.toString()))
                                .andExpect(jsonPath("$.username").value("demo_user"))
                                .andExpect(jsonPath("$.email").value("demo@investment-tracker.com"))
                                .andExpect(jsonPath("$.celular").value(3001234567L))
                                .andExpect(jsonPath("$.pais.id").value(PAIS_ID_ORIGINAL));

                printStep("PRO-01", "✅ 200 OK con datos reales");
        }

        @Test
        @Order(2)
        @DisplayName("PRO-02: get-my-profile sin JWT")
        void testGetMyProfileNoAuth() throws Exception {
                printStep("PRO-02", "Consultar sin JWT → 403");
                mockMvc.perform(get("/api/auth/get-my-profile"))
                                .andExpect(status().isForbidden());
                printStep("PRO-02", "✅ 403");
        }

        // =============================================
        // UPDATE MY PROFILE
        // =============================================

        @Test
        @Order(3)
        @DisplayName("PRO-03: update-my-profile sin cambios (mismos datos) → OK")
        void testUpdateMyProfileSameData() throws Exception {
                printBanner("🟡 UPDATE MY PROFILE");
                printStep("PRO-03", "Actualizar con mismos datos");

                UpdateMyProfileRequest request = UpdateMyProfileRequest.builder()
                                .id(demoUserId)
                                .username("demo_user")
                                .email("demo@investment-tracker.com")
                                .nombreCompleto("Usuario Demo")
                                .paisId(UUID.fromString(PAIS_ID_ORIGINAL))
                                .celular(CELULAR_ORIGINAL)
                                .build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .header("Authorization", "Bearer " + demoToken)
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(request))))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.code").value("UPT-0001"))
                                .andExpect(jsonPath("$.message").value("Actualización del usuario con éxito!!"));

                printStep("PRO-03", "✅ 200 OK");
        }

        @Test
        @Order(4)
        @DisplayName("PRO-04: update-my-profile con nuevo nombre → OK")
        void testUpdateMyProfileNewName() throws Exception {
                printStep("PRO-04", "Actualizar nombreCompleto");

                UpdateMyProfileRequest request = UpdateMyProfileRequest.builder()
                                .id(demoUserId)
                                .username("demo_user")
                                .email("demo@investment-tracker.com")
                                .nombreCompleto("Usuario Demo Actualizado")
                                .paisId(UUID.fromString(PAIS_ID_ORIGINAL))
                                .celular(CELULAR_ORIGINAL)
                                .build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .header("Authorization", "Bearer " + demoToken)
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(request))))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.code").value("UPT-0001"));

                // Verificar que se actualizó
                mockMvc.perform(get("/api/auth/get-my-profile")
                                .header("Authorization", "Bearer " + demoToken))
                                .andExpect(jsonPath("$.nombreCompleto").value("Usuario Demo Actualizado"));

                // Restaurar
                UpdateMyProfileRequest restore = UpdateMyProfileRequest.builder()
                                .id(demoUserId)
                                .username("demo_user")
                                .email("demo@investment-tracker.com")
                                .nombreCompleto("Usuario Demo")
                                .paisId(UUID.fromString(PAIS_ID_ORIGINAL))
                                .celular(CELULAR_ORIGINAL)
                                .build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .header("Authorization", "Bearer " + demoToken)
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(restore))))
                                .andExpect(status().isOk());

                printStep("PRO-04", "✅ Nombre actualizado y restaurado");
        }

        @Test
        @Order(5)
        @DisplayName("PRO-05: update-my-profile con username ajeno → 403")
        void testUpdateMyProfileOtherUser() throws Exception {
                printStep("PRO-05", "Intento de actualizar a otro usuario → 403");

                UpdateMyProfileRequest request = UpdateMyProfileRequest.builder()
                                .id(demoUserId)
                                .username("admin")
                                .email("demo@investment-tracker.com")
                                .nombreCompleto("Hack")
                                .paisId(UUID.fromString(PAIS_ID_ORIGINAL))
                                .celular(CELULAR_ORIGINAL)
                                .build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .header("Authorization", "Bearer " + demoToken)
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(request))))
                                .andExpect(status().isForbidden());

                printStep("PRO-05", "✅ 403");
        }

        @Test
        @Order(6)
        @DisplayName("PRO-06: update-my-profile con id ajeno → 403")
        void testUpdateMyProfileOtherId() throws Exception {
                printStep("PRO-06", "Intento con id incorrecto → 403");

                UpdateMyProfileRequest request = UpdateMyProfileRequest.builder()
                                .id(UUID.randomUUID())
                                .username("demo_user")
                                .email("demo@investment-tracker.com")
                                .nombreCompleto("Usuario Demo")
                                .paisId(UUID.fromString(PAIS_ID_ORIGINAL))
                                .celular(CELULAR_ORIGINAL)
                                .build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .header("Authorization", "Bearer " + demoToken)
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(request))))
                                .andExpect(status().isForbidden());

                printStep("PRO-06", "✅ 403");
        }

        @Test
        @Order(7)
        @DisplayName("PRO-07: update-my-profile con email duplicado → 409")
        void testUpdateMyProfileDuplicateEmail() throws Exception {
                printStep("PRO-07", "Email duplicado → 409");

                UpdateMyProfileRequest request = UpdateMyProfileRequest.builder()
                                .id(demoUserId)
                                .username("demo_user")
                                .email("admin@investment-tracker.com") // email de admin
                                .nombreCompleto("Usuario Demo")
                                .paisId(UUID.fromString(PAIS_ID_ORIGINAL))
                                .celular(CELULAR_ORIGINAL)
                                .build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .header("Authorization", "Bearer " + demoToken)
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(request))))
                                .andExpect(status().isConflict())
                                .andExpect(jsonPath("$.code").value("REG-002"));

                printStep("PRO-07", "✅ 409");
        }

        @Test
        @Order(8)
        @DisplayName("PRO-08: update-my-profile con campos vacíos → 500")
        void testUpdateMyProfileEmptyFields() throws Exception {
                printStep("PRO-08", "Campos vacíos → 500 SYS-03");

                UpdateMyProfileRequest request = UpdateMyProfileRequest.builder().build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .header("Authorization", "Bearer " + demoToken)
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(request))))
                                .andExpect(status().isInternalServerError())
                                .andExpect(jsonPath("$.code").value("SYS-03"))
                                .andExpect(jsonPath("$.message").value("Argumentos invalidos"));
                printStep("PRO-08", "✅ 500 SYS-03");
        }

        @Test
        @Order(9)
        @DisplayName("PRO-09: update-my-profile sin JWT → 401")
        void testUpdateMyProfileNoAuth() throws Exception {
                printStep("PRO-09", "Sin JWT → 403");

                UpdateMyProfileRequest request = UpdateMyProfileRequest.builder()
                                .id(demoUserId)
                                .username("demo_user")
                                .email("demo@investment-tracker.com")
                                .nombreCompleto("Usuario Demo")
                                .paisId(UUID.fromString(PAIS_ID_ORIGINAL))
                                .celular(CELULAR_ORIGINAL)
                                .build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(request))))
                                .andExpect(status().isForbidden());

                printStep("PRO-09", "✅ 403");
        }

        @Test
        @Order(10)
        @DisplayName("PRO-10: update-my-profile con país inexistente → 404")
        void testUpdateMyProfileInvalidPais() throws Exception {
                printStep("PRO-10", "País inexistente → 404");

                UpdateMyProfileRequest request = UpdateMyProfileRequest.builder()
                                .id(demoUserId)
                                .username("demo_user")
                                .email("demo@investment-tracker.com")
                                .nombreCompleto("Usuario Demo")
                                .paisId(UUID.randomUUID())
                                .celular(CELULAR_ORIGINAL)
                                .build();

                mockMvc.perform(post("/api/auth/update-my-profile")
                                .header("Authorization", "Bearer " + demoToken)
                                .contentType(Objects.requireNonNull(MediaType.APPLICATION_JSON))
                                .content(Objects.requireNonNull(toJson(request))))
                                .andExpect(status().isNotFound())
                                .andExpect(jsonPath("$.code").value("REG-007"));

                printStep("PRO-10", "✅ 404");
        }
}
