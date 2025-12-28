package com.irrigation.energie.kafka;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.irrigation.energie.event.SurconsommationEvent;

@Service
public class KafkaProducerService {
    
    private static final String TOPIC = "surconsommation-events";
    
    @Autowired
    private KafkaTemplate<String, SurconsommationEvent> kafkaTemplate;
    
    public void publierSurconsommation(SurconsommationEvent event) {
        System.out.println("📢 Publication événement Kafka : " + event);
        kafkaTemplate.send(TOPIC, event);
        System.out.println("✅ Événement publié sur le topic : " + TOPIC);
    }
}