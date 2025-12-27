package com.irrigation.energie.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.irrigation.energie.entity.ConsommationElectrique;

@Repository
public interface ConsommationElectriqueRepository extends JpaRepository<ConsommationElectrique, Long> {
    
    // Trouver toutes les consommations d'une pompe
    List<ConsommationElectrique> findByPompeId(Long pompeId);
    
    // Trouver les consommations entre 2 dates
    List<ConsommationElectrique> findByDateMesureBetween(LocalDateTime debut, LocalDateTime fin);
    
    // Trouver les surconsommations (plus de 10 kWh)
    List<ConsommationElectrique> findByEnergieUtiliseeGreaterThan(Double seuil);
    
    // Calculer la consommation totale d'une pompe (requête personnalisée)
    @Query("SELECT SUM(c.energieUtilisee) FROM ConsommationElectrique c WHERE c.pompeId = :pompeId")
    Double calculerConsommationTotale(Long pompeId);
}