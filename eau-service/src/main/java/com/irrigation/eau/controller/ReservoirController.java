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
    
    @PostMapping
    public ResponseEntity<Reservoir> creerReservoir(@RequestBody Reservoir reservoir) {
        Reservoir nouveauReservoir = reservoirService.creerReservoir(reservoir);
        return new ResponseEntity<>(nouveauReservoir, HttpStatus.CREATED);
    }
    
    @GetMapping
    public ResponseEntity<List<Reservoir>> getAllReservoirs() {
        List<Reservoir> reservoirs = reservoirService.getAllReservoirs();
        return ResponseEntity.ok(reservoirs);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Reservoir> getReservoirById(@PathVariable Long id) {
        return reservoirService.getReservoirById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Reservoir> updateReservoir(@PathVariable Long id, @RequestBody Reservoir reservoirDetails) {
        try {
            Reservoir reservoirUpdated = reservoirService.updateReservoir(id, reservoirDetails);
            return ResponseEntity.ok(reservoirUpdated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReservoir(@PathVariable Long id) {
        reservoirService.deleteReservoir(id);
        return ResponseEntity.noContent().build();
    }
    
    @PutMapping("/{id}/volume")
    public ResponseEntity<Reservoir> updateVolume(@PathVariable Long id, @RequestParam Double volume) {
        try {
            Reservoir reservoirUpdated = reservoirService.updateVolume(id, volume);
            return ResponseEntity.ok(reservoirUpdated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/{id}/niveau")
    public ResponseEntity<Double> getNiveauRemplissage(@PathVariable Long id) {
        try {
            Double niveau = reservoirService.getNiveauRemplissage(id);
            return ResponseEntity.ok(niveau);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping("/localisation/{localisation}")
    public ResponseEntity<List<Reservoir>> getReservoirsByLocalisation(@PathVariable String localisation) {
        List<Reservoir> reservoirs = reservoirService.getReservoirsByLocalisation(localisation);
        return ResponseEntity.ok(reservoirs);
    }
    
    @GetMapping("/alertes/niveau-critique")
    public ResponseEntity<List<Reservoir>> getReservoirsNiveauCritique() {
        List<Reservoir> reservoirs = reservoirService.getReservoirsNiveauCritique();
        return ResponseEntity.ok(reservoirs);
    }
    
    @GetMapping("/alertes/presque-pleins")
    public ResponseEntity<List<Reservoir>> getReservoirsPresquePleins() {
        List<Reservoir> reservoirs = reservoirService.getReservoirsPresquePleins();
        return ResponseEntity.ok(reservoirs);
    }
    
    @GetMapping("/test-pompe/{pompeId}")
    public ResponseEntity<String> testCommunicationPompe(@PathVariable Long pompeId) {
        boolean disponible = reservoirService.peutUtiliserPompe(pompeId);
        if (disponible) {
            return ResponseEntity.ok("✅ La pompe " + pompeId + " est DISPONIBLE");
        } else {
            return ResponseEntity.ok("❌ La pompe " + pompeId + " est INDISPONIBLE");
        }
    }
    
    @PostMapping("/{reservoirId}/remplir")
    public ResponseEntity<String> remplirReservoir(
            @PathVariable Long reservoirId, 
            @RequestParam Long pompeId, 
            @RequestParam Double volume) {
        String resultat = reservoirService.remplirReservoir(reservoirId, pompeId, volume);
        return ResponseEntity.ok(resultat);
    }
}