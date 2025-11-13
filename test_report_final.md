# Rapport de test API Kubernetes

**Date :** 2025-11-13 16:35:31  
**Namespace :** davidbreau  
**Ingress IP :** 4.178.34.136  

---

## État du cluster

### Pods
```
NAME                                READY   STATUS    RESTARTS   AGE
api-deployment-7df9dd5dbb-wwk69     1/1     Running   0          102m
mysql-deployment-755f886f49-hsfsx   1/1     Running   0          5h31m
```

### Services
```
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
api-service     ClusterIP   10.0.83.206    <none>        8000/TCP   172m
mysql-service   ClusterIP   10.0.152.198   <none>        3306/TCP   5h1m
```

### Ingress
```
NAME          CLASS   HOSTS   ADDRESS        PORTS   AGE
api-ingress   nginx   *       4.178.34.136   80      142m
```

---

## Tests des endpoints

### Test 1: Health Probe ✅ PASS

**Commande :**
```bash
curl http://4.178.34.136/davidbreau/health
```

**Réponse :**
```json
{"status":"ok"}
```

---

### Test 2: GET Clients ✅ PASS

**Commande :**
```bash
curl http://4.178.34.136/davidbreau/clients
```

**Réponse :**
```json
[{"first_name":"Alice","last_name":"Martin","email":"alice.martin@example.com","id":1},{"first_name":"Bruno","last_name":"Dupont","email":"bruno.dupont@example.com","id":2},{"first_name":"Claire","last_name":"Leroy","email":"claire.leroy@example.com","id":3},{"first_name":"David","last_name":"Moreau","email":"david.moreau@example.com","id":4},{"first_name":"Emma","last_name":"Garcia","email":"emma.garcia@example.com","id":5},{"first_name":"Farid","last_name":"Lopez","email":"farid.lopez@example.com","id":6},{"first_name":"Ghita","last_name":"Rossi","email":"ghita.rossi@example.com","id":7},{"first_name":"Hugo","last_name":"Bernard","email":"hugo.bernard@example.com","id":8},{"first_name":"Inès","last_name":"Robert","email":"ines.robert@example.com","id":9},{"first_name":"Jules","last_name":"Richard","email":"jules.richard@example.com","id":10}]
```

---

### Test 3: POST Nouveau Client ✅ PASS

**Commande :**
```bash
curl -X POST http://4.178.34.136/davidbreau/clients \
  -H "Content-Type: application/json" \
  -d '{"first_name":"TestAuto","last_name":"Script","email":"test@auto.com"}'
```

**Réponse :**
```json
{"first_name":"TestAuto","last_name":"Script","email":"test@auto.com","id":15}
```

---

### Test 4: GET Client par ID ✅ PASS

**Commande :**
```bash
curl http://4.178.34.136/davidbreau/clients/15
```

**Réponse :**
```json
{"first_name":"TestAuto","last_name":"Script","email":"test@auto.com","id":15}
```

---

### Test 5: DELETE Client ✅ PASS

**Commande :**
```bash
curl -X DELETE http://4.178.34.136/davidbreau/clients/15
```

**Réponse :**
```

```

**Vérification (GET après DELETE) :**
```
{"detail":"Client not found"}
404
```

---

## Résumé des tests

| Test | Endpoint | Statut |
|------|----------|--------|
| 1 | GET /health | ✅ PASS |
| 2 | GET /clients | ✅ PASS |
| 3 | POST /clients | ✅ PASS |
| 4 | GET /clients/{id} | ✅ PASS |
| 5 | DELETE /clients/{id} | ✅ PASS |

---

## Fichiers YAML du déploiement

```
total 28K
-rw-rw-r-- 1 utilisateur utilisateur  178 nov.  13 15:10 api-configmap.yaml
-rw-rw-r-- 1 utilisateur utilisateur 1,4K nov.  13 15:10 api-deployment.yaml
-rw-rw-r-- 1 utilisateur utilisateur  201 nov.  13 15:10 api-service.yaml
-rw-rw-r-- 1 utilisateur utilisateur  419 nov.  13 15:10 ingress.yaml
-rw-rw-r-- 1 utilisateur utilisateur 1,2K nov.  13 11:17 mysql-deployment.yaml
-rw-rw-r-- 1 utilisateur utilisateur  266 nov.  13 11:17 mysql-pvc.yaml
-rw-rw-r-- 1 utilisateur utilisateur  205 nov.  13 11:43 mysql-service.yaml
```

---

**Rapport généré automatiquement par test_api.sh**
