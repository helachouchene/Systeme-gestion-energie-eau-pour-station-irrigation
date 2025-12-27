package com.irrigation.energie.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.irrigation.energie.entity.ConsommationElectrique;
import com.irrigation.energie.repository.ConsommationElectriqueRepository;

@Service
public class ConsommationElectriqueService {
    
    @Autowired
    private ConsommationElectriqueRepository consommationRepository;
    
    // Seuil de surconsommation (en kWh)
    private static final Double SEUIL_SURCONSOMMATION = 10.0;
    
    // Enregistrer une nouvelle consommation
    public ConsommationElectrique enregistrerConsommation(ConsommationElectrique consommation) {
        consommation.setDateMesure(LocalDateTime.now());
        return consommationRepository.save(consommation);
    }
    
    // Récupérer toutes les consommations
    public List<ConsommationElectrique> getAllConsommations() {
        return consommationRepository.findAll();
    }
    
    // Récupérer une consommation par ID
    public Optional<ConsommationElectrique> getConsommationById(Long id) {
        return consommationRepository.findById(id);
    }
    
    // Récupérer les consommations d'une pompe
    public List<ConsommationElectrique> getConsommationsByPompe(Long pompeId) {
        return consommationRepository.findByPompeId(pompeId);
    }
    
    // Calculer la consommation totale d'une pompe
    public Double calculerConsommationTotale(Long pompeId) {
        Double total = consommationRepository.calculerConsommationTotale(pompeId);
        return total != null ? total : 0.0;
    }
    
    // Détecter les surconsommations
    public List<ConsommationElectrique> detecterSurconsommations() {
        return consommationRepository.findByEnergieUtiliseeGreaterThan(SEUIL_SURCONSOMMATION);
    }
    
    // Vérifier si une consommation est excessive
    public boolean isSurconsommation(Double energieUtilisee) {
        return energieUtilisee > SEUIL_SURCONSOMMATION;
    }
    
    // Récupérer les consommations entre deux dates
    public List<ConsommationElectrique> getConsommationsBetweenDates(LocalDateTime debut, LocalDateTime fin) {
        return consommationRepository.findByDateMesureBetween(debut, fin);
    }
}