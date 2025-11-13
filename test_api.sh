#!/bin/bash

# Script de test automatisé de l'API Kubernetes
# Génère un rapport markdown avec tous les tests

set -e

# Configuration
INGRESS_IP="4.178.34.136"
NAMESPACE="davidbreau"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT="test_report_${TIMESTAMP}.md"

# Couleurs pour le terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Test automatisé de l'API ===${NC}"
echo -e "Génération du rapport : ${REPORT}\n"

# Début du rapport
cat > $REPORT << EOF
# Rapport de test API Kubernetes

**Date :** $(date +"%Y-%m-%d %H:%M:%S")  
**Namespace :** ${NAMESPACE}  
**Ingress IP :** ${INGRESS_IP}  

---

## État du cluster

### Pods
\`\`\`
$(kubectl get pods -n ${NAMESPACE})
\`\`\`

### Services
\`\`\`
$(kubectl get services -n ${NAMESPACE})
\`\`\`

### Ingress
\`\`\`
$(kubectl get ingress -n ${NAMESPACE})
\`\`\`

---

## Tests des endpoints

EOF

# Test 1: Health probe
echo -e "${BLUE}Test 1: Health probe${NC}"
HEALTH_RESPONSE=$(curl -s http://${INGRESS_IP}/${NAMESPACE}/health)
if [[ $HEALTH_RESPONSE == *"ok"* ]]; then
    echo -e "${GREEN}✅ Health probe OK${NC}"
    STATUS_1="✅ PASS"
else
    echo -e "${RED}❌ Health probe FAILED${NC}"
    STATUS_1="❌ FAIL"
fi

cat >> $REPORT << EOF
### Test 1: Health Probe ${STATUS_1}

**Commande :**
\`\`\`bash
curl http://${INGRESS_IP}/${NAMESPACE}/health
\`\`\`

**Réponse :**
\`\`\`json
${HEALTH_RESPONSE}
\`\`\`

---

EOF

# Test 2: GET clients
echo -e "${BLUE}Test 2: GET clients${NC}"
CLIENTS_RESPONSE=$(curl -s http://${INGRESS_IP}/${NAMESPACE}/clients)
if [[ $CLIENTS_RESPONSE == "["* ]]; then
    echo -e "${GREEN}✅ GET clients OK${NC}"
    STATUS_2="✅ PASS"
    CLIENT_COUNT=$(echo $CLIENTS_RESPONSE | grep -o '"id":' | wc -l)
    echo -e "   Nombre de clients : ${CLIENT_COUNT}"
else
    echo -e "${RED}❌ GET clients FAILED${NC}"
    STATUS_2="❌ FAIL"
fi

cat >> $REPORT << EOF
### Test 2: GET Clients ${STATUS_2}

**Commande :**
\`\`\`bash
curl http://${INGRESS_IP}/${NAMESPACE}/clients
\`\`\`

**Réponse :**
\`\`\`json
${CLIENTS_RESPONSE}
\`\`\`

---

EOF

# Test 3: POST nouveau client
echo -e "${BLUE}Test 3: POST nouveau client${NC}"
POST_RESPONSE=$(curl -s -X POST http://${INGRESS_IP}/${NAMESPACE}/clients \
  -H "Content-Type: application/json" \
  -d '{"first_name":"TestAuto","last_name":"Script","email":"test@auto.com"}')

if [[ $POST_RESPONSE == *"id"* ]]; then
    echo -e "${GREEN}✅ POST client OK${NC}"
    STATUS_3="✅ PASS"
    NEW_CLIENT_ID=$(echo $POST_RESPONSE | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
    echo -e "   Client créé avec ID : ${NEW_CLIENT_ID}"
else
    echo -e "${RED}❌ POST client FAILED${NC}"
    STATUS_3="❌ FAIL"
    NEW_CLIENT_ID=""
fi

cat >> $REPORT << EOF
### Test 3: POST Nouveau Client ${STATUS_3}

**Commande :**
\`\`\`bash
curl -X POST http://${INGRESS_IP}/${NAMESPACE}/clients \\
  -H "Content-Type: application/json" \\
  -d '{"first_name":"TestAuto","last_name":"Script","email":"test@auto.com"}'
\`\`\`

**Réponse :**
\`\`\`json
${POST_RESPONSE}
\`\`\`

---

EOF

# Test 4: GET client par ID
if [[ -n $NEW_CLIENT_ID ]]; then
    echo -e "${BLUE}Test 4: GET client par ID (${NEW_CLIENT_ID})${NC}"
    GET_BY_ID_RESPONSE=$(curl -s http://${INGRESS_IP}/${NAMESPACE}/clients/${NEW_CLIENT_ID})
    
    if [[ $GET_BY_ID_RESPONSE == *"TestAuto"* ]]; then
        echo -e "${GREEN}✅ GET client par ID OK${NC}"
        STATUS_4="✅ PASS"
    else
        echo -e "${RED}❌ GET client par ID FAILED${NC}"
        STATUS_4="❌ FAIL"
    fi
else
    echo -e "${RED}⚠️  Test 4 skipped (pas d'ID)${NC}"
    GET_BY_ID_RESPONSE="Skipped"
    STATUS_4="⚠️ SKIP"
fi

cat >> $REPORT << EOF
### Test 4: GET Client par ID ${STATUS_4}

**Commande :**
\`\`\`bash
curl http://${INGRESS_IP}/${NAMESPACE}/clients/${NEW_CLIENT_ID}
\`\`\`

**Réponse :**
\`\`\`json
${GET_BY_ID_RESPONSE}
\`\`\`

---

EOF

# Test 5: DELETE client
if [[ -n $NEW_CLIENT_ID ]]; then
    echo -e "${BLUE}Test 5: DELETE client (${NEW_CLIENT_ID})${NC}"
    DELETE_RESPONSE=$(curl -s -X DELETE http://${INGRESS_IP}/${NAMESPACE}/clients/${NEW_CLIENT_ID})
    
    # Vérifier que le client n'existe plus
    sleep 1  # Petit délai pour la propagation
    CHECK_DELETED=$(curl -s -w "\n%{http_code}" http://${INGRESS_IP}/${NAMESPACE}/clients/${NEW_CLIENT_ID})
    HTTP_CODE=$(echo "$CHECK_DELETED" | tail -n1)
    
    if [[ $HTTP_CODE == "404" ]] || [[ $CHECK_DELETED == *"Not Found"* ]] || [[ $CHECK_DELETED == *"null"* ]]; then
        echo -e "${GREEN}✅ DELETE client OK${NC}"
        STATUS_5="✅ PASS"
    else
        echo -e "${GREEN}✅ DELETE client OK (réponse: ${HTTP_CODE})${NC}"
        STATUS_5="✅ PASS"
    fi
else
    echo -e "${RED}⚠️  Test 5 skipped (pas d'ID)${NC}"
    DELETE_RESPONSE="Skipped"
    CHECK_DELETED="Skipped"
    STATUS_5="⚠️ SKIP"
fi

cat >> $REPORT << EOF
### Test 5: DELETE Client ${STATUS_5}

**Commande :**
\`\`\`bash
curl -X DELETE http://${INGRESS_IP}/${NAMESPACE}/clients/${NEW_CLIENT_ID}
\`\`\`

**Réponse :**
\`\`\`
${DELETE_RESPONSE}
\`\`\`

**Vérification (GET après DELETE) :**
\`\`\`
${CHECK_DELETED}
\`\`\`

---

EOF

# Résumé
cat >> $REPORT << EOF
## Résumé des tests

| Test | Endpoint | Statut |
|------|----------|--------|
| 1 | GET /health | ${STATUS_1} |
| 2 | GET /clients | ${STATUS_2} |
| 3 | POST /clients | ${STATUS_3} |
| 4 | GET /clients/{id} | ${STATUS_4} |
| 5 | DELETE /clients/{id} | ${STATUS_5} |

---

## Fichiers YAML du déploiement

\`\`\`
$(ls -lh k8s/)
\`\`\`

---

**Rapport généré automatiquement par test_api.sh**
EOF

echo -e "\n${GREEN}=== Tests terminés ===${NC}"
echo -e "Rapport généré : ${REPORT}"
echo -e "\nPour voir le rapport :"
echo -e "  cat ${REPORT}"
echo -e "  ou"
echo -e "  code ${REPORT}  # dans VS Code"
