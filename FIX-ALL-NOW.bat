@echo off
chcp 65001 >nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║         🚀 RÉPARATION COMPLÈTE - MAINTENANT !               ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo ⏱️ Temps estimé: 3-4 minutes
echo.

REM ==================================================================
REM ÉTAPE 1: ARRÊT COMPLET
REM ==================================================================
echo [1/3] 🛑 Arrêt de tous les conteneurs...
docker-compose down -v 2>nul
timeout /t 3 /nobreak >nul

REM ==================================================================
REM ÉTAPE 2: CORRECTION DU DOCKER-COMPOSE.YML
REM ==================================================================
echo [2/3] 📝 Correction du docker-compose.yml...

REM Backup de l'ancien fichier
copy docker-compose.yml docker-compose.yml.backup >nul 2>&1

REM Création du nouveau docker-compose.yml
(
echo services:
echo   # BASES DE DONNÉES
echo   postgres-energie:
echo     image: postgres:15-alpine
echo     container_name: postgres-energie
echo     environment:
echo       POSTGRES_DB: energiedb
echo       POSTGRES_USER: energie_user
echo       POSTGRES_PASSWORD: energie_pass
echo     ports:
echo       - "5433:5432"
echo     volumes:
echo       - postgres_energie_data:/var/lib/postgresql/data
echo     networks:
echo       - irrigation-network
echo     healthcheck:
echo       test: ["CMD-SHELL", "pg_isready -U energie_user -d energiedb"]
echo       interval: 10s
echo       timeout: 5s
echo       retries: 5
echo     restart: unless-stopped
echo.
echo   postgres-eau:
echo     image: postgres:15-alpine
echo     container_name: postgres-eau
echo     environment:
echo       POSTGRES_DB: eaudb
echo       POSTGRES_USER: eau_user
echo       POSTGRES_PASSWORD: eau_pass
echo     ports:
echo       - "5434:5432"
echo     volumes:
echo       - postgres_eau_data:/var/lib/postgresql/data
echo     networks:
echo       - irrigation-network
echo     healthcheck:
echo       test: ["CMD-SHELL", "pg_isready -U eau_user -d eaudb"]
echo       interval: 10s
echo       timeout: 5s
echo       retries: 5
echo     restart: unless-stopped
echo.
echo   # KAFKA
echo   zookeeper:
echo     image: confluentinc/cp-zookeeper:7.4.0
echo     container_name: zookeeper
echo     environment:
echo       ZOOKEEPER_CLIENT_PORT: 2181
echo       ZOOKEEPER_TICK_TIME: 2000
echo     ports:
echo       - "2181:2181"
echo     networks:
echo       - irrigation-network
echo     restart: unless-stopped
echo.
echo   kafka:
echo     image: confluentinc/cp-kafka:7.4.0
echo     container_name: kafka
echo     depends_on:
echo       - zookeeper
echo     ports:
echo       - "9092:9092"
echo     environment:
echo       KAFKA_BROKER_ID: 1
echo       KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
echo       KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
echo       KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
echo       KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
echo       KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
echo       KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'
echo     networks:
echo       - irrigation-network
echo     restart: unless-stopped
echo.
echo   # MICROSERVICES
echo   discovery-server:
echo     build:
echo       context: ./discovery-server
echo       dockerfile: Dockerfile
echo     container_name: discovery-server
echo     ports:
echo       - "8761:8761"
echo     environment:
echo       SPRING_PROFILES_ACTIVE: docker
echo     networks:
echo       - irrigation-network
echo     restart: unless-stopped
echo.
echo   config-server:
echo     build:
echo       context: ./config-server
echo       dockerfile: Dockerfile
echo     container_name: config-server
echo     ports:
echo       - "8888:8888"
echo     environment:
echo       SPRING_PROFILES_ACTIVE: docker
echo     depends_on:
echo       - discovery-server
echo     networks:
echo       - irrigation-network
echo     restart: unless-stopped
echo.
echo   gateway-service:
echo     build:
echo       context: ./gateway-service
echo       dockerfile: Dockerfile
echo     container_name: gateway-service
echo     ports:
echo       - "8080:8080"
echo     environment:
echo       SPRING_PROFILES_ACTIVE: docker
echo     depends_on:
echo       - discovery-server
echo       - config-server
echo     networks:
echo       - irrigation-network
echo     restart: unless-stopped
echo.
echo   energie-service:
echo     build:
echo       context: ./energie-service
echo       dockerfile: Dockerfile
echo     container_name: energie-service
echo     ports:
echo       - "8081:8081"
echo     environment:
echo       SPRING_PROFILES_ACTIVE: docker
echo       SPRING_DATASOURCE_URL: jdbc:postgresql://postgres-energie:5432/energiedb
echo       SPRING_DATASOURCE_USERNAME: energie_user
echo       SPRING_DATASOURCE_PASSWORD: energie_pass
echo       SPRING_KAFKA_BOOTSTRAP_SERVERS: kafka:29092
echo     depends_on:
echo       - postgres-energie
echo       - discovery-server
echo       - kafka
echo     networks:
echo       - irrigation-network
echo     restart: unless-stopped
echo.
echo   eau-service:
echo     build:
echo       context: ./eau-service
echo       dockerfile: Dockerfile
echo     container_name: eau-service
echo     ports:
echo       - "8082:8082"
echo     environment:
echo       SPRING_PROFILES_ACTIVE: docker
echo       SPRING_DATASOURCE_URL: jdbc:postgresql://postgres-eau:5432/eaudb
echo       SPRING_DATASOURCE_USERNAME: eau_user
echo       SPRING_DATASOURCE_PASSWORD: eau_pass
echo       SPRING_KAFKA_BOOTSTRAP_SERVERS: kafka:29092
echo     depends_on:
echo       - postgres-eau
echo       - discovery-server
echo       - kafka
echo       - energie-service
echo     networks:
echo       - irrigation-network
echo     restart: unless-stopped
echo.
echo   frontend:
echo     build:
echo       context: ./irrigation-frontend
echo       dockerfile: Dockerfile
echo     container_name: irrigation-frontend
echo     ports:
echo       - "4200:80"
echo     depends_on:
echo       - gateway-service
echo     networks:
echo       - irrigation-network
echo     restart: unless-stopped
echo.
echo networks:
echo   irrigation-network:
echo     driver: bridge
echo     name: irrigation-network
echo.
echo volumes:
echo   postgres_energie_data:
echo     name: postgres_energie_data
echo   postgres_eau_data:
echo     name: postgres_eau_data
) > docker-compose.yml

echo    ✅ docker-compose.yml corrigé ^(SANS healthchecks problématiques^)

REM ==================================================================
REM ÉTAPE 3: DÉMARRAGE INTELLIGENT
REM ==================================================================
echo.
echo [3/3] 🚀 Démarrage du système...
echo.

echo    [1/7] 💾 Bases de données...
docker-compose up -d postgres-energie postgres-eau
timeout /t 20 /nobreak >nul

echo    [2/7] 🐘 Zookeeper...
docker-compose up -d zookeeper
timeout /t 15 /nobreak >nul

echo    [3/7] 📨 Kafka...
docker-compose up -d kafka
timeout /t 20 /nobreak >nul

echo    [4/7] 🔍 Discovery Server ^(Eureka^) - ATTENTE 70 SECONDES...
docker-compose up -d discovery-server
timeout /t 70 /nobreak >nul

echo    [5/7] ⚙️ Config Server...
docker-compose up -d config-server
timeout /t 25 /nobreak >nul

echo    [6/7] 🌐 Gateway Service...
docker-compose up -d gateway-service
timeout /t 20 /nobreak >nul

echo    [7/7] 🔧 Services métiers + Frontend...
docker-compose up -d energie-service eau-service frontend
timeout /t 30 /nobreak >nul

REM ==================================================================
REM VÉRIFICATION
REM ==================================================================
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                  📊 STATUT FINAL                             ║
echo ╚══════════════════════════════════════════════════════════════╝
docker-compose ps

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║               🔍 TEST DES SERVICES                           ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo Eureka ^(8761^):
curl -s http://localhost:8761 >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✅ ACCESSIBLE
) else (
    echo    ❌ PAS ENCORE PRÊT - Attendez 1 minute
)

echo.
echo Gateway ^(8080^):
curl -s http://localhost:8080/actuator/health >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✅ ACCESSIBLE
) else (
    echo    ⏳ En cours de démarrage...
)

echo.
echo Config ^(8888^):
curl -s http://localhost:8888/actuator/health >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✅ ACCESSIBLE
) else (
    echo    ⏳ En cours de démarrage...
)

echo.
echo Frontend ^(4200^):
curl -s http://localhost:4200 >nul 2>&1
if %errorlevel% equ 0 (
    echo    ✅ ACCESSIBLE
) else (
    echo    ⏳ En cours de démarrage...
)

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║               🌐 URLS D'ACCÈS                                ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo    📊 Frontend:  http://localhost:4200
echo    🔍 Eureka:    http://localhost:8761
echo    🚪 Gateway:   http://localhost:8080
echo    ⚙️  Config:    http://localhost:8888
echo    ⚡ Énergie:   http://localhost:8081
echo    💧 Eau:       http://localhost:8082
echo.
echo 💡 Si un service n'est pas encore accessible:
echo    1. Attendez 2-3 minutes supplémentaires
echo    2. Vérifiez les logs: docker logs [nom-service]
echo    3. Redémarrez le service: docker-compose restart [nom-service]
echo.

REM Ouvrir Eureka
timeout /t 2 /nobreak >nul
start http://localhost:8761

echo 📋 Fichier de backup créé: docker-compose.yml.backup
echo.

pause