package com.irrigation.energie.entity;

import java.time.LocalDate;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
public class Pompe {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String reference;
    
    private Double puissance; // en kW
    
    @Enumerated(EnumType.STRING)
    private StatutPompe statut;
    
    private LocalDate dateMiseEnService;
    
    // Enum pour le statut
    public enum StatutPompe {
        ACTIF,
        INACTIF,
        EN_MAINTENANCE
    }
}