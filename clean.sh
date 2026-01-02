#!/bin/bash

echo "🧹 Nettoyage complet du système..."
echo "=================================="

# Arrêter et supprimer les conteneurs
docker-compose down -v

# Supprimer les images Docker
docker rmi $(docker images "irrigation-*" -q) 2>/dev/null || true
docker rmi irrigation-frontend 2>/dev/null || true

# Nettoyer Docker
docker system prune -f

echo "✅ Nettoyage terminé!"
echo ""
echo "⚠️  Toutes les données ont été supprimées!"