package com.investmenttracker.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.investmenttracker.component.SecurityLoginComponent;
import com.investmenttracker.exception.AuthenticationException;
import com.investmenttracker.model.entity.Pais;
import com.investmenttracker.model.entity.Role;
import com.investmenttracker.model.entity.User;
import com.investmenttracker.model.enums.ErrorCode;
import com.investmenttracker.model.enums.Plan;
import com.investmenttracker.model.request.RegisterConfirmRequest;
import com.investmenttracker.model.request.RegisterRequest;
import com.investmenttracker.model.response.SuccessResponse;
import com.investmenttracker.repository.PaisRepository;
import com.investmenttracker.repository.RoleRepository;
import com.investmenttracker.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("Pruebas unitarias de RegisterService")
class RegisterServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PaisRepository paisRepository;

    @Mock
    private RoleRepository roleRepository;

    @Mock
    private SecurityLoginComponent securityLoginComponent;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private RegisterService registerService;

    private RegisterRequest registerRequest;
    private RegisterConfirmRequest confirmRequest;
    private User mockUser;
    private Role mockRole;
    private Pais mockPais;
    private UUID paisId;
    private UUID userId;

    @BeforeEach
    void setUp() {
        paisId = UUID.fromString("10000000-0001-0001-0001-000000000002");
        userId = UUID.randomUUID();

        registerRequest = RegisterRequest.builder()
                .username("test_user")
                .email("test@email.com")
                .nombreCompleto("Test User")
                .password("TestPass123!")
                .repeatPassword("TestPass123!")
                .celular(3101234567L)
                .paisId(paisId)
                .plan(Plan.FREE)
                .build();

        confirmRequest = RegisterConfirmRequest.builder()
                .username("test_user")
                .email("test@email.com")
                .nombreCompleto("Test User")
                .celular(3101234567L)
                .paisId(paisId)
                .plan(Plan.FREE)
                .token("123456")
                .build();

        mockRole = Role.builder()
                .id(UUID.randomUUID())
                .nombre("ROLE_USER")
                .build();

        mockPais = Pais.builder()
                .id(paisId)
                .nombre("Colombia")
                .codigoIso("COL")
                .indicativoCelular("+57")
                .build();

        mockUser = User.builder()
                .id(userId)
                .username("test_user")
                .email("test@email.com")
                .nombreCompleto("Test User")
                .passwordHash("encrypted")
                .celular(3101234567L)
                .pais(mockPais)
                .activo(true)
                .build();
    }

    // ============ REQUEST REGISTRATION TESTS ============

    @Test
    @DisplayName("Request registration - éxito (FREE)")
    void requestRegistration_Free_Success() {
        when(securityLoginComponent.passwordsMatch(any(), any())).thenReturn(true);
        when(securityLoginComponent.isValidPassword(any())).thenReturn(true);
        when(userRepository.existsByUsername(any())).thenReturn(false);
        when(userRepository.findByEmailIgnoreCase(any())).thenReturn(Optional.empty());
        when(userRepository.existsByPaisIdAndCelular(any(), any())).thenReturn(false);
        when(paisRepository.existsById(any())).thenReturn(true);
        doNothing().when(emailService).sendRegistrationEmail(any(), any(), any());

        SuccessResponse response = registerService.requestRegistration(registerRequest);

        assertNotNull(response);
        assertEquals("REG-0001", response.getCode());
        verify(emailService, times(1)).sendRegistrationEmail(any(), any(), any());
    }

    @Test
    @DisplayName("Request registration - éxito (PREMIUM)")
    void requestRegistration_Premium_Success() {
        registerRequest.setPlan(Plan.PREMIUM);
        when(securityLoginComponent.passwordsMatch(any(), any())).thenReturn(true);
        when(securityLoginComponent.isValidPassword(any())).thenReturn(true);
        when(userRepository.existsByUsername(any())).thenReturn(false);
        when(userRepository.findByEmailIgnoreCase(any())).thenReturn(Optional.empty());
        when(userRepository.existsByPaisIdAndCelular(any(), any())).thenReturn(false);
        when(paisRepository.existsById(any())).thenReturn(true);
        doNothing().when(emailService).sendRegistrationEmail(any(), any(), any());

        SuccessResponse response = registerService.requestRegistration(registerRequest);

        assertNotNull(response);
        assertEquals("REG-0001", response.getCode());
    }

    @Test
    @DisplayName("Request registration - campos vacíos → error")
    void requestRegistration_EmptyFields_ThrowsException() {
        registerRequest.setUsername(null);
        assertThrows(AuthenticationException.class, () -> registerService.requestRegistration(registerRequest));
    }

    @Test
    @DisplayName("Request registration - contraseñas no coinciden → error")
    void requestRegistration_PasswordsDoNotMatch_ThrowsException() {
        registerRequest.setRepeatPassword("Different123!");
        when(securityLoginComponent.passwordsMatch(any(), any())).thenReturn(false);

        AuthenticationException ex = assertThrows(AuthenticationException.class,
                () -> registerService.requestRegistration(registerRequest));
        assertEquals(ErrorCode.REGISTRATION_PASSWORD_DOES_NOT_MATCH, ex.getErrorCode());
    }

    @Test
    @DisplayName("Request registration - contraseña débil → error")
    void requestRegistration_WeakPassword_ThrowsException() {
        registerRequest.setPassword("weak");
        registerRequest.setRepeatPassword("weak");
        when(securityLoginComponent.passwordsMatch(any(), any())).thenReturn(true);
        when(securityLoginComponent.isValidPassword(any())).thenReturn(false);

        AuthenticationException ex = assertThrows(AuthenticationException.class,
                () -> registerService.requestRegistration(registerRequest));
        assertEquals(ErrorCode.PASSWORD_CRITERIA_NOT_MET, ex.getErrorCode());
    }

    @Test
    @DisplayName("Request registration - username ya existe → error")
    void requestRegistration_UsernameExists_ThrowsException() {
        // Permitir que las validaciones de contraseña pasen
        when(securityLoginComponent.passwordsMatch(any(), any())).thenReturn(true);
        when(securityLoginComponent.isValidPassword(any())).thenReturn(true);
        // Simular que el username ya existe
        when(userRepository.existsByUsername(any())).thenReturn(true);

        AuthenticationException ex = assertThrows(AuthenticationException.class,
                () -> registerService.requestRegistration(registerRequest));
        assertEquals(ErrorCode.REGISTRATION_USERNAME_EXISTS, ex.getErrorCode());
    }

    @Test
    @DisplayName("Request registration - email ya existe → error")
    void requestRegistration_EmailExists_ThrowsException() {
        // Permitir que las validaciones de contraseña pasen
        when(securityLoginComponent.passwordsMatch(any(), any())).thenReturn(true);
        when(securityLoginComponent.isValidPassword(any())).thenReturn(true);
        // Simular que el email ya existe (username no existe)
        when(userRepository.existsByUsername(any())).thenReturn(false);
        when(userRepository.findByEmailIgnoreCase(any())).thenReturn(Optional.of(mockUser));

        AuthenticationException ex = assertThrows(AuthenticationException.class,
                () -> registerService.requestRegistration(registerRequest));
        assertEquals(ErrorCode.REGISTRATION_EMAIL_EXISTS, ex.getErrorCode());
    }

    @Test
    @DisplayName("Request registration - pais no existe → error")
    void requestRegistration_PaisNotFound_ThrowsException() {
        // Permitir que las validaciones de contraseña pasen
        when(securityLoginComponent.passwordsMatch(any(), any())).thenReturn(true);
        when(securityLoginComponent.isValidPassword(any())).thenReturn(true);
        // Simular que username y email no existen
        when(userRepository.existsByUsername(any())).thenReturn(false);
        when(userRepository.findByEmailIgnoreCase(any())).thenReturn(Optional.empty());
        when(userRepository.existsByPaisIdAndCelular(any(), any())).thenReturn(false);
        // Simular que el país no existe
        when(paisRepository.existsById(any())).thenReturn(false);

        AuthenticationException ex = assertThrows(AuthenticationException.class,
                () -> registerService.requestRegistration(registerRequest));
        assertEquals(ErrorCode.PAIS_NOT_FOUND, ex.getErrorCode());
    }

    @Test
    @DisplayName("Request registration - error al enviar email → error")
    void requestRegistration_EmailSendError_ThrowsException() {
        when(securityLoginComponent.passwordsMatch(any(), any())).thenReturn(true);
        when(securityLoginComponent.isValidPassword(any())).thenReturn(true);
        when(userRepository.existsByUsername(any())).thenReturn(false);
        when(userRepository.findByEmailIgnoreCase(any())).thenReturn(Optional.empty());
        when(userRepository.existsByPaisIdAndCelular(any(), any())).thenReturn(false);
        when(paisRepository.existsById(any())).thenReturn(true);
        doThrow(new RuntimeException("SMTP error")).when(emailService).sendRegistrationEmail(any(), any(), any());

        AuthenticationException ex = assertThrows(AuthenticationException.class,
                () -> registerService.requestRegistration(registerRequest));
        assertEquals(ErrorCode.RECOVERY_EMAIL_SEND_ERROR, ex.getErrorCode());
    }

    // ============ CONFIRM REGISTRATION TESTS ============

    // Nota: Para pruebas de confirmación se requiere un enfoque de integración
    // debido al caché en memoria. Las pruebas unitarias se centran en validaciones.

    // ============ DELETE ACCOUNT TESTS ============

    @Test
    @DisplayName("Delete account - éxito")
    void deleteAccount_Success() {
        when(userRepository.findByUsernameIgnoreCase(any())).thenReturn(Optional.of(mockUser));

        SuccessResponse response = registerService.deleteAccount("test_user");

        assertNotNull(response);
        assertEquals("REG-0003", response.getCode());
        verify(userRepository, times(1)).save(any());
        assertFalse(mockUser.getActivo());
    }

    @Test
    @DisplayName("Delete account - usuario no encontrado → error")
    void deleteAccount_UserNotFound_ThrowsException() {
        when(userRepository.findByUsernameIgnoreCase(any())).thenReturn(Optional.empty());

        AuthenticationException ex = assertThrows(AuthenticationException.class,
                () -> registerService.deleteAccount("nonexistent"));
        assertEquals(ErrorCode.USER_NOT_FOUND, ex.getErrorCode());
    }

    // ============ DELETE USER PERMANENTLY TESTS ============

    @Test
    @DisplayName("Delete user permanently - éxito")
    void deleteUserPermanently_Success() {
        when(userRepository.findByUsernameIgnoreCase(any())).thenReturn(Optional.of(mockUser));

        registerService.deleteUserPermanently("test_user");

        verify(userRepository, times(1)).delete(any());
    }

    @Test
    @DisplayName("Delete user permanently - usuario no encontrado → error")
    void deleteUserPermanently_UserNotFound_ThrowsException() {
        when(userRepository.findByUsernameIgnoreCase(any())).thenReturn(Optional.empty());

        AuthenticationException ex = assertThrows(AuthenticationException.class,
                () -> registerService.deleteUserPermanently("nonexistent"));
        assertEquals(ErrorCode.USER_NOT_FOUND, ex.getErrorCode());
    }
}