@echo off
chcp 65001 >nul
echo ============================================
echo 🔧 CORRECTION DE TOUS LES DOCKERFILES
echo ============================================
echo.

set SERVICES=discovery-server config-server gateway-service energie-service eau-service

for %%s in (%SERVICES%) do (
    if exist "%%s" (
        echo 📝 Création Dockerfile pour %%s...
        (
            echo # Dockerfile pour %%s
            echo FROM eclipse-temurin:17-jdk-alpine
            echo.
            echo WORKDIR /app
            echo.
            echo # Copier le JAR
            echo COPY target/*.jar app.jar
            echo.
            echo # Exposer le port
            echo EXPOSE 8080
            echo.
            echo # Profil Docker
            echo ENV SPRING_PROFILES_ACTIVE=docker
            echo.
            echo # Démarrer l'application
            echo ENTRYPOINT ["java", "-jar", "app.jar"]
        ) > "%%s\Dockerfile"
        echo    ✅ %%s\Dockerfile créé
    ) else (
        echo    ❌ Dossier %%s introuvable
    )
)

echo.
echo ============================================
echo ✅ TOUS LES DOCKERFILES SONT CRÉÉS !
echo ============================================
echo.
echo 🎯 Prochaine étape :
echo    1. Lancez: fix-gateway.bat
echo    2. Puis lancez: start.bat
echo.
pause