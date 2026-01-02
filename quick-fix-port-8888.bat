@echo off
chcp 65001 >nul
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║     🔧 FIX RAPIDE - PROBLÈME PORT 8888                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

echo 🔍 Recherche du processus utilisant le port 8888...
echo.

netstat -ano | findstr :8888 | findstr LISTENING > port_check.txt

if %errorlevel% equ 0 (
    echo ⚠️ Port 8888 est utilisé par:
    type port_check.txt
    echo.
    
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8888 ^| findstr LISTENING') do (
        set PID=%%a
        goto :found_pid
    )
    
    :found_pid
    echo 🔍 Informations sur le processus !PID!:
    tasklist /FI "PID eq !PID!" /FO TABLE
    echo.
    
    echo ❓ Voulez-vous arrêter ce processus?
    echo    [O]ui - Arrêter le processus
    echo    [N]on - Annuler
    choice /c ON /n
    
    if !errorlevel! equ 1 (
        echo.
        echo 🛑 Arrêt du processus !PID!...
        taskkill /F /PID !PID!
        
        if !errorlevel! equ 0 (
            echo ✅ Processus arrêté avec succès!
            timeout /t 3 /nobreak >nul
            
            echo.
            echo 🔄 Redémarrage du système Docker...
            docker-compose down
            timeout /t 5 /nobreak >nul
            
            echo.
            echo 🚀 Démarrage séquentiel...
            
            echo [1/3] Bases de données + Zookeeper...
            docker-compose up -d postgres-energie postgres-eau zookeeper
            timeout /t 15 /nobreak >nul
            
            echo [2/3] Discovery Server...
            docker-compose up -d discovery-server
            timeout /t 40 /nobreak >nul
            
            echo [3/3] Tous les autres services...
            docker-compose up -d
            timeout /t 30 /nobreak >nul
            
            echo.
            echo ✅ Système redémarré!
            echo.
            echo 📊 Statut:
            docker-compose ps
            
            echo.
            echo 🌐 Test du port 8888:
            timeout /t 5 /nobreak >nul
            curl -s http://localhost:8888/actuator/health
            echo.
            
        ) else (
            echo ❌ Erreur lors de l'arrêt du processus
            echo 💡 Essayez de fermer l'application manuellement
        )
    ) else (
        echo ℹ️ Opération annulée
    )
) else (
    echo ✅ Port 8888 est LIBRE!
    echo.
    echo 🔍 Vérification de l'état du Config Server...
    docker ps | findstr config-server
    
    if !errorlevel! neq 0 (
        echo.
        echo ⚠️ Le Config Server n'est pas démarré
        echo 🚀 Démarrage du Config Server...
        docker-compose up -d config-server
        
        echo ⏳ Attente (20 secondes)...
        timeout /t 20 /nobreak >nul
        
        echo.
        echo 📊 Statut:
        docker-compose ps config-server
        
        echo.
        echo 🌐 Test:
        curl -s http://localhost:8888/actuator/health
        echo.
    ) else (
        echo ✅ Config Server est déjà en cours d'exécution
    )
)

del port_check.txt 2>nul

echo.
echo ════════════════════════════════════════════════════════════════
echo 💡 VÉRIFICATIONS SUPPLÉMENTAIRES
echo ════════════════════════════════════════════════════════════════
echo.
echo 1️⃣ Vérifier tous les services:
echo    check-status.bat
echo.
echo 2️⃣ Voir les logs du Config Server:
echo    docker logs config-server --tail 50
echo.
echo 3️⃣ Si le problème persiste:
echo    fix-docker.bat
echo.

pause