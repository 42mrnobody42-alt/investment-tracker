package com.investmenttracker.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import com.investmenttracker.component.LoginComponent;
import com.investmenttracker.component.RefreshTokenComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.Role;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.request.LoginRequest;
import com.investmenttracker.model.response.LoginResponse;

@ExtendWith(MockitoExtension.class)
class LoginServiceTest {

        @Mock
        private LoginComponent loginComponent;

        @Mock
        private JwtService jwtService;

        @Mock
        private RefreshTokenComponent refreshTokenComponent;

        @InjectMocks
        private LoginService loginService;

        private User demoUser;
        private User adminUser;

        @BeforeEach
        void setUp() {
                BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

                String demoPassHash = Objects.requireNonNull(encoder.encode("Demo123!"), "Hash demo no puede ser null");
                String adminPassHash = Objects.requireNonNull(encoder.encode("Admin123!"),
                                "Hash admin no puede ser null");

                Role userRole = Role.builder()
                                .id(UUID.randomUUID())
                                .nombre("ROLE_USER")
                                .build();

                Role adminRole = Role.builder()
                                .id(UUID.randomUUID())
                                .nombre("ROLE_ADMIN")
                                .build();

                Set<Role> demoRoles = Objects.requireNonNull(Set.of(userRole), "Roles demo no puede ser null");
                Set<Role> adminRoles = Objects.requireNonNull(Set.of(userRole, adminRole),
                                "Roles admin no puede ser null");

                demoUser = User.builder()
                                .id(UUID.randomUUID())
                                .username("demo_user")
                                .passwordHash(demoPassHash)
                                .email("demo@test.com")
                                .nombreCompleto("Usuario Demo")
                                .activo(true)
                                .roles(demoRoles)
                                .build();

                adminUser = User.builder()
                                .id(UUID.randomUUID())
                                .username("admin")
                                .passwordHash(adminPassHash)
                                .email("admin@test.com")
                                .nombreCompleto("Administrador")
                                .activo(true)
                                .roles(adminRoles)
                                .build();
        }

        @Test
        @DisplayName("UT-01: Login exitoso demo_user")
        void testDemoUserLoginSuccess() {
                LoginRequest request = LoginRequest.builder()
                                .username("demo_user")
                                .password("Demo123!")
                                .build();

                when(loginComponent.findUserByUsername("demo_user")).thenReturn(Optional.of(demoUser));
                when(loginComponent.isUserLocked("demo_user")).thenReturn(false);
                when(jwtService.generateToken(any(User.class))).thenReturn("jwt-token-demo-user-xyz123456789");
                when(jwtService.getExpirationTime()).thenReturn(86400000L);
                when(refreshTokenComponent.generateRefreshToken(any(String.class))).thenReturn("test-refresh-token");

                LoginResponse response = loginService.login(request);

                assertNotNull(response);
                assertEquals("demo_user", response.getUsername());
                assertEquals("jwt-token-demo-user-xyz123456789", response.getToken());
                assertEquals("Bearer", response.getTokenType());
                verify(loginComponent).resetFailedAttempts(demoUser);

                System.out.println("✅ UT-01: Login demo_user exitoso");
        }

        @Test
        @DisplayName("UT-02: Login exitoso admin")
        void testAdminLoginSuccess() {
                LoginRequest request = LoginRequest.builder()
                                .username("admin")
                                .password("Admin123!")
                                .build();

                when(loginComponent.findUserByUsername("admin")).thenReturn(Optional.of(adminUser));
                when(loginComponent.isUserLocked("admin")).thenReturn(false);
                when(jwtService.generateToken(any(User.class))).thenReturn("jwt-token-admin-abc987654321");
                when(jwtService.getExpirationTime()).thenReturn(86400000L);
                when(refreshTokenComponent.generateRefreshToken(any(String.class))).thenReturn("test-refresh-token");

                LoginResponse response = loginService.login(request);

                assertNotNull(response);
                assertEquals("admin", response.getUsername());
                assertEquals("jwt-token-admin-abc987654321", response.getToken());

                System.out.println("✅ UT-02: Login admin exitoso");
        }

        @Test
        @DisplayName("UT-03: Login fallido - contraseña incorrecta")
        void testLoginInvalidPassword() {
                LoginRequest request = LoginRequest.builder()
                                .username("demo_user")
                                .password("WrongPassword!")
                                .build();

                when(loginComponent.findUserByUsername("demo_user")).thenReturn(Optional.of(demoUser));
                when(loginComponent.isUserLocked("demo_user")).thenReturn(false);
                when(loginComponent.getLockInfo("demo_user"))
                                .thenReturn(new LoginComponent.LockInfo(false, 0, 2));

                AuthenticationException exception = assertThrows(AuthenticationException.class,
                                () -> loginService.login(request));

                assertEquals(ErrorCode.INVALID_CREDENTIALS, exception.getErrorCode());
                verify(loginComponent).recordFailedAttempt("demo_user");

                System.out.println("✅ UT-03: Contraseña incorrecta detectada");
        }

        @Test
        @DisplayName("UT-04: Login fallido - usuario bloqueado")
        void testLoginUserLocked() {
                LoginRequest request = LoginRequest.builder()
                                .username("demo_user")
                                .password("Demo123!")
                                .build();

                when(loginComponent.isUserLocked("demo_user")).thenReturn(true);
                when(loginComponent.getLockInfo("demo_user"))
                                .thenReturn(new LoginComponent.LockInfo(true, 300, 0));

                AuthenticationException exception = assertThrows(AuthenticationException.class,
                                () -> loginService.login(request));

                assertEquals(ErrorCode.ACCOUNT_LOCKED, exception.getErrorCode());

                System.out.println("✅ UT-04: Usuario bloqueado detectado");
        }

        @Test
        @DisplayName("UT-05: Login fallido - usuario no encontrado")
        void testLoginUserNotFound() {
                LoginRequest request = LoginRequest.builder()
                                .username("no_existe")
                                .password("password123")
                                .build();

                when(loginComponent.findUserByUsername("no_existe")).thenReturn(Optional.empty());

                AuthenticationException exception = assertThrows(AuthenticationException.class,
                                () -> loginService.login(request));

                assertEquals(ErrorCode.INVALID_CREDENTIALS, exception.getErrorCode());

                System.out.println("✅ UT-05: Usuario no encontrado detectado");
        }

        @Test
        @DisplayName("UT-06: Verificar independencia de tokens")
        void testTokenIndependence() {
                when(loginComponent.findUserByUsername("demo_user")).thenReturn(Optional.of(demoUser));
                when(loginComponent.isUserLocked("demo_user")).thenReturn(false);
                when(jwtService.generateToken(demoUser)).thenReturn("token-unico-demo-user-123456789");
                when(jwtService.getExpirationTime()).thenReturn(86400000L);
                when(refreshTokenComponent.generateRefreshToken(any(String.class))).thenReturn("test-refresh-token");

                LoginResponse demoResponse = loginService.login(
                                LoginRequest.builder().username("demo_user").password("Demo123!").build());

                when(loginComponent.findUserByUsername("admin")).thenReturn(Optional.of(adminUser));
                when(loginComponent.isUserLocked("admin")).thenReturn(false);
                when(jwtService.generateToken(adminUser)).thenReturn("token-unico-admin-456987123");
                when(jwtService.getExpirationTime()).thenReturn(86400000L);
                when(refreshTokenComponent.generateRefreshToken(any(String.class))).thenReturn("test-refresh-token");

                LoginResponse adminResponse = loginService.login(
                                LoginRequest.builder().username("admin").password("Admin123!").build());

                assertNotEquals(
                                Objects.requireNonNull(demoResponse.getToken(), "Token demo no puede ser null"),
                                Objects.requireNonNull(adminResponse.getToken(), "Token admin no puede ser null"),
                                "Los tokens deben ser diferentes");
                assertEquals("demo_user", demoResponse.getUsername());
                assertEquals("admin", adminResponse.getUsername());

                System.out.println("✅ UT-06: Independencia de tokens verificada");
        }
}