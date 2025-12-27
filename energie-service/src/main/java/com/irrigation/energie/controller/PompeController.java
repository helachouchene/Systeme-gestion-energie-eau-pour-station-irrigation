package com.irrigation.energie.controller;

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

import com.irrigation.energie.entity.Pompe;
import com.irrigation.energie.entity.Pompe.StatutPompe;
import com.irrigation.energie.service.PompeService;

@RestController
@RequestMapping("/api/pompes")
public class PompeController {
    
    @Autowired
    private PompeService pompeService;
    
    // Créer une nouvelle pompe
    @PostMapping
    public ResponseEntity<Pompe> creerPompe(@RequestBody Pompe pompe) {
        Pompe nouvellePompe = pompeService.creerPompe(pompe);
        return new ResponseEntity<>(nouvellePompe, HttpStatus.CREATED);
    }
    
    // Récupérer toutes les pompes
    @GetMapping
    public ResponseEntity<List<Pompe>> getAllPompes() {
        List<Pompe> pompes = pompeService.getAllPompes();
        return ResponseEntity.ok(pompes);
    }
    
    // Récupérer une pompe par ID
    @GetMapping("/{id}")
    public ResponseEntity<Pompe> getPompeById(@PathVariable Long id) {
        return pompeService.getPompeById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    // Mettre à jour une pompe
    @PutMapping("/{id}")
    public ResponseEntity<Pompe> updatePompe(@PathVariable Long id, @RequestBody Pompe pompeDetails) {
        try {
            Pompe pompeUpdated = pompeService.updatePompe(id, pompeDetails);
            return ResponseEntity.ok(pompeUpdated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Supprimer une pompe
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePompe(@PathVariable Long id) {
        pompeService.deletePompe(id);
        return ResponseEntity.noContent().build();
    }
    
    // Récupérer les pompes par statut
    @GetMapping("/statut/{statut}")
    public ResponseEntity<List<Pompe>> getPompesByStatut(@PathVariable StatutPompe statut) {
        List<Pompe> pompes = pompeService.getPompesByStatut(statut);
        return ResponseEntity.ok(pompes);
    }
    
    // Vérifier la disponibilité d'une pompe (pour communication avec eau-service)
    @GetMapping("/{id}/disponibilite")
    public ResponseEntity<Boolean> isPompeDisponible(@PathVariable Long id) {
        boolean disponible = pompeService.isPompeDisponible(id);
        return ResponseEntity.ok(disponible);
    }
}