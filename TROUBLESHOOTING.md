# 🔧 Guide de Dépannage Docker

## 🚨 Problèmes Courants et Solutions

### 1️⃣ **Erreur: Port déjà utilisé**
```
Error: Ports are not available: bind: Only one usage of each socket address
```

**Solution:**
```bash
# Exécuter le script de réparation
fix-docker.bat
```

**Ou manuellement:**
```bash
# 1. Arrêter Docker Compose
docker-compose down -v

# 2. Identifier le processus utilisant le port
netstat -ano | findstr :8888

# 3. Tuer le processus (remplacer PID par le numéro affiché)
taskkill /F /PID <PID>

# 4. Redémarrer
docker-compose up -d
```

---

### 2️⃣ **Service "unhealthy"**
```
STATUS: Up X minutes (unhealthy)
```

**Diagnostic:**
```bash
# Voir les logs du service problématique
docker logs discovery-server --tail 100

# Vérifier le healthcheck
docker inspect discovery-server | findstr -A 10 "Health"
```

**Solutions possibles:**

#### A) Augmenter le temps de démarrage
Modifier `docker-compose.yml`:
```yaml
healthcheck:
  start_period: 90s  # Au lieu de 60s
  interval: 30s
  retries: 5
```

#### B) Vérifier l'endpoint de healthcheck
```bash
# Depuis l'intérieur du conteneur
docker exec discovery-server curl -f http://localhost:8761/actuator/health
```

#### C) Désactiver temporairement le healthcheck
```yaml
healthcheck:
  disable: true  # Pour debug seulement
```

---

### 3️⃣ **Service ne démarre pas**

**Diagnostic:**
```bash
# Voir les logs détaillés
docker-compose logs -f [service-name]

# Vérifier l'état
docker-compose ps -a

# Vérifier les dépendances
docker-compose config
```

**Solutions:**

#### A) Problème de connexion à Eureka
```yaml
# Vérifier dans application-docker.yml
eureka:
  client:
    service-url:
      defaultZone: http://discovery-server:8761/eureka/
```

#### B) Problème de connexion BDD
```bash
# Vérifier que PostgreSQL est healthy
docker-compose ps postgres-energie postgres-eau

# Tester la connexion
docker exec postgres-energie psql -U energie_user -d energiedb -c "SELECT 1"
```

#### C) Problème avec Kafka
```bash
# Vérifier Kafka et Zookeeper
docker-compose logs kafka zookeeper

# Recréer Kafka
docker-compose rm -f kafka
docker-compose up -d kafka
```

---

### 4️⃣ **Frontend ne se connecte pas au backend**

**Solution:**
Vérifier `nginx.conf`:
```nginx
location /api/ {
    proxy_pass http://gateway-service:8080/;
    # ... reste de la config
}
```

**Tester depuis le conteneur:**
```bash
docker exec irrigation-frontend curl http://gateway-service:8080/actuator/health
```

---

### 5️⃣ **Images Docker corrompues**

**Solution - Rebuild complet:**
```bash
# 1. Tout arrêter
docker-compose down -v

# 2. Supprimer les images
docker-compose rm -f
docker rmi $(docker images -q 'systeme-gestion*')

# 3. Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d
```

---

## 📋 Commandes de Diagnostic Essentielles

### Voir l'état complet
```bash
docker-compose ps -a
docker stats --no-stream
```

### Logs en temps réel
```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f discovery-server

# Dernières 50 lignes
docker logs discovery-server --tail 50
```

### Vérifier la santé
```bash
# Santé d'un service
docker inspect discovery-server | findstr -A 10 "Health"

# Tester manuellement
docker exec discovery-server curl http://localhost:8761/actuator/health
```

### Réseau Docker
```bash
# Lister les réseaux
docker network ls

# Inspecter le réseau
docker network inspect irrigation-network

# Tester la connectivité entre conteneurs
docker exec eau-service ping discovery-server
```

### Bases de données
```bash
# Se connecter à PostgreSQL Energie
docker exec -it postgres-energie psql -U energie_user -d energiedb

# Se connecter à PostgreSQL Eau
docker exec -it postgres-eau psql -U eau_user -d eaudb

# Lister les tables
\dt

# Quitter
\q
```

---

## 🔄 Procédure de Redémarrage Propre

### Ordre recommandé:
```bash
# 1. Infrastructure de base
docker-compose up -d postgres-energie postgres-eau zookeeper
timeout /t 15

# 2. Eureka (doit démarrer en premier)
docker-compose up -d discovery-server
timeout /t 30

# 3. Config Server
docker-compose up -d config-server
timeout /t 20

# 4. Kafka
docker-compose up -d kafka
timeout /t 15

# 5. Gateway + Services métiers
docker-compose up -d gateway-service energie-service eau-service
timeout /t 25

# 6. Frontend
docker-compose up -d frontend
```

---

## 🧹 Nettoyage Complet (Si tout échoue)

```bash
# ATTENTION: Supprime TOUT (volumes, données, etc.)

# 1. Arrêter tout
docker-compose down -v

# 2. Supprimer tous les conteneurs
docker rm -f $(docker ps -aq)

# 3. Supprimer toutes les images du projet
docker rmi -f $(docker images -q 'systeme-gestion*')

# 4. Supprimer tous les volumes
docker volume rm $(docker volume ls -q | findstr postgres)

# 5. Nettoyer le système Docker
docker system prune -a --volumes -f

# 6. Rebuild et restart
docker-compose build --no-cache
docker-compose up -d
```

---

## 📊 Vérification Post-Démarrage

### URLs à tester:
```
✅ Eureka:   http://localhost:8761
✅ Config:   http://localhost:8888/actuator/health
✅ Gateway:  http://localhost:8080/actuator/health
✅ Énergie:  http://localhost:8081/actuator/health
✅ Eau:      http://localhost:8082/actuator/health
✅ Frontend: http://localhost:4200
```

### Vérifier l'enregistrement Eureka:
```
http://localhost:8761
```
Doit montrer: CONFIG-SERVER, GATEWAY-SERVICE, ENERGIE-SERVICE, EAU-SERVICE

### Tester les APIs:
```bash
# Pompes
curl http://localhost:8080/api/pompes

# Réservoirs
curl http://localhost:8080/api/reservoirs

# Via Gateway
curl http://localhost:8081/api/pompes
curl http://localhost:8082/api/reservoirs
```

---

## 🆘 Support Supplémentaire

Si aucune solution ne fonctionne:
1. Sauvegarder les logs: `docker-compose logs > logs.txt`
2. Capturer docker-compose ps: `docker-compose ps > status.txt`
3. Vérifier les configurations
4. Chercher l'erreur spécifique dans les logs