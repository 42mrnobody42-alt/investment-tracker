package com.investmenttracker.model.request;

import com.investmenttracker.model.enums.Plan;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {
    private String username;
    private String email;
    private String password;
    private String repeatPassword;
    private Long celular;
    private UUID paisId;
    private Plan plan;
}
