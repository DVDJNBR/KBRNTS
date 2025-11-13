# Déploiement Kubernetes - API Python + MySQL

Projet de déploiement d'une API Python et d'une base de données MySQL sur Azure Kubernetes Service (AKS).

## 📋 Architecture

- **MySQL** : Base de données avec stockage persistant (PVC 5Gi)
- **API Python** : API REST exposant des endpoints CRUD pour gérer des clients
- **Ingress** : Exposition publique de l'API avec préfixe `/davidbreau`

## 🚀 Déploiement

### Prérequis

- `kubectl` configuré et connecté au cluster AKS
- Accès au namespace `davidbreau`

### Étapes de déploiement

1. **Créer le Secret MySQL**
```bash
kubectl create secret generic mysql-secret --from-env-file=.env
```

2. **Déployer les ressources dans l'ordre**
```bash
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml
kubectl apply -f k8s/api-configmap.yaml
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/api-service.yaml
kubectl apply -f k8s/ingress.yaml
```

3. **Vérifier le déploiement**
```bash
kubectl get all -n davidbreau
kubectl get ingress -n davidbreau
```

## 📁 Structure des fichiers

```
.
├── k8s/
│   ├── mysql-secret.yaml          # (créé via kubectl, pas versionné)
│   ├── mysql-pvc.yaml              # PersistentVolumeClaim (5Gi)
│   ├── mysql-deployment.yaml      # Deployment MySQL
│   ├── mysql-service.yaml         # Service MySQL (ClusterIP)
│   ├── api-configmap.yaml         # ConfigMap pour l'API
│   ├── api-deployment.yaml        # Deployment API Python
│   ├── api-service.yaml           # Service API (ClusterIP)
│   └── ingress.yaml               # Ingress avec rewrite-target
├── test_api.sh                    # Script de test automatisé
├── test_report_final.md           # Rapport de test (preuve de fonctionnement)
└── README.md
```

## 🧪 Tests

### Test automatisé

Lancer le script de test qui génère un rapport complet :

```bash
./test_api.sh
```

Le script teste automatiquement :
- ✅ Health probe (`/health`)
- ✅ GET clients (`/clients`)
- ✅ POST client (`/clients`)
- ✅ GET client par ID (`/clients/{id}`)
- ✅ DELETE client (`/clients/{id}`)

Un rapport markdown est généré avec timestamp et peut être consulté dans `test_report_final.md`.

### Tests manuels

**Récupérer l'IP de l'Ingress :**
```bash
kubectl get ingress -n davidbreau
```

**Tester les endpoints :**

```bash
# Health probe
curl http://<INGRESS_IP>/davidbreau/health

# Liste des clients
curl http://<INGRESS_IP>/davidbreau/clients

# Créer un client
curl -X POST http://<INGRESS_IP>/davidbreau/clients \
  -H "Content-Type: application/json" \
  -d '{"first_name":"John","last_name":"Doe","email":"john@example.com"}'

# Récupérer un client par ID
curl http://<INGRESS_IP>/davidbreau/clients/1

# Supprimer un client
curl -X DELETE http://<INGRESS_IP>/davidbreau/clients/1
```

## 🔑 Variables d'environnement

L'API utilise les variables suivantes (définies dans la ConfigMap et le Secret) :

- `MYSQL_HOST` : Nom du service MySQL (`mysql-service`)
- `MYSQL_PORT` : Port MySQL (`3306`)
- `MYSQL_USER` : Utilisateur MySQL (`root`)
- `MYSQL_DB` : Nom de la base de données (`clients`)
- `MYSQL_PASSWORD` : Mot de passe root (depuis le Secret)

## 📊 Ressources Kubernetes

| Ressource | Type | Description |
|-----------|------|-------------|
| `mysql-secret` | Secret | Mot de passe root MySQL |
| `mysql-pvc` | PersistentVolumeClaim | Stockage persistant 5Gi |
| `mysql-deployment` | Deployment | Pod MySQL avec probes |
| `mysql-service` | Service | ClusterIP interne (3306) |
| `api-config` | ConfigMap | Configuration de l'API |
| `api-deployment` | Deployment | Pod API Python avec probes |
| `api-service` | Service | ClusterIP interne (8000) |
| `api-ingress` | Ingress | Exposition publique avec rewrite |

## 🎯 Endpoints publics

Base URL : `http://<INGRESS_IP>/davidbreau`

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/health` | Health check de l'API |
| GET | `/clients` | Liste tous les clients |
| POST | `/clients` | Crée un nouveau client |
| GET | `/clients/{id}` | Récupère un client par ID |
| DELETE | `/clients/{id}` | Supprime un client |

## 🛠️ Troubleshooting

### Les pods ne démarrent pas

```bash
kubectl describe pod <pod-name> -n davidbreau
kubectl logs <pod-name> -n davidbreau
```

### L'Ingress ne fonctionne pas

```bash
kubectl describe ingress api-ingress -n davidbreau
kubectl get ingress -n davidbreau
```

### Problème de connexion MySQL

```bash
kubectl exec -it <mysql-pod-name> -n davidbreau -- mysql -u root -p
```

## 📝 Notes importantes

- Le Secret MySQL est créé depuis un fichier `.env` (non versionné)
- L'API attend la variable `MYSQL_DB` (pas `MYSQL_DATABASE`)
- Le PVC utilise le storageClass `default` (WaitForFirstConsumer)
- L'Ingress utilise l'annotation `rewrite-target` pour retirer le préfixe

## 👨‍💻 Auteur

David Breau - Projet Kubernetes AKS
