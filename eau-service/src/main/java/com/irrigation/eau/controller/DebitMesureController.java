package com.irrigation.eau.controller;

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

import com.irrigation.eau.entity.DebitMesure;
import com.irrigation.eau.service.DebitMesureService;

@RestController
@RequestMapping("/api/debits")
public class DebitMesureController {
    
    @Autowired
    private DebitMesureService debitMesureService;
    
    // Enregistrer une nouvelle mesure de débit
    @PostMapping
    public ResponseEntity<DebitMesure> enregistrerDebit(@RequestBody DebitMesure debitMesure) {
        DebitMesure nouveauDebit = debitMesureService.enregistrerDebit(debitMesure);
        return new ResponseEntity<>(nouveauDebit, HttpStatus.CREATED);
    }
    
    // Récupérer toutes les mesures de débit
    @GetMapping
    public ResponseEntity<List<DebitMesure>> getAllDebits() {
        List<DebitMesure> debits = debitMesureService.getAllDebits();
        return ResponseEntity.ok(debits);
    }
    
    // Récupérer une mesure par ID
    @GetMapping("/{id}")
    public ResponseEntity<DebitMesure> getDebitById(@PathVariable Long id) {
        return debitMesureService.getDebitById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    // Récupérer les débits d'une pompe
    @GetMapping("/pompe/{pompeId}")
    public ResponseEntity<List<DebitMesure>> getDebitsByPompe(@PathVariable Long pompeId) {
        List<DebitMesure> debits = debitMesureService.getDebitsByPompe(pompeId);
        return ResponseEntity.ok(debits);
    }
    
    // Calculer le débit moyen d'une pompe
    @GetMapping("/pompe/{pompeId}/moyen")
    public ResponseEntity<Double> getDebitMoyen(@PathVariable Long pompeId) {
        Double debitMoyen = debitMesureService.calculerDebitMoyen(pompeId);
        return ResponseEntity.ok(debitMoyen);
    }
    
    // Calculer le débit total d'une pompe
    @GetMapping("/pompe/{pompeId}/total")
    public ResponseEntity<Double> getDebitTotal(@PathVariable Long pompeId) {
        Double debitTotal = debitMesureService.calculerDebitTotal(pompeId);
        return ResponseEntity.ok(debitTotal);
    }
    
    // Détecter les débits anormaux
    @GetMapping("/alertes/anormaux")
    public ResponseEntity<List<DebitMesure>> detecterDebitsAnormaux() {
        List<DebitMesure> debitsAnormaux = debitMesureService.detecterDebitsAnormaux();
        return ResponseEntity.ok(debitsAnormaux);
    }
    
    // Récupérer les débits entre deux dates
    @GetMapping("/periode")
    public ResponseEntity<List<DebitMesure>> getDebitsBetweenDates(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime debut,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin) {
        List<DebitMesure> debits = debitMesureService.getDebitsBetweenDates(debut, fin);
        return ResponseEntity.ok(debits);
    }
    
    // Récupérer la dernière mesure d'une pompe
    @GetMapping("/pompe/{pompeId}/dernier")
    public ResponseEntity<DebitMesure> getDernierDebit(@PathVariable Long pompeId) {
        DebitMesure dernierDebit = debitMesureService.getDernierDebit(pompeId);
        if (dernierDebit != null) {
            return ResponseEntity.ok(dernierDebit);
        }
        return ResponseEntity.notFound().build();
    }
}