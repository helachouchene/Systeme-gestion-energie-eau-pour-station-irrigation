@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║         🔍 VÉRIFICATION DU SYSTÈME D'IRRIGATION             ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM ==================================================================
REM 1. STATUT DES CONTENEURS
REM ==================================================================
echo [1/6] 📦 Statut des conteneurs Docker...
echo ────────────────────────────────────────────────────────────────
docker-compose ps
echo.

REM ==================================================================
REM 2. HEALTH CHECK DES SERVICES
REM ==================================================================
echo [2/6] 💚 Health Check des services...
echo ────────────────────────────────────────────────────────────────

set all_healthy=1

REM PostgreSQL Energie
docker inspect postgres-energie 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL Energie: HEALTHY
) else (
    echo ❌ PostgreSQL Energie: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

REM PostgreSQL Eau
docker inspect postgres-eau 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL Eau: HEALTHY
) else (
    echo ❌ PostgreSQL Eau: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

REM Zookeeper
docker inspect zookeeper 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ Zookeeper: HEALTHY
) else (
    echo ❌ Zookeeper: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

REM Kafka
docker inspect kafka 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ Kafka: HEALTHY
) else (
    echo ⚠️ Kafka: UNHEALTHY ou en démarrage (peut être normal)
)

REM Discovery Server
docker inspect discovery-server 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ Discovery Server: HEALTHY
) else (
    echo ❌ Discovery Server: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

REM Config Server
docker inspect config-server 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ Config Server: HEALTHY
) else (
    echo ❌ Config Server: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

REM Gateway
docker inspect gateway-service 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ Gateway Service: HEALTHY
) else (
    echo ❌ Gateway Service: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

REM Energie Service
docker inspect energie-service 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ Energie Service: HEALTHY
) else (
    echo ❌ Energie Service: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

REM Eau Service
docker inspect eau-service 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ Eau Service: HEALTHY
) else (
    echo ❌ Eau Service: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

REM Frontend
docker inspect irrigation-frontend 2>nul | findstr "\"Status\": \"healthy\"" >nul
if %errorlevel% equ 0 (
    echo ✅ Frontend: HEALTHY
) else (
    echo ❌ Frontend: UNHEALTHY ou ARRÊTÉ
    set all_healthy=0
)

echo.

REM ==================================================================
REM 3. TEST DES ENDPOINTS
REM ==================================================================
echo [3/6] 🌐 Test des endpoints HTTP...
echo ────────────────────────────────────────────────────────────────

REM Eureka
curl -s -o nul -w "%%{http_code}" http://localhost:8761 > temp_status.txt 2>nul
set /p eureka_status=<temp_status.txt
if "%eureka_status%"=="200" (
    echo ✅ Eureka Dashboard: http://localhost:8761 [HTTP %eureka_status%]
) else (
    echo ❌ Eureka Dashboard: INACCESSIBLE [HTTP %eureka_status%]
    set all_healthy=0
)

REM Config Server
curl -s -o nul -w "%%{http_code}" http://localhost:8888/actuator/health > temp_status.txt 2>nul
set /p config_status=<temp_status.txt
if "%config_status%"=="200" (
    echo ✅ Config Server: http://localhost:8888 [HTTP %config_status%]
) else (
    echo ❌ Config Server: INACCESSIBLE [HTTP %config_status%]
    set all_healthy=0
)

REM Gateway
curl -s -o nul -w "%%{http_code}" http://localhost:8080/actuator/health > temp_status.txt 2>nul
set /p gateway_status=<temp_status.txt
if "%gateway_status%"=="200" (
    echo ✅ Gateway: http://localhost:8080 [HTTP %gateway_status%]
) else (
    echo ❌ Gateway: INACCESSIBLE [HTTP %gateway_status%]
    set all_healthy=0
)

REM Energie Service
curl -s -o nul -w "%%{http_code}" http://localhost:8081/actuator/health > temp_status.txt 2>nul
set /p energie_status=<temp_status.txt
if "%energie_status%"=="200" (
    echo ✅ Energie Service: http://localhost:8081 [HTTP %energie_status%]
) else (
    echo ❌ Energie Service: INACCESSIBLE [HTTP %energie_status%]
    set all_healthy=0
)

REM Eau Service
curl -s -o nul -w "%%{http_code}" http://localhost:8082/actuator/health > temp_status.txt 2>nul
set /p eau_status=<temp_status.txt
if "%eau_status%"=="200" (
    echo ✅ Eau Service: http://localhost:8082 [HTTP %eau_status%]
) else (
    echo ❌ Eau Service: INACCESSIBLE [HTTP %eau_status%]
    set all_healthy=0
)

REM Frontend
curl -s -o nul -w "%%{http_code}" http://localhost:4200 > temp_status.txt 2>nul
set /p frontend_status=<temp_status.txt
if "%frontend_status%"=="200" (
    echo ✅ Frontend: http://localhost:4200 [HTTP %frontend_status%]
) else (
    echo ❌ Frontend: INACCESSIBLE [HTTP %frontend_status%]
    set all_healthy=0
)

del temp_status.txt 2>nul
echo.

REM ==================================================================
REM 4. ENREGISTREMENT EUREKA
REM ==================================================================
echo [4/6] 📋 Services enregistrés dans Eureka...
echo ────────────────────────────────────────────────────────────────

curl -s http://localhost:8761/eureka/apps > eureka_apps.xml 2>nul
if %errorlevel% equ 0 (
    findstr /C:"<name>CONFIG-SERVER</name>" eureka_apps.xml >nul
    if %errorlevel% equ 0 (
        echo ✅ CONFIG-SERVER enregistré
    ) else (
        echo ❌ CONFIG-SERVER non enregistré
    )
    
    findstr /C:"<name>GATEWAY-SERVICE</name>" eureka_apps.xml >nul
    if %errorlevel% equ 0 (
        echo ✅ GATEWAY-SERVICE enregistré
    ) else (
        echo ❌ GATEWAY-SERVICE non enregistré
    )
    
    findstr /C:"<name>ENERGIE-SERVICE</name>" eureka_apps.xml >nul
    if %errorlevel% equ 0 (
        echo ✅ ENERGIE-SERVICE enregistré
    ) else (
        echo ❌ ENERGIE-SERVICE non enregistré
    )
    
    findstr /C:"<name>EAU-SERVICE</name>" eureka_apps.xml >nul
    if %errorlevel% equ 0 (
        echo ✅ EAU-SERVICE enregistré
    ) else (
        echo ❌ EAU-SERVICE non enregistré
    )
    
    del eureka_apps.xml
) else (
    echo ❌ Impossible de contacter Eureka
)

echo.

REM ==================================================================
REM 5. RESSOURCES SYSTÈME
REM ==================================================================
echo [5/6] 💻 Utilisation des ressources...
echo ────────────────────────────────────────────────────────────────
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
echo.

REM ==================================================================
REM 6. PORTS UTILISÉS
REM ==================================================================
echo [6/6] 🔌 Ports utilisés...
echo ────────────────────────────────────────────────────────────────
netstat -ano | findstr ":4200 :8080 :8081 :8082 :8761 :8888 :5433 :5434 :9092 :2181" | findstr "LISTENING"
echo.

REM ==================================================================
REM RÉSUMÉ
REM ==================================================================
echo ╔══════════════════════════════════════════════════════════════╗
if %all_healthy% equ 1 (
    echo ║              ✅ SYSTÈME ENTIÈREMENT OPÉRATIONNEL            ║
) else (
    echo ║           ⚠️ SYSTÈME PARTIELLEMENT OPÉRATIONNEL            ║
)
echo ╚══════════════════════════════════════════════════════════════╝
echo.

if %all_healthy% neq 1 (
    echo 🔧 Actions recommandées:
    echo    1. Vérifier les logs: docker-compose logs -f [service-name]
    echo    2. Redémarrer les services: docker-compose restart [service-name]
    echo    3. Voir le guide de dépannage: TROUBLESHOOTING.md
    echo    4. Exécuter fix-docker.bat pour une réparation complète
    echo.
)

echo 📋 Commandes utiles:
echo    Logs en temps réel:  docker-compose logs -f
echo    Redémarrer:          docker-compose restart
echo    Rebuild:             docker-compose build --no-cache
echo    Tout arrêter:        docker-compose down
echo.

pause