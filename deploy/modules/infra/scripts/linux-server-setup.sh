#!/bin/bash
set -e

###
# The following steps condense down the quick start instructions for AIO:
# https://learn.microsoft.com/azure/iot-operations/get-started/quickstart-deploy?tabs=linux#connect-a-kubernetes-cluster-to-azure-arc
###

# Increase file handles and watches.
echo fs.inotify.max_user_instances=8192 | sudo tee -a /etc/sysctl.conf
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
echo fs.file-max = 100000 | sudo tee -a /etc/sysctl.conf

sudo sysctl -p

###
# Download and install Azure CLI and K3S.
###

sudo apt-get install -y curl

if [[ -n "$(hash az 2>&1)" ]];
then
# Install Azure CLI, used to connect new cluster to Azure Arc and enable Custom Location features.
echo "Starting install of Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash -s -- -y

# Update bash command cache for new `az` and `kubectl` commands.
hash -r
az config set extension.use_dynamic_install=yes_without_prompt

echo "Finished install of Azure CLI..."
fi

# Required for PersistentVolumeClaims in k3s.
sudo apt-get install -y nfs-common
#sudo apt-get install nfs-common || true

if [[ -n "$(hash k3s 2>&1)" ]];
then
# Providing the Public IP as a SAN if direct kubectl access from outside host machine is required.
# Refer to: https://github.com/k3s-io/k3s/issues/1381
# Makes it easier to copy the k3s.yaml to your ~/.kube/config file and have kubectl work.
# sudo KUBECONFIG=~/.kube/config:/etc/rancher/k3s/k3s.yaml kubectl config view --flatten
echo "Starting install of k3s..."
curl -sfL https://get.k3s.io | sudo sh -s -

# Update bash command cache for new `az` and `kubectl` commands.
hash -r
echo "Finished install of k3s..."
fi

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Add Az extension
az extension add --upgrade --name azure-iot-ops
az extension add --name connectedk8s

# Login using a service principal with the following roles:
# - "Kubernetes Cluster - Azure Arc Onboarding"
# - "Kubernetes Extension Contributor"
az login --service-principal --tenant "${tenant_id}" --username "${aio_onboard_sp_client_id}" -p="${aio_onboard_sp_client_secret}"
az account set --subscription "${subscription_id}"

if [[ "$(az connectedk8s list -g "${resource_group_name}" --query 'contains([].name, `${arc_resource_name}`)' -o json)" != "true" ]];
then
# Connect the cluster to Azure Arc.
az connectedk8s connect -l "${location}" -g "${resource_group_name}" -n "${arc_resource_name}"
fi

# Enable Custom Locations feature.
az connectedk8s enable-features -g "${resource_group_name}" -n "${arc_resource_name}" --custom-locations-oid "${custom_locations_oid}" --features cluster-connect custom-locations

if [[ "$(az k8s-extension list -g "${resource_group_name}" -c "${arc_resource_name}" -t connectedClusters --query 'contains([].name, `aks-secrets-provider`)' -o json)" != "true" ]];
then
# Add Azure Key Vault Secrets Store CSI Driver
az k8s-extension create -g "${resource_group_name}" -c "${arc_resource_name}" -n "aks-secrets-provider" -t "connectedClusters" --extension-type "Microsoft.AzureKeyVaultSecretsProvider" 
fi

kubectl create clusterrolebinding current-user-binding \
  --clusterrole cluster-admin \
  --user="${cluster_admin_oid}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create serviceaccount cluster-admin-user-token \
  -n default \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create clusterrolebinding cluster-admin-service-user-binding \
  --clusterrole cluster-admin \
  --serviceaccount default:cluster-admin-user-token \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cluster-admin-service-user-secret
  annotations:
    kubernetes.io/service-account.name: cluster-admin-user-token
type: kubernetes.io/service-account-token
EOF

TOKEN=$(kubectl get secret cluster-admin-service-user-secret -o jsonpath='{$.data.token}' | base64 -d | tr -d '\n')

az keyvault secret set -n az-connectedk8s-proxy \
  --vault-name "${aio_kv_name}" \
  --value "az connectedk8s proxy -g ${resource_group_name} -n ${arc_resource_name} --token $TOKEN"

# Create the AIO Namespace where AIO resources will be provisioned.
kubectl create namespace ${aio_cluster_namespace} \
  --dry-run=client -o yaml | kubectl apply -f -

# Add service principal client ID and client secret with Azure Key Vault Get/List permissions to
# a Secret and label it for the Azure Key Vault Secret Provider.
kubectl create secret generic ${aio_akv_sp_secret_name} \
  --from-literal clientid="${aio_sp_client_id}" \
  --from-literal clientsecret="${aio_sp_client_secret}" \
  --namespace ${aio_cluster_namespace} \
  --dry-run=client -o yaml | kubectl apply -f -
  
kubectl label secret ${aio_akv_sp_secret_name} \
  secrets-store.csi.k8s.io/used=true \
  --namespace ${aio_cluster_namespace} \
  --dry-run=client -o yaml | kubectl apply -f -

# Apply the Secret that contains the tls.crt and tls.key for AIO.
kubectl apply -f - <<EOF
${aio_ca_cert_trust_secret}
EOF

# Apply the SecretProviderClass required for AIO.
kubectl apply -f - <<EOF
${aio_default_spc}
EOF

# Apply the ConfigMap that contains just the ca.crt (the tls.crt from above).
kubectl create cm ${aio_trust_config_map_name} \
  --from-literal=ca.crt='${aio_ca_cert_pem}' \
  --namespace ${aio_cluster_namespace} \
  --dry-run=client -o yaml | kubectl apply -f -

# Create service account for mqtt client
if kubectl get serviceaccounts -n azure-iot-operations | grep -q 'mqtt-client'; then
  echo "Service account mqtt-client exists"
else
  kubectl create serviceaccount mqtt-client -n azure-iot-operations
  echo "Service account mqtt-client created"
fi

exit 0