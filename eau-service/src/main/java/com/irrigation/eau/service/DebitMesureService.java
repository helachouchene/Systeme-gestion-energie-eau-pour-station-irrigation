package com.irrigation.eau.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.irrigation.eau.entity.DebitMesure;
import com.irrigation.eau.repository.DebitMesureRepository;

@Service
public class DebitMesureService {
    
    @Autowired
    private DebitMesureRepository debitMesureRepository;
    
    // Seuil de débit anormal (en L/min)
    private static final Double SEUIL_DEBIT_ANORMAL = 100.0;
    
    // Enregistrer une nouvelle mesure de débit
    public DebitMesure enregistrerDebit(DebitMesure debitMesure) {
        debitMesure.setDateMesure(LocalDateTime.now());
        if (debitMesure.getUnite() == null) {
            debitMesure.setUnite("L/min");
        }
        return debitMesureRepository.save(debitMesure);
    }
    
    // Récupérer toutes les mesures de débit
    public List<DebitMesure> getAllDebits() {
        return debitMesureRepository.findAll();
    }
    
    // Récupérer une mesure par ID
    public Optional<DebitMesure> getDebitById(Long id) {
        return debitMesureRepository.findById(id);
    }
    
    // Récupérer les débits d'une pompe
    public List<DebitMesure> getDebitsByPompe(Long pompeId) {
        return debitMesureRepository.findByPompeId(pompeId);
    }
    
    // Calculer le débit moyen d'une pompe
    public Double calculerDebitMoyen(Long pompeId) {
        Double moyenne = debitMesureRepository.calculerDebitMoyen(pompeId);
        return moyenne != null ? moyenne : 0.0;
    }
    
    // Calculer le débit total d'une pompe
    public Double calculerDebitTotal(Long pompeId) {
        Double total = debitMesureRepository.calculerDebitTotal(pompeId);
        return total != null ? total : 0.0;
    }
    
    // Détecter les débits anormaux (trop élevés)
    public List<DebitMesure> detecterDebitsAnormaux() {
        return debitMesureRepository.findByDebitGreaterThan(SEUIL_DEBIT_ANORMAL);
    }
    
    // Vérifier si un débit est anormal
    public boolean isDebitAnormal(Double debit) {
        return debit > SEUIL_DEBIT_ANORMAL;
    }
    
    // Récupérer les débits entre deux dates
    public List<DebitMesure> getDebitsBetweenDates(LocalDateTime debut, LocalDateTime fin) {
        return debitMesureRepository.findByDateMesureBetween(debut, fin);
    }
    
    // Récupérer la dernière mesure d'une pompe
    public DebitMesure getDernierDebit(Long pompeId) {
        return debitMesureRepository.findTopByPompeIdOrderByDateMesureDesc(pompeId);
    }
}