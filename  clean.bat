@echo off
echo 🧹 Nettoyage complet...
docker-compose down -v
docker system prune -f
echo ✅ Nettoyage terminé.