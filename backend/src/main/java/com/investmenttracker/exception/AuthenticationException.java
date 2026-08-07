package com.investmenttracker.exception;

import com.investmenttracker.model.enums.ErrorCode;
import lombok.Getter;

@Getter
public class AuthenticationException extends RuntimeException {
    
    private final ErrorCode errorCode;
    
    public AuthenticationException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }
    
    public AuthenticationException(ErrorCode errorCode, String customMessage) {
        super(customMessage);
        this.errorCode = errorCode;
    }
}
