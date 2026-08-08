package com.investmenttracker.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.request.RestartPasswordRequest;

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
    private static final String PWD_VALIDA = "C4mb14m3!Urgente";

    private void printBanner(String title) {
        System.out.println("\n" + "=".repeat(70));
        System.out.println("  " + title);
        System.out.println("=".repeat(70));
    }

    private void printStep(String step, String message) {
        System.out.println("  [" + step + "] " + message);
    }

    private void printSubStep(String message) {
        System.out.println("     ↳ " + message);
    }

    private RestartPasswordRequest buildRestartRequest(String username, String email,
            String nombreCompleto,
            String nuevoPassword,
            String repetirPassword) {
        return RestartPasswordRequest.builder()
                .username(username)
                .email(email)
                .nombreCompleto(nombreCompleto)
                .nuevoPassword(nuevoPassword)
                .repetirNuevoPassword(repetirPassword)
                .build();
    }

    // =============================================
    // BLOQUE 0: Validaciones del servicio restartPassword
    // =============================================

    @Test
    @Order(1)
    @DisplayName("BLOQUE-0 | TC-00: Login admin para pruebas de validación")
    void testAdminLoginForValidationTests() throws Exception {
        printBanner("🟡 BLOQUE 0: VALIDACIONES DEL SERVICIO restartPassword");
        printStep("TC-00", "Login admin - Necesario para todas las pruebas del BLOQUE 0");

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

        adminToken = extractToken(result);
        printStep("TC-00", "✅ EXITOSO - admin autenticado. Token obtenido para validaciones");
    }

    @Test
    @Order(2)
    @DisplayName("BLOQUE-0 | TC-01: ÉXITO - Cambio de contraseña válido")
    void testRestartPasswordSuccess() throws Exception {
        printStep("TC-01", "Caso FELIZ: Todos los datos correctos - Esperado: 200 OK");
        printSubStep("username: incognito | email: 42mrnobody42@gmail.com");
        printSubStep("nombre: Usuario Premium incognito | password: C4mb14m3!Urgente");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").exists());

        printStep("TC-01", "✅ EXITOSO - Contraseña actualizada (200)");
    }

    @Test
    @Order(3)
    @DisplayName("BLOQUE-0 | TC-02: FALLO - Campos vacíos")
    void testRestartPasswordEmptyFields() throws Exception {
        printStep("TC-02", "Validación: CAMPOS VACÍOS - Esperado: 400 Bad Request");
        printSubStep("username: '' | email: '' | nombre: '' | password: ''");

        RestartPasswordRequest request = buildRestartRequest("", "", "", "", "");

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-02", "✅ EXITOSO - Campos vacíos rechazados (400)");
    }

    @Test
    @Order(4)
    @DisplayName("BLOQUE-0 | TC-03: FALLO - Username vacío (resto ok)")
    void testRestartPasswordEmptyUsername() throws Exception {
        printStep("TC-03", "Validación: username VACÍO - Esperado: 400 Bad Request");
        printSubStep("username: '' | resto de campos correctos");

        RestartPasswordRequest request = buildRestartRequest(
                "", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-03", "✅ EXITOSO - Username vacío rechazado (400)");
    }

    @Test
    @Order(5)
    @DisplayName("BLOQUE-0 | TC-04: FALLO - Email vacío (resto ok)")
    void testRestartPasswordEmptyEmail() throws Exception {
        printStep("TC-04", "Validación: email VACÍO - Esperado: 400 Bad Request");
        printSubStep("email: '' | resto de campos correctos");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-04", "✅ EXITOSO - Email vacío rechazado (400)");
    }

    @Test
    @Order(6)
    @DisplayName("BLOQUE-0 | TC-05: FALLO - Nombre completo vacío (resto ok)")
    void testRestartPasswordEmptyNombre() throws Exception {
        printStep("TC-05", "Validación: nombreCompleto VACÍO - Esperado: 400 Bad Request");
        printSubStep("nombre: '' | resto de campos correctos");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-05", "✅ EXITOSO - Nombre vacío rechazado (400)");
    }

    @Test
    @Order(7)
    @DisplayName("BLOQUE-0 | TC-06: FALLO - Contraseñas NO coinciden")
    void testRestartPasswordMismatch() throws Exception {
        printStep("TC-06", "Validación: CONTRASEÑAS NO COINCIDEN - Esperado: 400 Bad Request");
        printSubStep("nuevoPassword: C4mb14m3!Urgente | repetir: Diferente123!");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, "Diferente123!");

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-06", "✅ EXITOSO - Contraseñas diferentes rechazadas (400)");
    }

    @Test
    @Order(8)
    @DisplayName("BLOQUE-0 | TC-07: FALLO - Contraseña sin mayúscula")
    void testRestartPasswordNoUpperCase() throws Exception {
        printStep("TC-07", "Validación: SIN MAYÚSCULA - Esperado: 400 Bad Request");
        printSubStep("password: c4mb14m3!urgente (sin mayúscula)");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                "c4mb14m3!urgente", "c4mb14m3!urgente");

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-07", "✅ EXITOSO - Sin mayúscula rechazada (400)");
    }

    @Test
    @Order(9)
    @DisplayName("BLOQUE-0 | TC-08: FALLO - Contraseña sin carácter especial")
    void testRestartPasswordNoSpecialChar() throws Exception {
        printStep("TC-08", "Validación: SIN CARÁCTER ESPECIAL - Esperado: 400 Bad Request");
        printSubStep("password: C4mb14m3Urgente (sin ! @ # $ etc.)");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                "C4mb14m3Urgente", "C4mb14m3Urgente");

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-08", "✅ EXITOSO - Sin carácter especial rechazada (400)");
    }

    @Test
    @Order(10)
    @DisplayName("BLOQUE-0 | TC-09: FALLO - Contraseña muy corta (< 8 caracteres)")
    void testRestartPasswordTooShort() throws Exception {
        printStep("TC-09", "Validación: MUY CORTA (< 8) - Esperado: 400 Bad Request");
        printSubStep("password: C4m3!Ur (7 caracteres)");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                "C4m3!Ur", "C4m3!Ur");

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-09", "✅ EXITOSO - Contraseña corta rechazada (400)");
    }

    @Test
    @Order(11)
    @DisplayName("BLOQUE-0 | TC-10: FALLO - Contraseña con comillas dobles")
    void testRestartPasswordDoubleQuotes() throws Exception {
        printStep("TC-10", "Validación: COMILLAS DOBLES - Esperado: 400 Bad Request");
        printSubStep("password: C4mb\"14m3!Urgente");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                "C4mb\"14m3!Urgente", "C4mb\"14m3!Urgente");

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-10", "✅ EXITOSO - Comillas dobles rechazadas (400)");
    }

    @Test
    @Order(12)
    @DisplayName("BLOQUE-0 | TC-11: FALLO - Contraseña con comillas simples")
    void testRestartPasswordSingleQuotes() throws Exception {
        printStep("TC-11", "Validación: COMILLAS SIMPLES - Esperado: 400 Bad Request");
        printSubStep("password: C4mb'14m3!Urgente");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                "C4mb'14m3!Urgente", "C4mb'14m3!Urgente");

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest());

        printStep("TC-11", "✅ EXITOSO - Comillas simples rechazadas (400)");
    }

    @Test
    @Order(13)
    @DisplayName("BLOQUE-0 | TC-12: FALLO - Email no coincide con BD")
    void testRestartPasswordWrongEmail() throws Exception {
        printStep("TC-12", "Validación: EMAIL INCORRECTO - Esperado: 404 Not Found");
        printSubStep("email: wrong@email.com | BD: 42mrnobody42@gmail.com");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "wrong@email.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound());

        printStep("TC-12", "✅ EXITOSO - Email incorrecto rechazado (404)");
    }

    @Test
    @Order(14)
    @DisplayName("BLOQUE-0 | TC-13: FALLO - Nombre completo no coincide con BD")
    void testRestartPasswordWrongNombre() throws Exception {
        printStep("TC-13", "Validación: NOMBRE INCORRECTO - Esperado: 404 Not Found");
        printSubStep("nombre: Nombre Incorrecto | BD: Usuario Premium incognito");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Nombre Incorrecto",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound());

        printStep("TC-13", "✅ EXITOSO - Nombre incorrecto rechazado (404)");
    }

    @Test
    @Order(15)
    @DisplayName("BLOQUE-0 | TC-14: FALLO - Username no existe en BD")
    void testRestartPasswordUserNotFound() throws Exception {
        printStep("TC-14", "Validación: USUARIO NO EXISTE - Esperado: 404 Not Found");
        printSubStep("username: no_existe | BD: no existe");

        RestartPasswordRequest request = buildRestartRequest(
                "no_existe", "no@email.com", "No Existe",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isNotFound());

        printStep("TC-14", "✅ EXITOSO - Usuario inexistente rechazado (404)");
    }

    @Test
    @Order(16)
    @DisplayName("BLOQUE-0 | TC-15: FALLO - Email ignorando mayúsculas (debe funcionar)")
    void testRestartPasswordEmailCaseInsensitive() throws Exception {
        printStep("TC-15", "Validación: EMAIL CASE-INSENSITIVE - Esperado: 200 OK");
        printSubStep("email: 42MRNOBODY42@GMAIL.COM | BD: 42mrnobody42@gmail.com");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42MRNOBODY42@GMAIL.COM", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        printStep("TC-15", "✅ EXITOSO - Email case-insensitive aceptado (200)");
        System.out.println("=".repeat(70));
        System.out.println("  🟡 FIN BLOQUE 0: 15/15 validaciones probadas");
        System.out.println("=".repeat(70));
    }

    // =============================================
    // BLOQUE 1: demo_user primero, luego admin
    // =============================================

    @Test
    @Order(17)
    @DisplayName("BLOQUE-1 | TC-16: Login demo_user exitoso")
    void testDemoUserLogin() throws Exception {
        printBanner("🔵 BLOQUE 1: demo_user PRIMERO, luego admin");
        printStep("TC-16", "Login demo_user - Esperado: 200 + Token");

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

        demoToken = extractToken(result);
        printStep("TC-16", "✅ EXITOSO - demo_user autenticado");
    }

    @Test
    @Order(18)
    @DisplayName("BLOQUE-1 | TC-17: demo_user NO puede restart-password")
    void testDemoUserRestartPasswordForbidden() throws Exception {
        printStep("TC-17", "demo_user intenta restart-password - Esperado: 403 Forbidden");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + demoToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());

        printStep("TC-17", "✅ EXITOSO - demo_user BLOQUEADO (403)");
    }

    @Test
    @Order(19)
    @DisplayName("BLOQUE-1 | TC-18: Login admin exitoso")
    void testAdminLogin() throws Exception {
        printStep("TC-18", "Login admin - Esperado: 200 + Token");

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

        adminToken = extractToken(result);
        printStep("TC-18", "✅ EXITOSO - admin autenticado");
    }

    @Test
    @Order(20)
    @DisplayName("BLOQUE-1 | TC-19: admin SÍ puede restart-password")
    void testAdminRestartPasswordSuccess() throws Exception {
        printStep("TC-19", "admin ejecuta restart-password - Esperado: 200 OK");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        printStep("TC-19", "✅ EXITOSO - admin cambió contraseña (200)");
        System.out.println("=".repeat(70));
        System.out.println("  🔵 FIN BLOQUE 1: demo_user BLOQUEADO, admin EXITOSO");
        System.out.println("=".repeat(70));
    }

    // =============================================
    // BLOQUE 2: VICEVERSA
    // =============================================

    @Test
    @Order(21)
    @DisplayName("BLOQUE-2 | TC-20: Login admin (viceversa)")
    void testAdminRelogin() throws Exception {
        printBanner("🔴 BLOQUE 2: VICEVERSA - admin PRIMERO, luego demo_user");
        printStep("TC-20", "Login admin (viceversa) - Esperado: 200");

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

        adminToken = extractToken(result);
        printStep("TC-20", "✅ EXITOSO - admin autenticado (viceversa)");
    }

    @Test
    @Order(22)
    @DisplayName("BLOQUE-2 | TC-21: admin puede restart-password (viceversa)")
    void testAdminStillCanRestartPassword() throws Exception {
        printStep("TC-21", "admin restart-password (viceversa) - Esperado: 200 OK");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        printStep("TC-21", "✅ EXITOSO - admin cambió contraseña (viceversa)");
    }

    @Test
    @Order(23)
    @DisplayName("BLOQUE-2 | TC-22: Login demo_user (viceversa)")
    void testDemoUserRelogin() throws Exception {
        printStep("TC-22", "Login demo_user (viceversa) - Esperado: 200");

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

        demoToken = extractToken(result);
        printStep("TC-22", "✅ EXITOSO - demo_user autenticado (viceversa)");
    }

    @Test
    @Order(24)
    @DisplayName("BLOQUE-2 | TC-23: demo_user NO puede restart-password (viceversa)")
    void testDemoUserStillCannotRestartPassword() throws Exception {
        printStep("TC-23", "demo_user restart-password (viceversa) - Esperado: 403");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + demoToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());

        printStep("TC-23", "✅ EXITOSO - demo_user BLOQUEADO (403)");
        System.out.println("=".repeat(70));
        System.out.println("  🔴 FIN BLOQUE 2: admin EXITOSO, demo_user BLOQUEADO");
        System.out.println("=".repeat(70));
    }

    // =============================================
    // BLOQUE 3: Adicionales
    // =============================================

    @Test
    @Order(25)
    @DisplayName("BLOQUE-3 | TC-24: Sin token = 403")
    void testRestartPasswordWithoutToken() throws Exception {
        printBanner("🟢 BLOQUE 3: PRUEBAS ADICIONALES");
        printStep("TC-24", "Petición sin token - Esperado: 403");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());

        printStep("TC-24", "✅ EXITOSO - Sin token = 403");
    }

    @Test
    @Order(26)
    @DisplayName("BLOQUE-3 | TC-25: Cleanup final")
    void testRestoreIncognitoPassword() throws Exception {
        printStep("TC-25", "Cleanup - Restaurar contraseña final");

        RestartPasswordRequest request = buildRestartRequest(
                "incognito", "42mrnobody42@gmail.com", "Usuario Premium incognito",
                PWD_VALIDA, PWD_VALIDA);

        mockMvc.perform(post("/api/auth/restart-password")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "Bearer " + adminToken)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        printStep("TC-25", "✅ EXITOSO - Cleanup completado");
        System.out.println("=".repeat(70));
        System.out.println("  🏁 FIN DE TODAS LAS PRUEBAS - 25/25 EXITOSAS");
        System.out.println("=".repeat(70));
    }

    private String extractToken(MvcResult result) throws Exception {
        return objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();
    }
}
