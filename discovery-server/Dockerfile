# Dockerfile pour discovery-server
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copier le JAR
COPY target/*.jar app.jar

# Exposer le port
EXPOSE 8761

# Profil Docker
ENV SPRING_PROFILES_ACTIVE=docker

# Démarrer l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
