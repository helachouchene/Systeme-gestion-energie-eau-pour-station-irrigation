@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║         🔧 RÉPARATION DU SYSTÈME DOCKER                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo 🛑 Étape 1/5: Arrêt complet de tous les conteneurs...
docker-compose down -v 2>nul
timeout /t 3 /nobreak >nul

echo.
echo 🧹 Étape 2/5: Nettoyage des processus bloquants...
echo    Recherche des processus utilisant les ports 8888, 8080, 8081, 8082...

rem Libération du port 8888 (Config Server)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8888 ^| findstr LISTENING') do (
    echo    ❌ Arrêt du processus %%a sur port 8888
    taskkill /F /PID %%a 2>nul
)

rem Libération du port 8080 (Gateway)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
    echo    ❌ Arrêt du processus %%a sur port 8080
    taskkill /F /PID %%a 2>nul
)

rem Libération du port 8081 (Energie)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8081 ^| findstr LISTENING') do (
    echo    ❌ Arrêt du processus %%a sur port 8081
    taskkill /F /PID %%a 2>nul
)

rem Libération du port 8082 (Eau)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8082 ^| findstr LISTENING') do (
    echo    ❌ Arrêt du processus %%a sur port 8082
    taskkill /F /PID %%a 2>nul
)

rem Libération du port 8761 (Eureka)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8761 ^| findstr LISTENING') do (
    echo    ❌ Arrêt du processus %%a sur port 8761
    taskkill /F /PID %%a 2>nul
)

timeout /t 5 /nobreak >nul

echo.
echo 🗑️ Étape 3/5: Suppression des conteneurs orphelins...
docker rm -f $(docker ps -aq) 2>nul
docker network prune -f 2>nul
docker volume prune -f 2>nul

echo.
echo 🔍 Étape 4/5: Vérification des ports...
netstat -ano | findstr ":8888 :8080 :8081 :8082 :8761" | findstr LISTENING
if %errorlevel% equ 0 (
    echo    ⚠️ Attention: Certains ports sont encore occupés!
    echo    Veuillez fermer manuellement les applications utilisant ces ports.
    pause
    exit /b 1
) else (
    echo    ✅ Tous les ports sont libres!
)

echo.
echo 🚀 Étape 5/5: Redémarrage du système...
echo    Construction des images...
docker-compose build --no-cache

echo.
echo    Lancement des conteneurs dans l'ordre correct...
docker-compose up -d postgres-energie postgres-eau zookeeper
timeout /t 15 /nobreak >nul

docker-compose up -d discovery-server
timeout /t 30 /nobreak >nul

docker-compose up -d config-server
timeout /t 20 /nobreak >nul

docker-compose up -d kafka
timeout /t 15 /nobreak >nul

docker-compose up -d gateway-service energie-service eau-service
timeout /t 25 /nobreak >nul

docker-compose up -d frontend

echo.
echo ⏳ Attente du démarrage complet (30 secondes)...
timeout /t 30 /nobreak >nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                  ✅ RÉPARATION TERMINÉE                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 📊 Statut des conteneurs:
docker-compose ps

echo.
echo 🔍 Vérification de l'état des services:
echo.
echo 🌐 URLs de test:
echo    Eureka:   http://localhost:8761
echo    Config:   http://localhost:8888/actuator/health
echo    Gateway:  http://localhost:8080/actuator/health
echo    Énergie:  http://localhost:8081/actuator/health
echo    Eau:      http://localhost:8082/actuator/health
echo    Frontend: http://localhost:4200
echo.

echo 📋 Commandes utiles:
echo    Voir les logs:    docker-compose logs -f [service-name]
echo    Redémarrer:       docker-compose restart [service-name]
echo    Statut détaillé:  docker-compose ps -a
echo.

pause