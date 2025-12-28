package com.irrigation.eau.kafka;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.irrigation.eau.event.SurconsommationEvent;

@Service
public class KafkaConsumerService {
    
    @KafkaListener(topics = "surconsommation-events", groupId = "eau-service-group")
    public void consommerSurconsommation(SurconsommationEvent event) {
        System.out.println("🔔 ÉVÉNEMENT REÇU dans le service EAU !");
        System.out.println("📩 Détails : " + event);
        System.out.println("⚠️ ALERTE : Pompe " + event.getPompeId() + 
                         " en surconsommation (" + event.getEnergieUtilisee() + " kWh)");
        System.out.println("🛑 ACTION : Arrêt de la pompe " + event.getPompeId() + " recommandé !");
        
        // Ici vous pouvez ajouter la logique pour arrêter la pompe
        // Par exemple : appeler le service Énergie pour changer le statut
    }
}