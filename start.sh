#!/bin/bash

echo "🚀 Démarrage du Système de Gestion d'Irrigation..."
echo "================================================"

# Étape 1: Builder les applications Spring Boot
echo "📦 Étape 1/4: Construction des services Spring Boot..."

cd discovery-server
mvn clean package -DskipTests
cd ..

cd config-server
mvn clean package -DskipTests
cd ..

cd gateway-service
mvn clean package -DskipTests
cd ..

cd energie-service
mvn clean package -DskipTests
cd ..

cd eau-service
mvn clean package -DskipTests
cd ..

# Étape 2: Builder le frontend Angular
echo "🔄 Étape 2/4: Construction du frontend Angular..."

cd irrigation-frontend
npm install
npm run build --prod
cd ..

# Étape 3: Démarrer Docker Compose
echo "🐳 Étape 3/4: Démarrage des conteneurs Docker..."

docker-compose up --build -d

# Étape 4: Attendre que les services soient prêts
echo "⏳ Étape 4/4: Attente du démarrage des services..."

echo "Attente 30 secondes pour que tous les services démarrent..."
sleep 30

# Vérifier l'état des services
echo "🔍 Vérification de l'état des services:"
docker-compose ps

echo ""
echo "✅ Système démarré avec succès!"
echo ""
echo "📊 URLs d'accès:"
echo "   Frontend:        http://localhost:4200"
echo "   Eureka:          http://localhost:8761"
echo "   API Gateway:     http://localhost:8080"
echo "   Config Server:   http://localhost:8888"
echo ""
echo "🔧 Services:"
echo "   Service Énergie: http://localhost:8081"
echo "   Service Eau:     http://localhost:8082"
echo "   PostgreSQL Énergie: localhost:5433"
echo "   PostgreSQL Eau:     localhost:5434"
echo ""
echo "📝 Commandes utiles:"
echo "   Voir les logs:    docker-compose logs -f"
echo "   Arrêter:          ./stop.sh"
echo "   Nettoyer:         ./clean.sh"