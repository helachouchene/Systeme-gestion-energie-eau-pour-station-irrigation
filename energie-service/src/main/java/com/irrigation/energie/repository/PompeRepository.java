package com.irrigation.energie.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.irrigation.energie.entity.Pompe;
import com.irrigation.energie.entity.Pompe.StatutPompe;

@Repository
public interface PompeRepository extends JpaRepository<Pompe, Long> {
    
    // Méthodes personnalisées (Spring Data les génère automatiquement)
    
    List<Pompe> findByStatut(StatutPompe statut);
    
    List<Pompe> findByReference(String reference);
    
    List<Pompe> findByPuissanceGreaterThan(Double puissance);
}