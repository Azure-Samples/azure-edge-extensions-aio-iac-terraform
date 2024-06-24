
az config set extension.use_dynamic_install=yes_without_prompt

# Add Az extension
az extension add --upgrade --name azure-iot-ops
az extension add --name connectedk8s

az login --service-principal --tenant "${tenant_id}" --username "${aio_onboard_sp_client_id}" -p="${aio_onboard_sp_client_secret}"
az account set --subscription "${subscription_id}"

.\AksEdgeQuickStartForAio.ps1 -SubscriptionId "${subscription_id}" -TenantId "${tenant_id}" -Location "${location}" -ResourceGroupName "${resource_group_name}" -ClusterName "${arc_resource_name}"

az k8s-extension create -g "${resource_group_name}" -c "${arc_resource_name}" -n "aks-secrets-provider" -t "connectedClusters" --extension-type "Microsoft.AzureKeyVaultSecretsProvider"

kubectl create clusterrolebinding current-user-binding --clusterrole cluster-admin --user="${cluster_admin_oid}" -o yaml

kubectl create serviceaccount cluster-admin-user-token -n default -o yaml

kubectl create clusterrolebinding cluster-admin-service-user-binding --clusterrole cluster-admin --serviceaccount default:cluster-admin-user-token -o yaml

@"
apiVersion: v1
kind: Secret
metadata:
  name: cluster-admin-service-user-secret
  annotations:
    kubernetes.io/service-account.name: cluster-admin-user-token
type: kubernetes.io/service-account-token
"@ | kubectl apply -f -

$TOKEN_DATA = kubectl get secret cluster-admin-service-user-secret -o jsonpath='{$.data.token}'
$TOKEN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($TOKEN_DATA))

az keyvault secret set -n az-connectedk8s-proxy --vault-name "${aio_kv_name}" --value "az connectedk8s proxy -g ${resource_group_name} -n ${arc_resource_name} --token $TOKEN"

# Create the AIO Namespace where AIO resources will be provisioned.
kubectl create namespace ${aio_cluster_namespace} -o yaml

# Add service principal client ID and client secret with Azure Key Vault Get/List permissions to
# a Secret and label it for the Azure Key Vault Secret Provider.
kubectl create secret generic ${aio_akv_sp_secret_name} --from-literal clientid="${aio_sp_client_id}" --from-literal clientsecret="${aio_sp_client_secret}" --namespace ${aio_cluster_namespace} -o yaml
  
kubectl label secret ${aio_akv_sp_secret_name} secrets-store.csi.k8s.io/used=true --namespace ${aio_cluster_namespace} -o yaml

# Apply the Secret that contains the tls.crt and tls.key for AIO.
@"
${aio_ca_cert_trust_secret}
"@ | kubectl apply -f -

# Apply the SecretProviderClass required for AIO.
@"
${aio_default_spc}
"@ | kubectl apply -f -

# Apply the ConfigMap that contains just the ca.crt (the tls.crt from above).
kubectl create cm ${aio_trust_config_map_name} --from-literal=ca.crt='${aio_ca_cert_pem}' --namespace ${aio_cluster_namespace} -o yaml

# Create MQTT Client service account
if (-not (kubectl get serviceaccounts -n azure-iot-operations | Select-String 'mqtt-client') )
{
  kubectl create serviceaccount mqtt-client -n azure-iot-operations
}

exit 0