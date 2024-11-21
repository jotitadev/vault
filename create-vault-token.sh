#!/bin/bash
read -p "Vault token:" VAULT_TOKEN
VAULT_TOKEN=$(echo $VAULT_TOKEN | base64)

# read the yml template from a file and substitute the string
# {{MYVARNAME}} with the value of the MYVARVALUE variable
template=`cat "vault-token.yaml.template" | sed "s/{{VAULT_TOKEN}}/$VAULT_TOKEN/g"`

# apply the yml with the substituted value
echo "$template" | kubectl apply -f -
