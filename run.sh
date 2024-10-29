#!/bin/bash

# Variables
NAMESPACE="vault"

# Crear namespace para Vault
kubectl create namespace $NAMESPACE

# Agregar repositorio de Helm para Vault e instalar Vault en el namespace
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Instalar Vault en el namespace con Helm
helm install vault hashicorp/vault --namespace $NAMESPACE --set "server.dev.enabled=true"

# Esperar a que los pods de Vault estén listos
echo "Esperando a que Vault esté listo..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault --namespace $NAMESPACE --timeout=120s

# Inicializar Vault y guardar claves de acceso
echo "Inicializando Vault..."
kubectl exec -n $NAMESPACE vault-0 -- vault operator init > vault-init.txt

# Extraer tokens y claves de la inicialización
UNSEAL_KEYS=$(grep 'Unseal Key' vault-init.txt | awk '{print $NF}')
ROOT_TOKEN=$(grep 'Initial Root Token' vault-init.txt | awk '{print $NF}')

echo "Vault ha sido inicializado con éxito."
echo "Las claves de desellado (unseal keys) son:"
echo "$UNSEAL_KEYS"

echo "El token de root es:"
echo "$ROOT_TOKEN"

# Limpiar archivo de inicialización
rm vault-init.txt

# Instrucciones adicionales
echo "Para deselladar Vault, usa las claves de desellado con el siguiente comando:"
echo "kubectl exec -n $NAMESPACE vault-0 -- vault operator unseal <UNSEAL_KEY>"