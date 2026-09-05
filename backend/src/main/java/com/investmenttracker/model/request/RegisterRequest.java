package com.investmenttracker.model.request;

import java.util.UUID;

import com.investmenttracker.model.enums.Plan;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {
    private String username;
    private String email;
    private String nombreCompleto;
    private String password;
    private String repeatPassword;
    private Long celular;
    private UUID paisId;
    private Plan plan;
}
