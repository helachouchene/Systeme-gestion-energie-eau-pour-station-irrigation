# 🐳 Guide de Déploiement Docker Complet

## 📋 Table des Matières
- [Prérequis](#prérequis)
- [Architecture](#architecture)
- [Installation Rapide](#installation-rapide)
- [Scripts Disponibles](#scripts-disponibles)
- [Configuration](#configuration)
- [Dépannage](#dépannage)
- [Migration H2 → PostgreSQL](#migration-h2--postgresql)

---

## 🎯 Prérequis

### Logiciels Requis
- **Docker Desktop** 4.0+ ([Télécharger](https://www.docker.com/products/docker-desktop))
- **Docker Compose** 2.0+ (inclus avec Docker Desktop)
- **Git** pour cloner le projet
- **Minimum 8GB RAM** pour Docker
- **20GB d'espace disque** libre

### Vérification
```bash
docker --version
# Docker version 24.0.0 ou supérieur

docker-compose --version
# Docker Compose version 2.0.0 ou supérieur
```

---

## 🏗️ Architecture

### Services Déployés

| Service | Port | Technologie | Dépendances |
|---------|------|-------------|-------------|
| **discovery-server** | 8761 | Eureka | - |
| **config-server** | 8888 | Spring Cloud Config | discovery-server |
| **gateway-service** | 8080 | Spring Cloud Gateway | discovery-server, config-server |
| **energie-service** | 8081 | Spring Boot | postgres-energie, kafka, discovery-server |
| **eau-service** | 8082 | Spring Boot | postgres-eau, kafka, discovery-server |
| **frontend** | 4200 (→80) | Angular + Nginx | gateway-service |
| **postgres-energie** | 5433 | PostgreSQL 15 | - |
| **postgres-eau** | 5434 | PostgreSQL 15 | - |
| **zookeeper** | 2181 | Apache Zookeeper | - |
| **kafka** | 9092 | Apache Kafka | zookeeper |

### Schéma de Communication
```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND (4200)                      │
│                   Angular + Nginx                       │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│               GATEWAY SERVICE (8080)                    │
│            Spring Cloud Gateway                         │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┴──────────────┐
        ▼                              ▼
┌──────────────────┐          ┌──────────────────┐
│ ENERGIE SERVICE  │ ◄──────► │  EAU SERVICE     │
│     (8081)       │  Feign   │    (8082)        │
└────────┬─────────┘          └─────────┬────────┘
         │                               │
         ▼                               ▼
┌──────────────────┐          ┌──────────────────┐
│ PostgreSQL       │          │ PostgreSQL       │
│ Energie (5433)   │          │ Eau (5434)       │
└──────────────────┘          └──────────────────┘
         │                               │
         └───────────┬───────────────────┘
                     ▼
            ┌────────────────┐
            │  KAFKA (9092)  │
            │ + Zookeeper    │
            └────────────────┘
                     ▲
                     │
            ┌────────────────┐
            │ EUREKA (8761)  │
            │ Service        │
            │ Discovery      │
            └────────────────┘
```

---

## 🚀 Installation Rapide

### Méthode 1 : Script Automatique (Recommandé)

```bash
# 1. Cloner le projet
git clone <votre-repo>
cd Systeme-gestion-energie-eau-pour-station-irrigation

# 2. Build de tous les services Java
mvn clean package -DskipTests

# 3. Lancer le script de démarrage optimisé
start-improved.bat
```

### Méthode 2 : Commandes Manuelles

```bash
# 1. Build des images
docker-compose build --no-cache

# 2. Démarrage séquentiel
docker-compose up -d postgres-energie postgres-eau zookeeper
timeout /t 15

docker-compose up -d discovery-server
timeout /t 40

docker-compose up -d config-server
timeout /t 20

docker-compose up -d kafka
timeout /t 15

docker-compose up -d gateway-service energie-service eau-service
timeout /t 30

docker-compose up -d frontend
```

### Vérification du Démarrage

Après 2-3 minutes, vérifier :
```bash
# Statut des conteneurs
docker-compose ps

# Tous doivent être "Up (healthy)"
check-status.bat
```

---

## 📜 Scripts Disponibles

### `start-improved.bat` ⭐
**Démarrage optimisé avec vérifications**
- Vérifie l'environnement
- Démarre les services dans le bon ordre
- Attend que chaque service soit ready
- Ouvre automatiquement le dashboard Eureka

```bash
start-improved.bat
```

### `fix-docker.bat` 🔧
**Réparation complète du système**
- Libère les ports bloqués
- Nettoie les conteneurs orphelins
- Rebuild complet
- Redémarrage propre

```bash
fix-docker.bat
```

### `check-status.bat` 🔍
**Vérification complète du système**
- Health check de tous les services
- Test des endpoints HTTP
- Enregistrement Eureka
- Utilisation des ressources
- Ports utilisés

```bash
check-status.bat
```

### `stop.bat` 🛑
**Arrêt propre du système**
```bash
stop.bat
```

### `clean.bat` 🧹
**Nettoyage complet**
- Supprime tous les conteneurs
- Supprime tous les volumes
- Supprime toutes les images du projet
```bash
clean.bat
```

---

## ⚙️ Configuration

### Variables d'Environnement

Créer un fichier `.env` à la racine (optionnel) :
```env
# Bases de données
POSTGRES_ENERGIE_DB=energiedb
POSTGRES_ENERGIE_USER=energie_user
POSTGRES_ENERGIE_PASSWORD=energie_pass

POSTGRES_EAU_DB=eaudb
POSTGRES_EAU_USER=eau_user
POSTGRES_EAU_PASSWORD=eau_pass

# Kafka
KAFKA_BOOTSTRAP_SERVERS=kafka:29092

# Eureka
EUREKA_SERVER_URL=http://discovery-server:8761/eureka/
```

### Personnalisation des Ports

Modifier `docker-compose.yml` :
```yaml
services:
  energie-service:
    ports:
      - "8081:8081"  # Changer le premier port (hôte)
```

### Configuration PostgreSQL

Connexion aux bases de données :
```bash
# Energie
docker exec -it postgres-energie psql -U energie_user -d energiedb

# Eau
docker exec -it postgres-eau psql -U eau_user -d eaudb
```

Commandes SQL utiles :
```sql
-- Lister les tables
\dt

-- Voir la structure d'une table
\d pompe

-- Compter les enregistrements
SELECT COUNT(*) FROM pompe;

-- Quitter
\q
```

---

## 🔧 Dépannage

### Problème 1 : Port 8888 occupé

**Erreur:**
```
Error: Ports are not available: bind: Only one usage of each socket address
```

**Solution:**
```bash
# Automatique
fix-docker.bat

# Manuel
netstat -ano | findstr :8888
taskkill /F /PID <PID>
```

### Problème 2 : Service "unhealthy"

**Diagnostic:**
```bash
docker logs discovery-server --tail 100
docker inspect discovery-server | findstr "Health"
```

**Solutions:**
1. Augmenter `start_period` dans `docker-compose.yml`
2. Vérifier les logs pour des erreurs spécifiques
3. Redémarrer le service: `docker-compose restart discovery-server`

### Problème 3 : Services ne s'enregistrent pas dans Eureka

**Vérifier:**
```bash
# URL Eureka Dashboard
http://localhost:8761

# Vérifier les logs
docker-compose logs energie-service | findstr "eureka"
```

**Solution:**
```yaml
# Vérifier dans application-docker.yml
eureka:
  client:
    service-url:
      defaultZone: http://discovery-server:8761/eureka/
```

### Problème 4 : Kafka ne démarre pas

```bash
# Vérifier Zookeeper d'abord
docker logs zookeeper --tail 50

# Recréer Kafka
docker-compose rm -f kafka
docker-compose up -d kafka
```

### Problème 5 : Frontend ne charge pas

**Vérifier nginx.conf:**
```nginx
location /api/ {
    proxy_pass http://gateway-service:8080/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
}
```

**Tester depuis le conteneur:**
```bash
docker exec irrigation-frontend curl http://gateway-service:8080/actuator/health
```

### Logs Utiles

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker-compose logs -f energie-service

# Dernières 100 lignes
docker logs energie-service --tail 100 -f

# Depuis un timestamp
docker logs --since 2024-01-02T10:00:00 energie-service
```

---

## 🔄 Migration H2 → PostgreSQL

### Étapes Réalisées ✅

1. **Ajout des dépendances PostgreSQL**
```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

2. **Configuration application-docker.yml**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://postgres-energie:5432/energiedb
    username: energie_user
    password: energie_pass
    driver-class-name: org.postgresql.Driver
  
  jpa:
    hibernate:
      ddl-auto: update
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
```

3. **Conteneurs PostgreSQL dans docker-compose.yml**
```yaml
postgres-energie:
  image: postgres:15-alpine
  environment:
    POSTGRES_DB: energiedb
    POSTGRES_USER: energie_user
    POSTGRES_PASSWORD: energie_pass
  volumes:
    - postgres_energie_data:/var/lib/postgresql/data
```

### Export/Import de Données

Si vous avez des données en H2 à migrer :

```bash
# 1. Export depuis H2 (en mode local)
# Démarrer l'application localement avec H2
# Aller sur http://localhost:8081/h2-console
# Exécuter: SCRIPT TO 'backup.sql'

# 2. Import dans PostgreSQL
docker exec -i postgres-energie psql -U energie_user -d energiedb < backup.sql
```

---

## 📊 URLs d'Accès

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:4200 | Application Angular |
| Eureka Dashboard | http://localhost:8761 | Service Discovery |
| Config Server | http://localhost:8888/actuator/health | Configuration centralisée |
| Gateway | http://localhost:8080 | API Gateway |
| Energie API | http://localhost:8081/api/pompes | Service Énergie |
| Eau API | http://localhost:8082/api/reservoirs | Service Eau |

---

## 🧪 Tests Manuels

### 1. Créer une Pompe
```bash
curl -X POST http://localhost:8080/api/pompes \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Pompe Test",
    "puissance": 5.5,
    "statut": "ACTIF"
  }'
```

### 2. Lister les Pompes
```bash
curl http://localhost:8080/api/pompes
```

### 3. Créer un Réservoir
```bash
curl -X POST http://localhost:8080/api/reservoirs \
  -H "Content-Type: application/json" \
  -d '{
    "nom": "Réservoir Test",
    "capaciteMax": 1000,
    "niveauActuel": 500
  }'
```

### 4. Tester la Communication Feign
```bash
curl http://localhost:8082/api/reservoirs/test-pompe/1
```

### 5. Provoquer une Surconsommation (Kafka)
```bash
curl -X POST http://localhost:8081/api/consommations \
  -H "Content-Type: application/json" \
  -d '{
    "pompeId": 1,
    "consommation": 15.0
  }'

# Vérifier les logs du service Eau
docker logs eau-service | findstr "SURCONSOMMATION"
```

---

## 🔐 Sécurité (Production)

### ⚠️ À faire avant la production :

1. **Changer les mots de passe**
```yaml
environment:
  POSTGRES_PASSWORD: ${DB_PASSWORD}  # Via .env sécurisé
```

2. **Activer HTTPS**
```yaml
nginx.conf:
listen 443 ssl;
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/ssl/key.pem;
```

3. **Limiter l'exposition des ports**
```yaml
ports:
  - "127.0.0.1:8888:8888"  # Seulement localhost
```

4. **Activer l'authentification Spring Security**

5. **Configurer des secrets Kubernetes** (si déploiement K8s)

---

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)

---

## 🆘 Support

En cas de problème :
1. Consulter [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. Exécuter `check-status.bat` pour un diagnostic
3. Sauvegarder les logs : `docker-compose logs > logs.txt`
4. Ouvrir une issue sur le repository Git