@echo off
chcp 65001 >nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║      📁 CRÉATION STRUCTURE KUBERNETES                       ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM Créer les dossiers principaux
echo [1/4] Création des dossiers...
mkdir k8s 2>nul
mkdir k8s\namespaces 2>nul
mkdir k8s\configmaps 2>nul
mkdir k8s\secrets 2>nul
mkdir k8s\deployments 2>nul
mkdir k8s\services 2>nul
mkdir k8s\ingress 2>nul
mkdir k8s\hpa 2>nul
mkdir k8s\persistent-volumes 2>nul
mkdir scripts 2>nul

REM Créer les fichiers namespaces
echo [2/4] Création des fichiers namespaces...
type nul > k8s\namespaces\irrigation-namespace.yaml

REM Créer les fichiers configmaps
echo [3/4] Création des fichiers configmaps et secrets...
type nul > k8s\configmaps\eureka-config.yaml
type nul > k8s\configmaps\postgres-config.yaml
type nul > k8s\secrets\postgres-secrets.yaml

REM Créer les fichiers deployments
echo [4/4] Création des fichiers deployments, services, etc...
type nul > k8s\deployments\discovery-server-deployment.yaml
type nul > k8s\deployments\config-server-deployment.yaml
type nul > k8s\deployments\gateway-deployment.yaml
type nul > k8s\deployments\energie-deployment.yaml
type nul > k8s\deployments\eau-deployment.yaml
type nul > k8s\deployments\postgres-energie-deployment.yaml
type nul > k8s\deployments\postgres-eau-deployment.yaml
type nul > k8s\deployments\kafka-deployment.yaml
type nul > k8s\deployments\zookeeper-deployment.yaml
type nul > k8s\deployments\frontend-deployment.yaml

REM Créer les fichiers services
type nul > k8s\services\discovery-server-service.yaml
type nul > k8s\services\config-server-service.yaml
type nul > k8s\services\gateway-service.yaml
type nul > k8s\services\energie-service.yaml
type nul > k8s\services\eau-service.yaml
type nul > k8s\services\postgres-energie-service.yaml
type nul > k8s\services\postgres-eau-service.yaml
type nul > k8s\services\kafka-service.yaml
type nul > k8s\services\zookeeper-service.yaml
type nul > k8s\services\frontend-service.yaml

REM Créer les fichiers ingress
type nul > k8s\ingress\ingress.yaml

REM Créer les fichiers HPA
type nul > k8s\hpa\energie-hpa.yaml
type nul > k8s\hpa\eau-hpa.yaml
type nul > k8s\hpa\gateway-hpa.yaml

REM Créer les fichiers persistent volumes
type nul > k8s\persistent-volumes\postgres-energie-pv.yaml
type nul > k8s\persistent-volumes\postgres-energie-pvc.yaml
type nul > k8s\persistent-volumes\postgres-eau-pv.yaml
type nul > k8s\persistent-volumes\postgres-eau-pvc.yaml

REM Créer les scripts
type nul > scripts\k8s-deploy.bat
type nul > scripts\k8s-delete.bat
type nul > scripts\k8s-status.bat

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║              ✅ STRUCTURE CRÉÉE AVEC SUCCÈS !                ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 📁 Structure créée:
echo    k8s\
echo    ├── namespaces\         (1 fichier)
echo    ├── configmaps\         (2 fichiers)
echo    ├── secrets\            (1 fichier)
echo    ├── deployments\        (10 fichiers)
echo    ├── services\           (10 fichiers)
echo    ├── ingress\            (1 fichier)
echo    ├── hpa\                (3 fichiers)
echo    └── persistent-volumes\ (4 fichiers)
echo.
echo    scripts\
echo    ├── k8s-deploy.bat
echo    ├── k8s-delete.bat
echo    └── k8s-status.bat
echo.
echo 📝 Prochaine étape: Remplir les fichiers YAML
echo.

REM Afficher l'arborescence
tree /F k8s 2>nul
tree /F scripts 2>nul

pause