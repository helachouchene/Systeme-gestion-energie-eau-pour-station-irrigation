@echo off
chcp 65001 >nul
echo ============================================
echo 🔧 CORRECTION PORT DISCOVERY SERVER
echo ============================================
echo.

cd discovery-server
if errorlevel 1 (
    echo ❌ Exécutez depuis la racine du projet
    pause
    exit /b 1
)

echo 📝 Création du fichier application.properties...
(
echo spring.application.name=discovery-server
echo server.port=8761
echo.
echo eureka.client.register-with-eureka=false
echo eureka.client.fetch-registry=false
echo eureka.client.service-url.defaultZone=http://localhost:8761/eureka/
echo.
echo management.endpoints.web.exposure.include=health,info
) > src\main\resources\application.properties

echo ✅ Fichier créé avec server.port=8761
echo.
echo 🔨 Recompilation...
call mvn clean package -DskipTests

if errorlevel 1 (
    echo ❌ Compilation échouée
    pause
    exit /b 1
)

echo.
echo ============================================
echo ✅ DISCOVERY SERVER CORRIGÉ !
echo ============================================
echo 📦 Port configuré: 8761
echo.
cd ..

echo 🐳 Redémarrage Docker...
docker-compose down
docker-compose up -d

echo.
echo ⏳ Attente 60 secondes...
timeout /t 60 /nobreak

echo.
echo ============================================
echo ✅ SYSTÈME REDÉMARRÉ !
echo ============================================
echo.
echo 🌐 Testez maintenant:
echo    Eureka:  http://localhost:8761
echo    Gateway: http://localhost:8080
echo    Frontend: http://localhost:4200
echo.
pause