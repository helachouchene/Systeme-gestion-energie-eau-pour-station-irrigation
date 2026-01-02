@echo off
chcp 65001 >nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║   🚀 DÉMARRAGE SYSTÈME IRRIGATION                            ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM ==================================================================
REM ÉTAPE 1: ARRÊT PROPRE
REM ==================================================================
echo 🛑 Arrêt des conteneurs existants...
docker-compose down 2>nul
timeout /t 3 /nobreak >nul

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
echo 📦 Démarrage des services...

echo [1/6] 💾 Bases de données PostgreSQL...
docker-compose up -d postgres-energie postgres-eau
timeout /t 15 /nobreak >nul

echo [2/6] 🐘 Zookeeper...
docker-compose up -d zookeeper
timeout /t 10 /nobreak >nul

echo [3/6] 🔍 Discovery Server (Eureka)...
docker-compose up -d discovery-server
timeout /t 40 /nobreak >nul

echo [4/6] ⚙️ Config Server...
docker-compose up -d config-server
timeout /t 20 /nobreak >nul

echo [5/6] 📨 Kafka...
docker-compose up -d kafka
timeout /t 15 /nobreak >nul

echo [6/6] 🌐 Services applicatifs...
docker-compose up -d gateway-service energie-service eau-service frontend
timeout /t 30 /nobreak >nul

REM ==================================================================
REM ÉTAPE 4: VÉRIFICATION
REM ==================================================================
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                  📊 STATUT DES SERVICES                      ║
echo ╚══════════════════════════════════════════════════════════════╝
docker-compose ps

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                  ✅ DÉMARRAGE TERMINÉ                        ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🌐 URLs d'accès:
echo    📊 Frontend:         http://localhost:4200
echo    🔍 Eureka:           http://localhost:8761
echo    🚪 Gateway:          http://localhost:8080
echo    ⚙️  Config:           http://localhost:8888
echo    ⚡ Énergie:          http://localhost:8081
echo    💧 Eau:              http://localhost:8082
echo.
echo 💡 Attendez 1-2 minutes que tous les services s'enregistrent
echo.

REM Ouvrir Eureka
timeout /t 2 /nobreak >nul
start http://localhost:8761

pause