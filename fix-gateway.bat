@echo off
chcp 65001 >nul
echo ============================================
echo 🔧 CORRECTION GATEWAY SERVICE - UTF-8
echo ============================================
echo.

cd gateway-service
if errorlevel 1 (
    echo ❌ Vous devez être à la racine du projet
    echo    Exemple: C:\Users\LENOVO\Desktop\Systeme-gestion-energie-eau-pour-station-irrigation
    pause
    exit /b 1
)

echo 📁 Suppression de l'ancien fichier...
del /f /q "src\main\resources\application.properties" 2>nul

echo 📝 Création du nouveau fichier en UTF-8...
(
echo spring.application.name=gateway-service
echo server.port=8080
echo.
echo eureka.client.service-url.defaultZone=http://localhost:8761/eureka/
echo eureka.client.register-with-eureka=true
echo eureka.client.fetch-registry=true
echo.
echo spring.cloud.gateway.discovery.locator.enabled=true
echo spring.cloud.gateway.discovery.locator.lower-case-service-id=true
echo.
echo management.endpoints.web.exposure.include=health,info,gateway
echo management.endpoint.health.show-details=always
) > src\main\resources\application.properties

if errorlevel 1 (
    echo ❌ Erreur PowerShell
    pause
    exit /b 1
)

echo ✅ Fichier créé avec succès
echo.
echo 🔨 Compilation Maven...
call mvn clean package -DskipTests

if errorlevel 1 (
    echo ❌ Compilation échouée
    pause
    exit /b 1
)

echo.
echo ============================================
echo ✅ GATEWAY SERVICE CORRIGÉ !
echo ============================================
echo 📦 JAR: target\gateway-service-0.0.1-SNAPSHOT.jar
echo.
cd ..
pause