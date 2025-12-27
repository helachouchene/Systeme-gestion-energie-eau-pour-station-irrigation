package com.irrigation.energie.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.irrigation.energie.entity.Pompe;
import com.irrigation.energie.entity.Pompe.StatutPompe;
import com.irrigation.energie.repository.PompeRepository;

@Service
public class PompeService {
    
    @Autowired
    private PompeRepository pompeRepository;
    
    // Créer une nouvelle pompe
    public Pompe creerPompe(Pompe pompe) {
        return pompeRepository.save(pompe);
    }
    
    // Récupérer toutes les pompes
    public List<Pompe> getAllPompes() {
        return pompeRepository.findAll();
    }
    
    // Récupérer une pompe par ID
    public Optional<Pompe> getPompeById(Long id) {
        return pompeRepository.findById(id);
    }
    
    // Mettre à jour une pompe
    public Pompe updatePompe(Long id, Pompe pompeDetails) {
        Pompe pompe = pompeRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Pompe non trouvée avec l'id : " + id));
        
        pompe.setReference(pompeDetails.getReference());
        pompe.setPuissance(pompeDetails.getPuissance());
        pompe.setStatut(pompeDetails.getStatut());
        pompe.setDateMiseEnService(pompeDetails.getDateMiseEnService());
        
        return pompeRepository.save(pompe);
    }
    
    // Supprimer une pompe
    public void deletePompe(Long id) {
        pompeRepository.deleteById(id);
    }
    
    // Récupérer les pompes par statut
    public List<Pompe> getPompesByStatut(StatutPompe statut) {
        return pompeRepository.findByStatut(statut);
    }
    
    // Vérifier si une pompe est disponible (pour la communication avec eau-service)
    public boolean isPompeDisponible(Long id) {
        Optional<Pompe> pompe = pompeRepository.findById(id);
        return pompe.isPresent() && pompe.get().getStatut() == StatutPompe.ACTIF;
    }
}