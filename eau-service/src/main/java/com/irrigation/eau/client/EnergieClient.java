package com.irrigation.eau.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "energie-service")
public interface EnergieClient {
    
    @GetMapping("/api/pompes/{id}/disponibilite")
    Boolean isPompeDisponible(@PathVariable("id") Long pompeId);
}