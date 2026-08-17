package com.investmenttracker.model.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChangePasswordRequest {
    
    private String username;
    private String email;
    private String actualPassword;
    private String nuevoPassword;
    private String repetirNuevoPassword;
}
