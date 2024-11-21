luego de correr el run.sh

ingresar a vault y correr


vault write sys/auth/kubernetes type=kubernetes


luego entrar al pod
1.
cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt

2.	Ejecuta el Comando para Configurar la Autenticación en Vault usando el certificado de kubernetes:
vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt


3.	Asegúrate de reemplazar <service-account-name> y <namespace> por los valores reales correspondientes a tu aplicación. Por ejemplo, si tu ServiceAccount se llama my-app-sa y el namespace es default, el comando sería:

vault write auth/kubernetes/role/my-app-role \
    bound_service_account_names="my-app-sa" \
    bound_service_account_namespaces="default" \
    policies="my-app-policy" \
    ttl="24h"