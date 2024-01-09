$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
Remove-Item .\AzureCLI.msi

az config set extension.use_dynamic_install=yes_without_prompt

az login --service-principal --tenant "${tenant_id}" --username "${aio_onboard_sp_client_id}" -p="${aio_onboard_sp_client_secret}"
az account set --subscription "${subscription_id}"

.\AksEdgeQuickStartForAio.ps1 -SubscriptionId "${subscription_id}" -TenantId "${tenant_id}" -Location "${location}" -ResourceGroupName "${resource_group_name}" -ClusterName "${arc_resource_name}"

###
# The next set of steps will setup the cluster for Azure IoT Operations.
###

# Give a provided service principal client ID `cluster-admin` privileges to update and modify the cluster.
# Note: This gives a service principal full access to do anything to the cluster. In a production scenario
# you would want to follow least privilege access and make sure anyone who needs admin permissions to the
# cluster has limited time as admin and follows approvals.
#
# Azure Arc RBAC at time of writing is in Preview but would be the recommend method of managing
# permissions in the future, https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/azure-rbac?tabs=AzureCLI%2Ckubernetes-latest
kubectl create clusterrolebinding current-user-binding `
  --clusterrole cluster-admin `
  --user="${cluster_admin_oid}" `
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create serviceaccount cluster-admin-user-token `
  -n default `
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create clusterrolebinding cluster-admin-service-user-binding `
  --clusterrole cluster-admin `
  --serviceaccount default:cluster-admin-user-token `
  --dry-run=client -o yaml | kubectl apply -f -

@"
apiVersion: v1
kind: Secret
metadata:
  name: cluster-admin-service-user-secret
  annotations:
    kubernetes.io/service-account.name: cluster-admin-user-token
type: kubernetes.io/service-account-token
"@ | kubectl apply -f -

$TOKEN = kubectl get secret cluster-admin-service-user-secret -o jsonpath='{$.data.token}' | 
         [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String) |
         Out-String | 
         ForEach-Object { $_.TrimEnd() }

az keyvault secret set -n az-connectedk8s-proxy `
  --vault-name "${aio_kv_name}" `
  --value "az connectedk8s proxy -g ${resource_group_name} -n ${arc_resource_name} --token $TOKEN"

# Create the AIO Namespace where AIO resources will be provisioned.
kubectl create namespace ${aio_cluster_namespace} `
  --dry-run=client -o yaml | kubectl apply -f -

# Add service principal client ID and client secret with Azure Key Vault Get/List permissions to
# a Secret and label it for the Azure Key Vault Secret Provider.
kubectl create secret generic ${aio_akv_sp_secret_name} `
  --from-literal clientid="${aio_sp_client_id}" `
  --from-literal clientsecret="${aio_sp_client_secret}" `
  --namespace ${aio_cluster_namespace} `
  --dry-run=client -o yaml | kubectl apply -f -
kubectl label secret ${aio_akv_sp_secret_name} `
  secrets-store.csi.k8s.io/used=true `
  --namespace ${aio_cluster_namespace} `
  --dry-run=client -o yaml | kubectl apply -f -

# Apply the Secret that contains the tls.crt and tls.key for AIO.
@"
${aio_ca_cert_trust_secret}
"@ | kubectl apply -f - 

# Apply the SecretProviderClass required for AIO.
@"
${aio_default_spc}
"@ | kubectl apply -f -

# Apply the ConfigMap that contains just the ca.crt (the tls.crt from above).
kubectl create cm aio-ca-trust-bundle `
  --from-literal=ca.crt='${aio_ca_cert_pem}' `
  --namespace ${aio_cluster_namespace} `
  --dry-run=client -o yaml | kubectl apply -f -

exit 0