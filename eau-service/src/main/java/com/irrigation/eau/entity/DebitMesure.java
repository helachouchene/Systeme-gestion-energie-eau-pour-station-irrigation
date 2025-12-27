package com.irrigation.eau.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DebitMesure {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Long pompeId;
    
    private Double debit; // en L/min
    
    private LocalDateTime dateMesure;
    
    private String unite; // Unité de mesure (L/min, m³/h, etc.)
    
    // Méthode utilitaire pour convertir en m³/h
    public Double getDebitEnM3ParHeure() {
        if (debit == null) {
            return 0.0;
        }
        // Conversion de L/min vers m³/h
        // 1 m³ = 1000 L
        // 1 h = 60 min
        return (debit * 60) / 1000;
    }
}