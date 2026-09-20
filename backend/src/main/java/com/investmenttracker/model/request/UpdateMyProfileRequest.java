package com.investmenttracker.model.request;

import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request para actualizar el perfil del propio usuario autenticado.
 * Todos los campos son obligatorios. El username e id deben coincidir
 * con el usuario autenticado vía JWT.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateMyProfileRequest {

    @NotNull(message = "id no puede ser null")
    private UUID id;

    @NotBlank(message = "username no puede estar vacío")
    private String username;

    @NotBlank(message = "email no puede estar vacío")
    private String email;

    @NotBlank(message = "nombreCompleto no puede estar vacío")
    private String nombreCompleto;

    @NotNull(message = "paisId no puede ser null")
    private UUID paisId;

    @NotNull(message = "celular no puede ser null")
    private Long celular;
}
