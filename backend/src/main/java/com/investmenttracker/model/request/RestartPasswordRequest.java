package com.investmenttracker.model.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RestartPasswordRequest {
    
    @NotBlank(message = "El username es requerido")
    private String username;
    
    @NotBlank(message = "El email es requerido")
    private String email;
    
    @NotBlank(message = "El nombre completo es requerido")
    private String nombreCompleto;
    
    @NotBlank(message = "El nuevo password es requerido")
    @Size(min = 8, message = "El password debe tener al menos 8 caracteres")
    private String nuevoPassword;
    
    @NotBlank(message = "La repetición del password es requerida")
    private String repetirNuevoPassword;
}
