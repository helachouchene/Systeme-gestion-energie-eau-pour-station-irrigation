package com.irrigation.energie.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.irrigation.energie.entity.ConsommationElectrique;
import com.irrigation.energie.event.SurconsommationEvent;
import com.irrigation.energie.kafka.KafkaProducerService;
import com.irrigation.energie.repository.ConsommationElectriqueRepository;

@Service
public class ConsommationElectriqueService {
    
    @Autowired
    private ConsommationElectriqueRepository consommationRepository;
    
    @Autowired
    private KafkaProducerService kafkaProducerService;
    
    private static final Double SEUIL_SURCONSOMMATION = 10.0;
    
    public ConsommationElectrique enregistrerConsommation(ConsommationElectrique consommation) {
        consommation.setDateMesure(LocalDateTime.now());
        ConsommationElectrique saved = consommationRepository.save(consommation);
        
        // Vérifier surconsommation et publier événement Kafka
        if (isSurconsommation(saved.getEnergieUtilisee())) {
            SurconsommationEvent event = new SurconsommationEvent(
                saved.getPompeId(),
                saved.getEnergieUtilisee(),
                saved.getDateMesure(),
                "⚠️ ALERTE : Surconsommation détectée sur la pompe " + saved.getPompeId() + 
                " avec " + saved.getEnergieUtilisee() + " kWh"
            );
            kafkaProducerService.publierSurconsommation(event);
        }
        
        return saved;
    }
    
    public List<ConsommationElectrique> getAllConsommations() {
        return consommationRepository.findAll();
    }
    
    public Optional<ConsommationElectrique> getConsommationById(Long id) {
        return consommationRepository.findById(id);
    }
    
    public List<ConsommationElectrique> getConsommationsByPompe(Long pompeId) {
        return consommationRepository.findByPompeId(pompeId);
    }
    
    public Double calculerConsommationTotale(Long pompeId) {
        Double total = consommationRepository.calculerConsommationTotale(pompeId);
        return total != null ? total : 0.0;
    }
    
    public List<ConsommationElectrique> detecterSurconsommations() {
        return consommationRepository.findByEnergieUtiliseeGreaterThan(SEUIL_SURCONSOMMATION);
    }
    
    public boolean isSurconsommation(Double energieUtilisee) {
        return energieUtilisee > SEUIL_SURCONSOMMATION;
    }
    
    public List<ConsommationElectrique> getConsommationsBetweenDates(LocalDateTime debut, LocalDateTime fin) {
        return consommationRepository.findByDateMesureBetween(debut, fin);
    }
}