package com.irrigation.eau.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.irrigation.eau.entity.DebitMesure;

@Repository
public interface DebitMesureRepository extends JpaRepository<DebitMesure, Long> {
    
    // Trouver tous les débits d'une pompe
    List<DebitMesure> findByPompeId(Long pompeId);
    
    // Trouver les mesures entre deux dates
    List<DebitMesure> findByDateMesureBetween(LocalDateTime debut, LocalDateTime fin);
    
    // Trouver les débits supérieurs à un seuil
    List<DebitMesure> findByDebitGreaterThan(Double seuil);
    
    // Calculer le débit moyen d'une pompe
    @Query("SELECT AVG(d.debit) FROM DebitMesure d WHERE d.pompeId = :pompeId")
    Double calculerDebitMoyen(Long pompeId);
    
    // Calculer le débit total d'une pompe
    @Query("SELECT SUM(d.debit) FROM DebitMesure d WHERE d.pompeId = :pompeId")
    Double calculerDebitTotal(Long pompeId);
    
    // Trouver la dernière mesure d'une pompe
    DebitMesure findTopByPompeIdOrderByDateMesureDesc(Long pompeId);
}