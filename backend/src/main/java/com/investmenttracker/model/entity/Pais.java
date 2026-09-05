package com.investmenttracker.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.lang.NonNull;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "paises", schema = "investment_tracker")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Pais {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NonNull
    @Column(nullable = false, length = 100)
    private String nombre;

    @NonNull
    @Column(name = "codigo_iso", unique = true, nullable = false, length = 3)
    private String codigoIso;

    @NonNull
    @Column(name = "indicativo_celular", nullable = false, length = 10)
    private String indicativoCelular;

    @Column(name = "moneda_id")
    private UUID monedaId;

    @NonNull
    @Column(nullable = false)
    @Builder.Default
    private Boolean activo = true;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
