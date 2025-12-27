package com.irrigation.eau.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.irrigation.eau.entity.Reservoir;
import com.irrigation.eau.service.ReservoirService;

@RestController
@RequestMapping("/api/reservoirs")
public class ReservoirController {
    
    @Autowired
    private ReservoirService reservoirService;
    
    // Créer un nouveau réservoir
    @PostMapping
    public ResponseEntity<Reservoir> creerReservoir(@RequestBody Reservoir reservoir) {
        Reservoir nouveauReservoir = reservoirService.creerReservoir(reservoir);
        return new ResponseEntity<>(nouveauReservoir, HttpStatus.CREATED);
    }
    
    // Récupérer tous les réservoirs
    @GetMapping
    public ResponseEntity<List<Reservoir>> getAllReservoirs() {
        List<Reservoir> reservoirs = reservoirService.getAllReservoirs();
        return ResponseEntity.ok(reservoirs);
    }
    
    // Récupérer un réservoir par ID
    @GetMapping("/{id}")
    public ResponseEntity<Reservoir> getReservoirById(@PathVariable Long id) {
        return reservoirService.getReservoirById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    // Mettre à jour un réservoir
    @PutMapping("/{id}")
    public ResponseEntity<Reservoir> updateReservoir(@PathVariable Long id, @RequestBody Reservoir reservoirDetails) {
        try {
            Reservoir reservoirUpdated = reservoirService.updateReservoir(id, reservoirDetails);
            return ResponseEntity.ok(reservoirUpdated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Supprimer un réservoir
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReservoir(@PathVariable Long id) {
        reservoirService.deleteReservoir(id);
        return ResponseEntity.noContent().build();
    }
    
    // Mettre à jour le volume d'un réservoir
    @PutMapping("/{id}/volume")
    public ResponseEntity<Reservoir> updateVolume(@PathVariable Long id, @RequestParam Double volume) {
        try {
            Reservoir reservoirUpdated = reservoirService.updateVolume(id, volume);
            return ResponseEntity.ok(reservoirUpdated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Récupérer le niveau de remplissage d'un réservoir
    @GetMapping("/{id}/niveau")
    public ResponseEntity<Double> getNiveauRemplissage(@PathVariable Long id) {
        try {
            Double niveau = reservoirService.getNiveauRemplissage(id);
            return ResponseEntity.ok(niveau);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Récupérer les réservoirs par localisation
    @GetMapping("/localisation/{localisation}")
    public ResponseEntity<List<Reservoir>> getReservoirsByLocalisation(@PathVariable String localisation) {
        List<Reservoir> reservoirs = reservoirService.getReservoirsByLocalisation(localisation);
        return ResponseEntity.ok(reservoirs);
    }
    
    // Récupérer les réservoirs avec niveau critique
    @GetMapping("/alertes/niveau-critique")
    public ResponseEntity<List<Reservoir>> getReservoirsNiveauCritique() {
        List<Reservoir> reservoirs = reservoirService.getReservoirsNiveauCritique();
        return ResponseEntity.ok(reservoirs);
    }
    
    // Récupérer les réservoirs presque pleins
    @GetMapping("/alertes/presque-pleins")
    public ResponseEntity<List<Reservoir>> getReservoirsPresquePleins() {
        List<Reservoir> reservoirs = reservoirService.getReservoirsPresquePleins();
        return ResponseEntity.ok(reservoirs);
    }
}