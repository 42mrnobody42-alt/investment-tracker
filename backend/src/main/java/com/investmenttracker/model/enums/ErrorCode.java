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
    ACCESS_DENIED("AUTH-007", "Acceso denegado. Se requiere rol ADMIN", HttpStatus.FORBIDDEN),
    USER_NOT_AUTHENTICATED("AUTH-008", "Usuario no autenticado", HttpStatus.UNAUTHORIZED),
    
    // Errores de recuperación de contraseña
    RECOVERY_MAX_ATTEMPTS_EXCEEDED("REC-001", "Máximo de intentos de recuperación excedido. Servicio bloqueado por 24 horas", HttpStatus.LOCKED),
    RECOVERY_TOKEN_EXPIRED("REC-002", "El token de recuperación ha expirado. Solicite uno nuevo", HttpStatus.BAD_REQUEST),
    RECOVERY_TOKEN_INVALID("REC-003", "Token inválido. Verifique e intente nuevamente", HttpStatus.BAD_REQUEST),
    RECOVERY_USER_MISMATCH("REC-004", "Los datos del usuario no coinciden con los registrados", HttpStatus.NOT_FOUND),
    RECOVERY_EMAIL_SEND_ERROR("REC-005", "Error al enviar el correo de recuperación. Intente más tarde", HttpStatus.INTERNAL_SERVER_ERROR),
    
    // Errores de validación
    VALIDATION_ERROR("VAL-001", "Error de validación en los datos ingresados", HttpStatus.BAD_REQUEST),
    UPDATE_VALIDATION_ERROR("VAL-002", "Error con el guardado de los datos ingresados", HttpStatus.BAD_REQUEST),
    USERNAME_ALREADY_EXISTS("VAL-003", "El nombre de usuario ya existe", HttpStatus.CONFLICT),
    EMAIL_ALREADY_EXISTS("VAL-004", "El email ya está registrado", HttpStatus.CONFLICT),
    EMPTY_FIELDS("VAL-005", "Información vacía, digite correctamente todos los campos obligatorios", HttpStatus.BAD_REQUEST),
    
    // Errores de contraseña
    PASSWORDS_DO_NOT_MATCH("PWD-001", "El nuevo password y su repetición NO coinciden", HttpStatus.BAD_REQUEST),
    PASSWORD_CRITERIA_NOT_MET("PWD-002", "CONTRASEÑA_NO_CUMPLE_CRITERIOS", HttpStatus.BAD_REQUEST),
    CURRENT_PASSWORD_INCORRECT("PWD-003", "La contraseña actual es incorrecta", HttpStatus.BAD_REQUEST),
    SAME_PASSWORD("PWD-004", "La nueva contraseña no puede ser igual a la actual", HttpStatus.BAD_REQUEST),
    
    // Errores de encriptación
    ENCRYPT_ERROR("ENC-001", "Error al encriptar el texto proporcionado", HttpStatus.INTERNAL_SERVER_ERROR),
    DECRYPT_ERROR("ENC-002", "Error al desencriptar el texto proporcionado", HttpStatus.INTERNAL_SERVER_ERROR),
    TEXT_CANNOT_BE_NULL("ENC-003", "La cadena de texto no puede ser null o vacía", HttpStatus.BAD_REQUEST),
    
    // Errores de negocio
    USER_NOT_FOUND("BIZ-001", "Usuario no encontrado", HttpStatus.NOT_FOUND),
    PLATFORM_NOT_FOUND("BIZ-002", "Plataforma no encontrada", HttpStatus.NOT_FOUND),
    NO_POSITION_FOUND("BIZ-003", "No se encontraron posiciones para el símbolo indicado", HttpStatus.NOT_FOUND),
    
    // Errores internos
    RATE_LIMIT_EXCEEDED("RATE-001", "Demasiadas peticiones. Intente nuevamente más tarde", HttpStatus.TOO_MANY_REQUESTS),
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
