@echo off
chcp 65001 >nul

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║      📝 REMPLISSAGE DES FICHIERS KUBERNETES                 ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM ==================================================================
REM 1. NAMESPACE
REM ==================================================================
echo [1/28] Création namespace...
(
echo apiVersion: v1
echo kind: Namespace
echo metadata:
echo   name: irrigation
echo   labels:
echo     name: irrigation
) > k8s\namespaces\irrigation-namespace.yaml

REM ==================================================================
REM 2. CONFIGMAPS
REM ==================================================================
echo [2/28] Création ConfigMap Eureka...
(
echo apiVersion: v1
echo kind: ConfigMap
echo metadata:
echo   name: eureka-config
echo   namespace: irrigation
echo data:
echo   EUREKA_SERVER_URL: "http://discovery-server:8761/eureka/"
) > k8s\configmaps\eureka-config.yaml

echo [3/28] Création ConfigMap PostgreSQL...
(
echo apiVersion: v1
echo kind: ConfigMap
echo metadata:
echo   name: postgres-config
echo   namespace: irrigation
echo data:
echo   POSTGRES_ENERGIE_DB: "energiedb"
echo   POSTGRES_EAU_DB: "eaudb"
) > k8s\configmaps\postgres-config.yaml

REM ==================================================================
REM 3. SECRETS
REM ==================================================================
echo [4/28] Création Secrets PostgreSQL...
(
echo apiVersion: v1
echo kind: Secret
echo metadata:
echo   name: postgres-secrets
echo   namespace: irrigation
echo type: Opaque
echo stringData:
echo   POSTGRES_ENERGIE_USER: "energie_user"
echo   POSTGRES_ENERGIE_PASSWORD: "energie_pass"
echo   POSTGRES_EAU_USER: "eau_user"
echo   POSTGRES_EAU_PASSWORD: "eau_pass"
) > k8s\secrets\postgres-secrets.yaml

REM ==================================================================
REM 4. PERSISTENT VOLUMES
REM ==================================================================
echo [5/28] PV PostgreSQL Energie...
(
echo apiVersion: v1
echo kind: PersistentVolume
echo metadata:
echo   name: postgres-energie-pv
echo   namespace: irrigation
echo spec:
echo   capacity:
echo     storage: 5Gi
echo   accessModes:
echo     - ReadWriteOnce
echo   hostPath:
echo     path: /data/postgres-energie
) > k8s\persistent-volumes\postgres-energie-pv.yaml

echo [6/28] PVC PostgreSQL Energie...
(
echo apiVersion: v1
echo kind: PersistentVolumeClaim
echo metadata:
echo   name: postgres-energie-pvc
echo   namespace: irrigation
echo spec:
echo   accessModes:
echo     - ReadWriteOnce
echo   resources:
echo     requests:
echo       storage: 5Gi
) > k8s\persistent-volumes\postgres-energie-pvc.yaml

echo [7/28] PV PostgreSQL Eau...
(
echo apiVersion: v1
echo kind: PersistentVolume
echo metadata:
echo   name: postgres-eau-pv
echo   namespace: irrigation
echo spec:
echo   capacity:
echo     storage: 5Gi
echo   accessModes:
echo     - ReadWriteOnce
echo   hostPath:
echo     path: /data/postgres-eau
) > k8s\persistent-volumes\postgres-eau-pv.yaml

echo [8/28] PVC PostgreSQL Eau...
(
echo apiVersion: v1
echo kind: PersistentVolumeClaim
echo metadata:
echo   name: postgres-eau-pvc
echo   namespace: irrigation
echo spec:
echo   accessModes:
echo     - ReadWriteOnce
echo   resources:
echo     requests:
echo       storage: 5Gi
) > k8s\persistent-volumes\postgres-eau-pvc.yaml

REM ==================================================================
REM 5. DEPLOYMENTS - POSTGRESQL
REM ==================================================================
echo [9/28] Deployment PostgreSQL Energie...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: postgres-energie
echo   namespace: irrigation
echo spec:
echo   replicas: 1
echo   selector:
echo     matchLabels:
echo       app: postgres-energie
echo   template:
echo     metadata:
echo       labels:
echo         app: postgres-energie
echo     spec:
echo       containers:
echo       - name: postgres
echo         image: postgres:15-alpine
echo         ports:
echo         - containerPort: 5432
echo         env:
echo         - name: POSTGRES_DB
echo           valueFrom:
echo             configMapKeyRef:
echo               name: postgres-config
echo               key: POSTGRES_ENERGIE_DB
echo         - name: POSTGRES_USER
echo           valueFrom:
echo             secretKeyRef:
echo               name: postgres-secrets
echo               key: POSTGRES_ENERGIE_USER
echo         - name: POSTGRES_PASSWORD
echo           valueFrom:
echo             secretKeyRef:
echo               name: postgres-secrets
echo               key: POSTGRES_ENERGIE_PASSWORD
echo         volumeMounts:
echo         - name: postgres-storage
echo           mountPath: /var/lib/postgresql/data
echo       volumes:
echo       - name: postgres-storage
echo         persistentVolumeClaim:
echo           claimName: postgres-energie-pvc
) > k8s\deployments\postgres-energie-deployment.yaml

echo [10/28] Deployment PostgreSQL Eau...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: postgres-eau
echo   namespace: irrigation
echo spec:
echo   replicas: 1
echo   selector:
echo     matchLabels:
echo       app: postgres-eau
echo   template:
echo     metadata:
echo       labels:
echo         app: postgres-eau
echo     spec:
echo       containers:
echo       - name: postgres
echo         image: postgres:15-alpine
echo         ports:
echo         - containerPort: 5432
echo         env:
echo         - name: POSTGRES_DB
echo           valueFrom:
echo             configMapKeyRef:
echo               name: postgres-config
echo               key: POSTGRES_EAU_DB
echo         - name: POSTGRES_USER
echo           valueFrom:
echo             secretKeyRef:
echo               name: postgres-secrets
echo               key: POSTGRES_EAU_USER
echo         - name: POSTGRES_PASSWORD
echo           valueFrom:
echo             secretKeyRef:
echo               name: postgres-secrets
echo               key: POSTGRES_EAU_PASSWORD
echo         volumeMounts:
echo         - name: postgres-storage
echo           mountPath: /var/lib/postgresql/data
echo       volumes:
echo       - name: postgres-storage
echo         persistentVolumeClaim:
echo           claimName: postgres-eau-pvc
) > k8s\deployments\postgres-eau-deployment.yaml

REM ==================================================================
REM 6. DEPLOYMENTS - KAFKA/ZOOKEEPER
REM ==================================================================
echo [11/28] Deployment Zookeeper...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: zookeeper
echo   namespace: irrigation
echo spec:
echo   replicas: 1
echo   selector:
echo     matchLabels:
echo       app: zookeeper
echo   template:
echo     metadata:
echo       labels:
echo         app: zookeeper
echo     spec:
echo       containers:
echo       - name: zookeeper
echo         image: confluentinc/cp-zookeeper:7.4.0
echo         ports:
echo         - containerPort: 2181
echo         env:
echo         - name: ZOOKEEPER_CLIENT_PORT
echo           value: "2181"
echo         - name: ZOOKEEPER_TICK_TIME
echo           value: "2000"
) > k8s\deployments\zookeeper-deployment.yaml

echo [12/28] Deployment Kafka...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: kafka
echo   namespace: irrigation
echo spec:
echo   replicas: 1
echo   selector:
echo     matchLabels:
echo       app: kafka
echo   template:
echo     metadata:
echo       labels:
echo         app: kafka
echo     spec:
echo       containers:
echo       - name: kafka
echo         image: confluentinc/cp-kafka:7.4.0
echo         ports:
echo         - containerPort: 9092
echo         env:
echo         - name: KAFKA_BROKER_ID
echo           value: "1"
echo         - name: KAFKA_ZOOKEEPER_CONNECT
echo           value: "zookeeper:2181"
echo         - name: KAFKA_ADVERTISED_LISTENERS
echo           value: "PLAINTEXT://kafka:9092"
echo         - name: KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR
echo           value: "1"
) > k8s\deployments\kafka-deployment.yaml

REM ==================================================================
REM 7. DEPLOYMENTS - MICROSERVICES
REM ==================================================================
echo [13/28] Deployment Discovery Server...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: discovery-server
echo   namespace: irrigation
echo spec:
echo   replicas: 1
echo   selector:
echo     matchLabels:
echo       app: discovery-server
echo   template:
echo     metadata:
echo       labels:
echo         app: discovery-server
echo     spec:
echo       containers:
echo       - name: discovery-server
echo         image: systeme-gestion-energie-eau-pour-station-irrigation-discovery-server:latest
echo         imagePullPolicy: Never
echo         ports:
echo         - containerPort: 8761
echo         env:
echo         - name: SPRING_PROFILES_ACTIVE
echo           value: "docker"
) > k8s\deployments\discovery-server-deployment.yaml

echo [14/28] Deployment Config Server...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: config-server
echo   namespace: irrigation
echo spec:
echo   replicas: 1
echo   selector:
echo     matchLabels:
echo       app: config-server
echo   template:
echo     metadata:
echo       labels:
echo         app: config-server
echo     spec:
echo       containers:
echo       - name: config-server
echo         image: systeme-gestion-energie-eau-pour-station-irrigation-config-server:latest
echo         imagePullPolicy: Never
echo         ports:
echo         - containerPort: 8888
echo         env:
echo         - name: SPRING_PROFILES_ACTIVE
echo           value: "docker"
echo         - name: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
echo           valueFrom:
echo             configMapKeyRef:
echo               name: eureka-config
echo               key: EUREKA_SERVER_URL
) > k8s\deployments\config-server-deployment.yaml

echo [15/28] Deployment Gateway...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: gateway-service
echo   namespace: irrigation
echo spec:
echo   replicas: 2
echo   selector:
echo     matchLabels:
echo       app: gateway-service
echo   template:
echo     metadata:
echo       labels:
echo         app: gateway-service
echo     spec:
echo       containers:
echo       - name: gateway-service
echo         image: systeme-gestion-energie-eau-pour-station-irrigation-gateway-service:latest
echo         imagePullPolicy: Never
echo         ports:
echo         - containerPort: 8080
echo         env:
echo         - name: SPRING_PROFILES_ACTIVE
echo           value: "docker"
echo         - name: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
echo           valueFrom:
echo             configMapKeyRef:
echo               name: eureka-config
echo               key: EUREKA_SERVER_URL
) > k8s\deployments\gateway-deployment.yaml

echo [16/28] Deployment Energie Service...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: energie-service
echo   namespace: irrigation
echo spec:
echo   replicas: 2
echo   selector:
echo     matchLabels:
echo       app: energie-service
echo   template:
echo     metadata:
echo       labels:
echo         app: energie-service
echo     spec:
echo       containers:
echo       - name: energie-service
echo         image: systeme-gestion-energie-eau-pour-station-irrigation-energie-service:latest
echo         imagePullPolicy: Never
echo         ports:
echo         - containerPort: 8081
echo         env:
echo         - name: SPRING_PROFILES_ACTIVE
echo           value: "docker"
echo         - name: SPRING_DATASOURCE_URL
echo           value: "jdbc:postgresql://postgres-energie:5432/energiedb"
echo         - name: SPRING_DATASOURCE_USERNAME
echo           valueFrom:
echo             secretKeyRef:
echo               name: postgres-secrets
echo               key: POSTGRES_ENERGIE_USER
echo         - name: SPRING_DATASOURCE_PASSWORD
echo           valueFrom:
echo             secretKeyRef:
echo               name: postgres-secrets
echo               key: POSTGRES_ENERGIE_PASSWORD
echo         - name: SPRING_KAFKA_BOOTSTRAP_SERVERS
echo           value: "kafka:9092"
echo         - name: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
echo           valueFrom:
echo             configMapKeyRef:
echo               name: eureka-config
echo               key: EUREKA_SERVER_URL
) > k8s\deployments\energie-deployment.yaml

echo [17/28] Deployment Eau Service...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: eau-service
echo   namespace: irrigation
echo spec:
echo   replicas: 2
echo   selector:
echo     matchLabels:
echo       app: eau-service
echo   template:
echo     metadata:
echo       labels:
echo         app: eau-service
echo     spec:
echo       containers:
echo       - name: eau-service
echo         image: systeme-gestion-energie-eau-pour-station-irrigation-eau-service:latest
echo         imagePullPolicy: Never
echo         ports:
echo         - containerPort: 8082
echo         env:
echo         - name: SPRING_PROFILES_ACTIVE
echo           value: "docker"
echo         - name: SPRING_DATASOURCE_URL
echo           value: "jdbc:postgresql://postgres-eau:5432/eaudb"
echo         - name: SPRING_DATASOURCE_USERNAME
echo           valueFrom:
echo             secretKeyRef:
echo               name: postgres-secrets
echo               key: POSTGRES_EAU_USER
echo         - name: SPRING_DATASOURCE_PASSWORD
echo           valueFrom:
echo             secretKeyRef:
echo               name: postgres-secrets
echo               key: POSTGRES_EAU_PASSWORD
echo         - name: SPRING_KAFKA_BOOTSTRAP_SERVERS
echo           value: "kafka:9092"
echo         - name: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE
echo           valueFrom:
echo             configMapKeyRef:
echo               name: eureka-config
echo               key: EUREKA_SERVER_URL
) > k8s\deployments\eau-deployment.yaml

echo [18/28] Deployment Frontend...
(
echo apiVersion: apps/v1
echo kind: Deployment
echo metadata:
echo   name: frontend
echo   namespace: irrigation
echo spec:
echo   replicas: 2
echo   selector:
echo     matchLabels:
echo       app: frontend
echo   template:
echo     metadata:
echo       labels:
echo         app: frontend
echo     spec:
echo       containers:
echo       - name: frontend
echo         image: systeme-gestion-energie-eau-pour-station-irrigation-frontend:latest
echo         imagePullPolicy: Never
echo         ports:
echo         - containerPort: 80
) > k8s\deployments\frontend-deployment.yaml

REM ==================================================================
REM 8. SERVICES
REM ==================================================================
echo [19/28] Service PostgreSQL Energie...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: postgres-energie
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: postgres-energie
echo   ports:
echo   - port: 5432
echo     targetPort: 5432
echo   type: ClusterIP
) > k8s\services\postgres-energie-service.yaml

echo [20/28] Service PostgreSQL Eau...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: postgres-eau
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: postgres-eau
echo   ports:
echo   - port: 5432
echo     targetPort: 5432
echo   type: ClusterIP
) > k8s\services\postgres-eau-service.yaml

echo [21/28] Service Zookeeper...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: zookeeper
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: zookeeper
echo   ports:
echo   - port: 2181
echo     targetPort: 2181
echo   type: ClusterIP
) > k8s\services\zookeeper-service.yaml

echo [22/28] Service Kafka...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: kafka
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: kafka
echo   ports:
echo   - port: 9092
echo     targetPort: 9092
echo   type: ClusterIP
) > k8s\services\kafka-service.yaml

echo [23/28] Service Discovery Server...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: discovery-server
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: discovery-server
echo   ports:
echo   - port: 8761
echo     targetPort: 8761
echo   type: ClusterIP
) > k8s\services\discovery-server-service.yaml

echo [24/28] Service Config Server...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: config-server
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: config-server
echo   ports:
echo   - port: 8888
echo     targetPort: 8888
echo   type: ClusterIP
) > k8s\services\config-server-service.yaml

echo [25/28] Service Gateway...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: gateway-service
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: gateway-service
echo   ports:
echo   - port: 8080
echo     targetPort: 8080
echo   type: LoadBalancer
) > k8s\services\gateway-service.yaml

echo [26/28] Service Energie...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: energie-service
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: energie-service
echo   ports:
echo   - port: 8081
echo     targetPort: 8081
echo   type: ClusterIP
) > k8s\services\energie-service.yaml

echo [27/28] Service Eau...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: eau-service
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: eau-service
echo   ports:
echo   - port: 8082
echo     targetPort: 8082
echo   type: ClusterIP
) > k8s\services\eau-service.yaml

echo [28/28] Service Frontend...
(
echo apiVersion: v1
echo kind: Service
echo metadata:
echo   name: frontend
echo   namespace: irrigation
echo spec:
echo   selector:
echo     app: frontend
echo   ports:
echo   - port: 80
echo     targetPort: 80
echo   type: LoadBalancer
) > k8s\services\frontend-service.yaml

REM ==================================================================
REM 9. HPA (Horizontal Pod Autoscaler)
REM ==================================================================
echo Création HPA...
(
echo apiVersion: autoscaling/v2
echo kind: HorizontalPodAutoscaler
echo metadata:
echo   name: energie-hpa
echo   namespace: irrigation
echo spec:
echo   scaleTargetRef:
echo     apiVersion: apps/v1
echo     kind: Deployment
echo     name: energie-service
echo   minReplicas: 2
echo   maxReplicas: 5
echo   metrics:
echo   - type: Resource
echo     resource:
echo       name: cpu
echo       target:
echo         type: Utilization
echo         averageUtilization: 70
) > k8s\hpa\energie-hpa.yaml

(
echo apiVersion: autoscaling/v2
echo kind: HorizontalPodAutoscaler
echo metadata:
echo   name: eau-hpa
echo   namespace: irrigation
echo spec:
echo   scaleTargetRef:
echo     apiVersion: apps/v1
echo     kind: Deployment
echo     name: eau-service
echo   minReplicas: 2
echo   maxReplicas: 5
echo   metrics:
echo   - type: Resource
echo     resource:
echo       name: cpu
echo       target:
echo         type: Utilization
echo         averageUtilization: 70
) > k8s\hpa\eau-hpa.yaml

(
echo apiVersion: autoscaling/v2
echo kind: HorizontalPodAutoscaler
echo metadata:
echo   name: gateway-hpa
echo   namespace: irrigation
echo spec:
echo   scaleTargetRef:
echo     apiVersion: apps/v1
echo     kind: Deployment
echo     name: gateway-service
echo   minReplicas: 2
echo   maxReplicas: 5
echo   metrics:
echo   - type: Resource
echo     resource:
echo       name: cpu
echo       target:
echo         type: Utilization
echo         averageUtilization: 70
) > k8s\hpa\gateway-hpa.yaml

REM ==================================================================
REM 10. INGRESS
REM ==================================================================
echo Création Ingress...
(
echo apiVersion: networking.k8s.io/v1
echo kind: Ingress
echo metadata:
echo   name: irrigation-ingress
echo   namespace: irrigation
echo   annotations:
echo     nginx.ingress.kubernetes.io/rewrite-target: /
echo spec:
echo   rules:
echo   - host: irrigation.local
echo     http:
echo       paths:
echo       - path: /
echo         pathType: Prefix
echo         backend:
echo           service:
echo             name: frontend
echo             port:
echo               number: 80
echo       - path: /api
echo         pathType: Prefix
echo         backend:
echo           service:
echo             name: gateway-service
echo             port:
echo               number: 8080
) > k8s\ingress\ingress.yaml

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║         ✅ TOUS LES FICHIERS YAML SONT CRÉÉS !               ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 📝 Fichiers créés: 28
echo    - 1 Namespace
echo    - 2 ConfigMaps
echo    - 1 Secret
echo    - 4 PersistentVolumes/Claims
echo    - 10 Deployments
echo    - 10 Services
echo    - 3 HPA
echo    - 1 Ingress
echo.
echo 🚀 Prochaine étape: Charger les images Docker dans Minikube
echo    minikube image load NOM_IMAGE:latest
echo.

pause