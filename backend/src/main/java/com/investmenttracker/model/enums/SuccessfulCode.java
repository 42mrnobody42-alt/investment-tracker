package com.investmenttracker.model.enums;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum SuccessfulCode {
    
    TEST_SERVICE("UP-0001", "Servicio Investment Tracker iniciado con éxito", HttpStatus.OK),
    LOGIN_SUCCESS("AUTH-0001", "Inicio de sesión exitoso", HttpStatus.OK),
    OPERATION_SUCCESS("BIZ-0001", "Operación realizada con éxito", HttpStatus.OK),
    LOGOUT_SUCCESS("AUTH-0002", "Sesión cerrada exitosamente", HttpStatus.OK),
    
    // Recuperación de contraseña
    RECOVERY_EMAIL_SENT("REC-0001", "Correo de recuperación enviado exitosamente. Verifique su bandeja de entrada", HttpStatus.OK),
    RECOVERY_PASSWORD_CHANGED("REC-0002", "Contraseña actualizada exitosamente", HttpStatus.OK);
    
    private final String code;
    private final String message;
    private final HttpStatus httpStatus;
    
    SuccessfulCode(String code, String message, HttpStatus httpStatus) {
        this.code = code;
        this.message = message;
        this.httpStatus = httpStatus;
    }
}
