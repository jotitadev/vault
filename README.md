# Requisitos
* kubectl
* Terraform
* kubens - https://webinstall.dev/kubens/

# Crear el namespace en Kubernetes

```bash
kubectl create ns hashi-vault

```
```bash
kubens hashi-vault
```

```bash
kubectl create serviceaccount vault-auth
```
# Agregar el repositorio de hashicorp al k8s

helm repo add hashicorp https://helm.releases.hashicorp.com
```
# Agregar consul a k8s
```bash
helm install consul hashicorp/consul --values 0_k8s/helm-values-consul.yaml
```
# Agrear vault al cluster de k8s
```bash
helm install vault hashicorp/vault --values 0_k8s/helm-values-vault.yaml
```
# Verificar el estatus de vault-0
```bash
kubectl exec vault-0 -- vault status
```
# Obtener la llave de acceso a nuestro recien instalado vault
```bash
kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
```
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")

# Hacer un port forward hacia k8s y nuestro local
## Unseal los servidores con exposision de puertos
kpf vault-0 8200:8200 #<-- Ingresar con el unseal del cluster-keys.json para desbloquear vault
kpf vault-1 8200:8200 #<-- Ingresar con el unseal del cluster-keys.json para desbloquear vault

Ingresar a: http://192.168.10.151:8200/

## Unseal los servidores con comandos
kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY


## Obtener la informacion del cluster de kubernetes
echo $KUBERNETES_PORT_443_TCP_ADDR
cat /var/run/secrets/kubernetes.io/serviceaccount/token
cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Exportar las variables para terraform
export VAULT_TOKEN="hvs.jakxIRxpMFmZjE0Drkso7kkX"
export VAULT_ADDR="http://127.0.0.1:8200"


## Empezando con terraform
terraform init
terraform plan
terraform apply



vault login

vault write auth/kubernetes/config \
        kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
        token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
        kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
        issuer="https://kubernetes.default.svc.cluster.local"


## Crear un pod para obtener los secretos desde vault
kubectl apply -f 0_k8s/pod-secret-ejemplo.yaml