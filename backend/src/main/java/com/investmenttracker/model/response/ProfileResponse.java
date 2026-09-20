package com.investmenttracker.model.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.investmenttracker.model.dto.PaisDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Respuesta del perfil propio del usuario autenticado.
 * Los campos sensibles (email, celular, nombre) se devuelven reales
 * porque el endpoint está en OWN_DATA_PATHS del MaskingFilter.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProfileResponse {

    private UUID id;
    private String username;
    private String email;
    private String nombreCompleto;
    private Long celular;
    private PaisDTO pais;
    private Boolean activo;
    private LocalDateTime ultimoLogin;
    private LocalDateTime createdAt;
}
