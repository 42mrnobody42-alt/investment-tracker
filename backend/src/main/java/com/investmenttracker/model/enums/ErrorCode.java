package com.investmenttracker.model.enums;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {
    
    // Errores de autenticación
    INVALID_CREDENTIALS("AUTH-001", "Usuario o contraseña inválidos", HttpStatus.UNAUTHORIZED),
    ACCOUNT_LOCKED("AUTH-002", "Cuenta bloqueada temporalmente. Intente más tarde", HttpStatus.LOCKED),
    ACCOUNT_DISABLED("AUTH-003", "Cuenta deshabilitada. Contacte al administrador", HttpStatus.FORBIDDEN),
    MAX_ATTEMPTS_EXCEEDED("AUTH-004", "Máximo de intentos excedido. Cuenta bloqueada", HttpStatus.LOCKED),
    TOKEN_EXPIRED("AUTH-005", "Token expirado", HttpStatus.UNAUTHORIZED),
    TOKEN_INVALID("AUTH-006", "Token inválido", HttpStatus.UNAUTHORIZED),
    
    // Errores de validación
    VALIDATION_ERROR("VAL-001", "Error de validación en los datos ingresados", HttpStatus.BAD_REQUEST),
    USERNAME_ALREADY_EXISTS("VAL-002", "El nombre de usuario ya existe", HttpStatus.CONFLICT),
    EMAIL_ALREADY_EXISTS("VAL-003", "El email ya está registrado", HttpStatus.CONFLICT),
    
    // Errores de negocio
    USER_NOT_FOUND("BIZ-001", "Usuario no encontrado", HttpStatus.NOT_FOUND),
    PLATFORM_NOT_FOUND("BIZ-002", "Plataforma no encontrada", HttpStatus.NOT_FOUND),
    NO_POSITION_FOUND("BIZ-003", "No se encontraron posiciones para el símbolo indicado", HttpStatus.NOT_FOUND),
    
    // Errores internos
    INTERNAL_ERROR("SYS-001", "Error interno del servidor", HttpStatus.INTERNAL_SERVER_ERROR),
    DATABASE_ERROR("SYS-002", "Error de conexión con la base de datos", HttpStatus.INTERNAL_SERVER_ERROR);
    
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
    
    ErrorCode(String code, String message, HttpStatus httpStatus) {
        this.code = code;
        this.message = message;
        this.httpStatus = httpStatus;
    }
}
