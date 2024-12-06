#!/bin/bash

# Variables communes
ACME_HOST="http://in_acme:8080"
CSE_BASE="/~/id-in/cse-in"
DATA_CONTAINER="dataContainer"
SUBSCRIPTION_NAME="mySubscription"
NOTIFICATION_URL="http://flat_script:5000/notification"

# Créer le conteneur de données
echo "Création du conteneur de données..."
curl -X POST "${ACME_HOST}${CSE_BASE}" \
    -H "Content-Type: application/json;ty=3" \
    -H "Accept: application/json" \
    -H "X-M2M-Origin: CAdmin" \
    -H "X-M2M-RI: mykw5lfy47" \
    -H "X-M2M-RVI: 3" \
    -d '{
        "m2m:cnt": {
            "rn": "'${DATA_CONTAINER}'"
        }
    }'
echo -e "\nConteneur de données créé avec succès."

# Ajouter une subscription
echo "Ajout de la subscription..."
curl -X POST "${ACME_HOST}${CSE_BASE}/${DATA_CONTAINER}" \
    -H "Content-Type: application/json;ty=23" \
    -H "X-M2M-Origin: CAdmin" \
    -H "X-M2M-RI: req12345" \
    -H "X-M2M-RVI: 3" \
    -d '{
        "m2m:sub": {
            "rn": "'${SUBSCRIPTION_NAME}'",
            "nu": ["'${NOTIFICATION_URL}'"],
            "nct": 2,
            "enc": {
                "net": [1]
            }
        }
    }'
echo -e "\nSubscription ajoutée avec succès."