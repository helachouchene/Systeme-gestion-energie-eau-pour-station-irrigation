@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║   🚀 DÉMARRAGE SYSTÈME IRRIGATION - MODE OPTIMISÉ           ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Fonction pour vérifier si un service est healthy
:check_health
set service=%1
set max_wait=%2
set counter=0

echo ⏳ Attente du service %service%...
:wait_loop
docker inspect %service% 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo    ✅ %service% est prêt!
    exit /b 0
)

set /a counter+=1
if !counter! gtr %max_wait% (
    echo    ❌ TIMEOUT: %service% n'est pas healthy après %max_wait% secondes
    echo    📋 Logs du service:
    docker logs %service% --tail 20
    exit /b 1
)

timeout /t 1 /nobreak >nul
goto wait_loop

REM ==================================================================
REM ÉTAPE 0: VÉRIFICATION PRÉALABLE
REM ==================================================================
echo 🔍 Vérification de l'environnement...

docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker n'est pas installé ou n'est pas démarré!
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose n'est pas installé!
    pause
    exit /b 1
)

echo ✅ Docker et Docker Compose sont disponibles

REM ==================================================================
REM ÉTAPE 1: NETTOYAGE ET ARRÊT
REM ==================================================================
echo.
echo 🧹 Nettoyage des conteneurs existants...
docker-compose down 2>nul

REM Vérifier si des ports sont bloqués
echo.
echo 🔍 Vérification des ports...
set ports_busy=0

netstat -ano | findstr ":8888" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo    ⚠️ Port 8888 occupé
    set ports_busy=1
)

netstat -ano | findstr ":8080" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo    ⚠️ Port 8080 occupé
    set ports_busy=1
)

netstat -ano | findstr ":8761" | findstr "LISTENING" >nul
if %errorlevel% equ 0 (
    echo    ⚠️ Port 8761 occupé
    set ports_busy=1
)

if %ports_busy% equ 1 (
    echo.
    echo ❌ Des ports sont occupés! Voulez-vous les libérer automatiquement?
    echo    [O]ui / [N]on / [A]nnuler
    choice /c ONA /n
    if !errorlevel! equ 1 (
        echo    Exécution de fix-docker.bat...
        call fix-docker.bat
        if !errorlevel! neq 0 exit /b 1
    )
    if !errorlevel! equ 3 exit /b 0
)

REM ==================================================================
REM ÉTAPE 2: BUILD DES IMAGES
REM ==================================================================
echo.
echo 🔨 Construction des images Docker...
docker-compose build
if %errorlevel% neq 0 (
    echo ❌ Erreur lors du build!
    pause
    exit /b 1
)

REM ==================================================================
REM ÉTAPE 3: DÉMARRAGE SÉQUENTIEL
REM ==================================================================
echo.
echo 📦 Démarrage des services dans l'ordre...

REM 3.1 - Bases de données
echo.
echo [1/6] 💾 Démarrage des bases de données PostgreSQL...
docker-compose up -d postgres-energie postgres-eau

echo    Attente de la disponibilité...
timeout /t 15 /nobreak >nul

docker inspect postgres-energie | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% neq 0 (
    echo    ❌ PostgreSQL Energie ne démarre pas correctement
    docker logs postgres-energie --tail 20
    pause
    exit /b 1
)
echo    ✅ PostgreSQL Energie OK

docker inspect postgres-eau | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% neq 0 (
    echo    ❌ PostgreSQL Eau ne démarre pas correctement
    docker logs postgres-eau --tail 20
    pause
    exit /b 1
)
echo    ✅ PostgreSQL Eau OK

REM 3.2 - Zookeeper
echo.
echo [2/6] 🐘 Démarrage de Zookeeper...
docker-compose up -d zookeeper
timeout /t 15 /nobreak >nul

docker inspect zookeeper | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% neq 0 (
    echo    ❌ Zookeeper ne démarre pas correctement
    docker logs zookeeper --tail 20
    pause
    exit /b 1
)
echo    ✅ Zookeeper OK

REM 3.3 - Discovery Server (Eureka)
echo.
echo [3/6] 🔍 Démarrage de Eureka Discovery Server...
docker-compose up -d discovery-server

echo    Attente du démarrage (cela peut prendre 40-60 secondes)...
set counter=0
:eureka_wait
docker inspect discovery-server 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo    ✅ Eureka Server OK
    goto eureka_ok
)

set /a counter+=1
if %counter% gtr 60 (
    echo    ⚠️ Eureka met plus de temps que prévu...
    docker logs discovery-server --tail 30
)
if %counter% gtr 90 (
    echo    ❌ TIMEOUT: Eureka ne démarre pas
    pause
    exit /b 1
)

timeout /t 1 /nobreak >nul
goto eureka_wait

:eureka_ok

REM 3.4 - Config Server
echo.
echo [4/6] ⚙️ Démarrage du Config Server...
docker-compose up -d config-server
timeout /t 25 /nobreak >nul

docker ps | findstr "config-server" | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo    ❌ Config Server ne démarre pas
    docker logs config-server --tail 30
    pause
    exit /b 1
)
echo    ✅ Config Server OK

REM 3.5 - Kafka
echo.
echo [5/6] 📨 Démarrage de Kafka...
docker-compose up -d kafka
timeout /t 20 /nobreak >nul

docker inspect kafka | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% neq 0 (
    echo    ⚠️ Kafka en cours de démarrage (normal)...
)
echo    ✅ Kafka lancé

REM 3.6 - Gateway et Services Métiers
echo.
echo [6/6] 🌐 Démarrage du Gateway et des Services Métiers...
docker-compose up -d gateway-service energie-service eau-service
timeout /t 30 /nobreak >nul

echo    ✅ Services métiers lancés

REM 3.7 - Frontend
echo.
echo [7/7] 🎨 Démarrage du Frontend...
docker-compose up -d frontend
timeout /t 10 /nobreak >nul

echo    ✅ Frontend lancé

REM ==================================================================
REM ÉTAPE 4: VÉRIFICATION FINALE
REM ==================================================================
echo.
echo 🔍 Vérification finale de tous les services...
timeout /t 15 /nobreak >nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                   📊 STATUT DES SERVICES                     ║
echo ╚══════════════════════════════════════════════════════════════╝
docker-compose ps

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                  ✅ DÉMARRAGE TERMINÉ!                       ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🌐 URLs d'accès:
echo.
echo    📊 Frontend:         http://localhost:4200
echo    🔍 Eureka Dashboard: http://localhost:8761
echo    🚪 API Gateway:      http://localhost:8080
echo    ⚙️ Config Server:    http://localhost:8888
echo.
echo 🔧 Services Backend:
echo    ⚡ Énergie:           http://localhost:8081
echo    💧 Eau:              http://localhost:8082
echo.
echo 🗄️ Bases de données:
echo    PostgreSQL Énergie:  localhost:5433
echo    PostgreSQL Eau:      localhost:5434
echo.
echo 📋 Commandes utiles:
echo    Logs:       docker-compose logs -f [service-name]
echo    Statut:     docker-compose ps
echo    Arrêt:      docker-compose down
echo    Rebuild:    docker-compose build --no-cache
echo.

REM Ouvrir automatiquement Eureka dans le navigateur
echo 🌐 Ouverture du dashboard Eureka...
timeout /t 2 /nobreak >nul
start http://localhost:8761

echo.
echo 💡 Astuce: Attendez 1-2 minutes que tous les services s'enregistrent dans Eureka
echo.
pause