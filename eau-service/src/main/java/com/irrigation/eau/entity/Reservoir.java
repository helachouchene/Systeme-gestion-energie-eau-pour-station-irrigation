package com.irrigation.eau.entity;

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
public class Reservoir {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String nom;
    
    private Double capaciteTotale; // en m³
    
    private Double volumeActuel; // en m³
    
    private String localisation;
    
    // Méthode utilitaire pour calculer le niveau de remplissage en %
    public Double getNiveauRemplissage() {
        if (capaciteTotale == null || capaciteTotale == 0) {
            return 0.0;
        }
        return (volumeActuel / capaciteTotale) * 100;
    }
    
    // Méthode pour vérifier si le niveau est critique (< 20%)
    public boolean isNiveauCritique() {
        return getNiveauRemplissage() < 20.0;
    }
    
    // Méthode pour vérifier si le réservoir est plein (> 95%)
    public boolean isPlein() {
        return getNiveauRemplissage() > 95.0;
    }
}