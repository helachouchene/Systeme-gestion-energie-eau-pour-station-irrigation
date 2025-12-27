package com.irrigation.energie.controller;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.irrigation.energie.entity.ConsommationElectrique;
import com.irrigation.energie.service.ConsommationElectriqueService;

@RestController
@RequestMapping("/api/consommations")
public class ConsommationElectriqueController {
    
    @Autowired
    private ConsommationElectriqueService consommationService;
    
    // Enregistrer une nouvelle consommation
    @PostMapping
    public ResponseEntity<ConsommationElectrique> enregistrerConsommation(@RequestBody ConsommationElectrique consommation) {
        ConsommationElectrique nouvelleConsommation = consommationService.enregistrerConsommation(consommation);
        return new ResponseEntity<>(nouvelleConsommation, HttpStatus.CREATED);
    }
    
    // Récupérer toutes les consommations
    @GetMapping
    public ResponseEntity<List<ConsommationElectrique>> getAllConsommations() {
        List<ConsommationElectrique> consommations = consommationService.getAllConsommations();
        return ResponseEntity.ok(consommations);
    }
    
    // Récupérer une consommation par ID
    @GetMapping("/{id}")
    public ResponseEntity<ConsommationElectrique> getConsommationById(@PathVariable Long id) {
        return consommationService.getConsommationById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    // Récupérer les consommations d'une pompe
    @GetMapping("/pompe/{pompeId}")
    public ResponseEntity<List<ConsommationElectrique>> getConsommationsByPompe(@PathVariable Long pompeId) {
        List<ConsommationElectrique> consommations = consommationService.getConsommationsByPompe(pompeId);
        return ResponseEntity.ok(consommations);
    }
    
    // Calculer la consommation totale d'une pompe
    @GetMapping("/pompe/{pompeId}/total")
    public ResponseEntity<Double> getConsommationTotale(@PathVariable Long pompeId) {
        Double total = consommationService.calculerConsommationTotale(pompeId);
        return ResponseEntity.ok(total);
    }
    
    // Détecter les surconsommations
    @GetMapping("/surconsommation")
    public ResponseEntity<List<ConsommationElectrique>> detecterSurconsommations() {
        List<ConsommationElectrique> surconsommations = consommationService.detecterSurconsommations();
        return ResponseEntity.ok(surconsommations);
    }
    
    // Récupérer les consommations entre deux dates
    @GetMapping("/periode")
    public ResponseEntity<List<ConsommationElectrique>> getConsommationsBetweenDates(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime debut,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin) {
        List<ConsommationElectrique> consommations = consommationService.getConsommationsBetweenDates(debut, fin);
        return ResponseEntity.ok(consommations);
    }
}