package com.irrigation.eau.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.irrigation.eau.entity.Reservoir;

@Repository
public interface ReservoirRepository extends JpaRepository<Reservoir, Long> {
    
    // Trouver un réservoir par nom
    List<Reservoir> findByNom(String nom);
    
    // Trouver les réservoirs par localisation
    List<Reservoir> findByLocalisation(String localisation);
    
    // Trouver les réservoirs avec capacité supérieure à un seuil
    List<Reservoir> findByCapaciteTotaleGreaterThan(Double capacite);
    
    // Trouver les réservoirs avec niveau critique (volume < 20% de la capacité)
    @Query("SELECT r FROM Reservoir r WHERE (r.volumeActuel / r.capaciteTotale) < 0.20")
    List<Reservoir> findReservoirsNiveauCritique();
    
    // Trouver les réservoirs presque pleins (volume > 95% de la capacité)
    @Query("SELECT r FROM Reservoir r WHERE (r.volumeActuel / r.capaciteTotale) > 0.95")
    List<Reservoir> findReservoirsPresquePleins();
}