#!/bin/bash

# Variables
NAMESPACE="vault"
POD_NAME="vault-0"

# Crear namespace para Vault
kubectl create namespace $NAMESPACE

# Agregar repositorio de Helm para Vault e instalar Vault en el namespace
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Instalar Vault en el namespace con Helm
helm install vault hashicorp/vault --namespace $NAMESPACE --set "server.dev.enabled=true"

# Esperar a que el pod de Vault esté listo
echo "Esperando a que Vault esté listo..."
kubectl wait --for=condition=ready pod -n $NAMESPACE $POD_NAME --timeout=120s

# Esperar hasta que el pod esté en ejecución y extraer las claves y el token de los logs
echo "Esperando a que Vault esté inicializado y mostrando claves de desellado..."
while true; do
    # Verificar si ya están disponibles en los logs
    LOGS=$(kubectl logs -n $NAMESPACE $POD_NAME)
    if echo "$LOGS" | grep -q "Unseal Key"; then
        UNSEAL_KEY=$(echo "$LOGS" | grep 'Unseal Key' | awk '{print $NF}')
        ROOT_TOKEN=$(echo "$LOGS" | grep 'Root Token' | awk '{print $NF}')
        break
    else
        echo "Esperando a que los valores estén disponibles en los logs..."
        sleep 5
    fi
done

# Mostrar resultados
echo "Vault ha sido inicializado con éxito."
echo "La clave de desellado (unseal key) es:"
echo "$UNSEAL_KEY"

echo "El token de root es:"
echo "$ROOT_TOKEN"

# Instrucciones adicionales
echo "Para deselladar Vault, usa la clave de desellado con el siguiente comando:"
echo "kubectl exec -n $NAMESPACE $POD_NAME -- vault operator unseal <UNSEAL_KEY>"