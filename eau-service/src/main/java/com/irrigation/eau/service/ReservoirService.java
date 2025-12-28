package com.irrigation.eau.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.irrigation.eau.client.EnergieClient;
import com.irrigation.eau.entity.Reservoir;
import com.irrigation.eau.repository.ReservoirRepository;

@Service
public class ReservoirService {
    
    @Autowired
    private ReservoirRepository reservoirRepository;
    
    @Autowired
    private EnergieClient energieClient;
    
    // Créer un nouveau réservoir
    public Reservoir creerReservoir(Reservoir reservoir) {
        return reservoirRepository.save(reservoir);
    }
    
    // Récupérer tous les réservoirs
    public List<Reservoir> getAllReservoirs() {
        return reservoirRepository.findAll();
    }
    
    // Récupérer un réservoir par ID
    public Optional<Reservoir> getReservoirById(Long id) {
        return reservoirRepository.findById(id);
    }
    
    // Mettre à jour un réservoir
    public Reservoir updateReservoir(Long id, Reservoir reservoirDetails) {
        Reservoir reservoir = reservoirRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Réservoir non trouvé avec l'id : " + id));
        
        reservoir.setNom(reservoirDetails.getNom());
        reservoir.setCapaciteTotale(reservoirDetails.getCapaciteTotale());
        reservoir.setVolumeActuel(reservoirDetails.getVolumeActuel());
        reservoir.setLocalisation(reservoirDetails.getLocalisation());
        
        return reservoirRepository.save(reservoir);
    }
    
    // Supprimer un réservoir
    public void deleteReservoir(Long id) {
        reservoirRepository.deleteById(id);
    }
    
    // Mettre à jour le volume actuel d'un réservoir
    public Reservoir updateVolume(Long id, Double nouveauVolume) {
        Reservoir reservoir = reservoirRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Réservoir non trouvé avec l'id : " + id));
        
        reservoir.setVolumeActuel(nouveauVolume);
        return reservoirRepository.save(reservoir);
    }
    
    // Récupérer les réservoirs par localisation
    public List<Reservoir> getReservoirsByLocalisation(String localisation) {
        return reservoirRepository.findByLocalisation(localisation);
    }
    
    // Récupérer les réservoirs avec niveau critique
    public List<Reservoir> getReservoirsNiveauCritique() {
        return reservoirRepository.findReservoirsNiveauCritique();
    }
    
    // Récupérer les réservoirs presque pleins
    public List<Reservoir> getReservoirsPresquePleins() {
        return reservoirRepository.findReservoirsPresquePleins();
    }
    
    // Calculer le niveau de remplissage d'un réservoir
    public Double getNiveauRemplissage(Long id) {
        Reservoir reservoir = reservoirRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Réservoir non trouvé avec l'id : " + id));
        
        return reservoir.getNiveauRemplissage();
    }
    
    // Vérifier si un réservoir a un niveau critique
    public boolean hasNiveauCritique(Long id) {
        Reservoir reservoir = reservoirRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Réservoir non trouvé avec l'id : " + id));
        
        return reservoir.isNiveauCritique();
    }
    
    // NOUVELLE MÉTHODE : Vérifier si on peut utiliser une pompe
    public boolean peutUtiliserPompe(Long pompeId) {
        try {
            Boolean disponible = energieClient.isPompeDisponible(pompeId);
            return disponible != null && disponible;
        } catch (Exception e) {
            System.err.println("Erreur lors de la communication avec le service Énergie : " + e.getMessage());
            return false;
        }
    }
    
    // NOUVELLE MÉTHODE : Remplir un réservoir avec vérification de la pompe
    public String remplirReservoir(Long reservoirId, Long pompeId, Double volume) {
        Reservoir reservoir = reservoirRepository.findById(reservoirId)
            .orElseThrow(() -> new RuntimeException("Réservoir non trouvé avec l'id : " + reservoirId));
        
        if (!peutUtiliserPompe(pompeId)) {
            return "ERREUR : La pompe " + pompeId + " n'est pas disponible. Opération annulée.";
        }
        
        Double nouveauVolume = reservoir.getVolumeActuel() + volume;
        if (nouveauVolume > reservoir.getCapaciteTotale()) {
            return "ERREUR : Dépassement de capacité. Capacité max : " + reservoir.getCapaciteTotale() + " m³";
        }
        
        reservoir.setVolumeActuel(nouveauVolume);
        reservoirRepository.save(reservoir);
        
        return "SUCCESS : Réservoir rempli. Nouveau volume : " + nouveauVolume + " m³ (" + reservoir.getNiveauRemplissage() + "%)";
    }
}