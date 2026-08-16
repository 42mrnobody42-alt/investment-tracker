package com.investmenttracker.model.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EncryptionResponse {
    
    private String textoOriginal;
    private String textoEncriptado;
    private String textoDesencriptado;
}
