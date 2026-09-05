package com.investmenttracker.model.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.investmenttracker.model.dto.PaisDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class LoginResponse {
    
    private String token;
    private String tokenType;
    private Long expiresIn;
    private String refreshToken;
    private Long refreshTokenExpiresIn;
    private String username;
    private String email;
    private String nombreCompleto;
    private Long celular;
    private PaisDTO pais;
}
