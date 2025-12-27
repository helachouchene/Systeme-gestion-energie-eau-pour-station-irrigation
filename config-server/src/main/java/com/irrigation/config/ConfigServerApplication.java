package com.irrigation.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

/**
 * Config Server - Serveur de configuration centralisée
 * Port: 8888
 * 
 * Ce service stocke toutes les configurations des microservices
 * permettant une gestion centralisée et dynamique.
 */
@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
        System.out.println("\n==============================================");
        System.out.println("✅ Config Server démarré avec succès!");
        System.out.println("🌐 URL: http://localhost:8888");
        System.out.println("==============================================\n");
    }
}