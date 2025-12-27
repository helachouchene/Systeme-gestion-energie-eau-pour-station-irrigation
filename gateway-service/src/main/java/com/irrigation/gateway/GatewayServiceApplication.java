package com.irrigation.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * Gateway Service - Point d'entrée unique pour tous les microservices
 * Port: 8080
 * 
 * Ce service route toutes les requêtes vers les microservices appropriés
 * et fournit des fonctionnalités comme le load balancing et la sécurité.
 */
@SpringBootApplication
@EnableDiscoveryClient
public class GatewayServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(GatewayServiceApplication.class, args);
        System.out.println("\n==============================================");
        System.out.println("✅ Gateway Service démarré avec succès!");
        System.out.println("🌐 URL: http://localhost:8080");
        System.out.println("📡 Routes:");
        System.out.println("   - /energie/** → energie-service");
        System.out.println("   - /eau/** → eau-service");
        System.out.println("==============================================\n");
    }
}