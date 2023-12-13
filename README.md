# Azure Edge Extensions AIO IaC Terraform

Infrastructure as Code (IaC) Terraform to install all Azure IoT Operations (AIO) components. Provides an optional infrastructure deployment that configures a Kubernetes cluster connected to Azure Arc. Each AIO component deployment is split out into separate Terraform deployment directories to make deploying a particular component (or all) of AIO easy, quick, and straightforward.

## Features

This project utilizes Terraform to do the following:

* (Optional) Provision an appropriately sized VM in Azure for Kubernetes and AIO.
* (Optional) Provision necessary service principals for onboarding Arc and Azure Key Vault Secrets Provider access in the cluster.
* (Optional) Creates self-signed certificates used within AIO.
* Install Azure IoT Orchistrator into the cluster.
* Install Azure IoT MQ into the cluster.
* Install Azure IoT Data Processor into the cluster.
* Install Azure IoT Akri agent into the cluster.
* Install Azure IoT OPC UA Broker into the cluster.
* Install Azure IoT Layered Network Management into the cluster.

## Getting Started

### Prerequisites

- (Windows) [WSL](https://learn.microsoft.com/windows/wsl/install) installed and setup.
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) available on the command line where this will be deployed.
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) available on the command line where this will be deployed.
- (Optional) Owner access to a Subscription to deploy the infrastructure.
- (Or) Owner access to a Resource Group with an existing cluster configured and connected to Azure Arc. 

### Quickstart

1. Generate a new ssh key to use with the new VM (replace the `<computer-username>` with the username that will be used for the VM):
    ```shell
    ssh-keygen -t rsa -b 4096 -C "<computer-username>" -f ~/.ssh/id_aio_rsa
    # Press enter twice unless you want a passphrase
    ```
2. Login to the AZ CLI:
    ```shell
    az login --tenant <tenant>.onmicrosoft.com
    ```
   - Make sure your subscription is the one that you would like to use: `az account show`.
   - Change to the subscription that you would like to use if needed:
     ```shell
     az account set -s <subscription-id>
     ```
3. Add a `root-<unique-name>.tfvars` file to the root of the [deploy](deploy) directory that contains the following (refer to [deploy/sample-aio.general.tfvars.example](deploy/sample-aio.general.tfvars.example) for an example):
    ```hcl
    // <project-root>/deploy/root-<unique-name>.tfvars

    name = "<unique-name>"
    location = "<location>"
    ```
4. Add a `<unique-name>.auto.tfvars` to the [deploy/1-infra](deploy/1-infra) directory that contains the following required variables (refer to the [deploy/sample-aio.auto.tfvars.example](deploy/1-infra/sample-aio.auto.tfvars.example) for an example):
    ```hcl
    // <project-root>/deploy/1-infra/<unique-name>.auto.tfvars

    vm_computer_name             = "<computer-name>"
    vm_username                  = "<computer-username>"
    vm_ssh_pub_key_file          = "~/.ssh/id_aio_rsa.pub"
    ```
5. From the [deploy/1-infra](deploy/1-infra) directory execute the following (the `<unique-name>.auto.tfvars` created earlier will automatically be applied):
   ```shell
   terraform init
   terraform apply -var-file="../root-<unique-name>.tfvars"
   ```
6. Repeat the same `terraform` commands for the [deploy/2-aio-full](deploy/2-aio-full) directory:
   ```shell
   terraform init
   terraform apply -var-file="../root-<unique-name>.tfvars"
   ```
   
## Deploying into Existing Cluster

It is possible to use this repository to deploy Azure IoT Operations to an existing Azure Arc enabled cluster in an existing Resource Group. Ensure your cluster is setup and configured with the following prerequisites before deploying Azure IoT Operations.

### Prerequisites

- An Azure Arc connected cluster in a Resource Group that meets the minimum requirements for Azure IoT Operations.
  - Follow these instructions to make sure the following [Connect a Kubernetes cluster to Azure Arc](https://learn.microsoft.com/azure/iot-operations/get-started/quickstart-deploy?tabs=linux#connect-a-kubernetes-cluster-to-azure-arc):
    - *user watch/instance limits* have been increased.
    - The cluster has been `az connectedk8s connect` connected to Azure.
    - The cluster has `az connectedk8s enable-features` enabled for `custom-locations`.
- All Azure Providers for Azure IoT Operations have been registered into your subscription.
- An Azure Key Vault in a Resource Group that has RBAC Authorization **disabled**.
- A placeholder secret in the Azure Key Vault.
- A Service Principal with access policies to `List` and `Get` Secrets on the Azure Key Vault with `user_impersonation` API permissions.
  - The following AZ CLI commands will create a new Service Principal and give it the API permissions.
    ```shell
    # Keep track of the clientId, clientSecret, subscriptionId, and tenantId
    az ad sp create-for-rbac -n <your-service-principal-name> --json-auth
    
    # Grant your new app registration 'user_impersonation' on AzureKeyVault
    # - AzureKeyVault is the well-known GUID cfa8b339-82a2-471a-a3c9-0fc0be7a4093
    # - user_impersonation for AzureKeyVault is the well-known GUID f53da476-18e3-4152-8e01-aec403e6edc0 
    az ad app permission add --id <clientId-from-above> --api cfa8b339-82a2-471a-a3c9-0fc0be7a4093 --api-permissions f53da476-18e3-4152-8e01-aec403e6edc0=Scope
    
    # Print out the new app registration Object ID
    OBJECTID=$(az ad app show --id <clientId-from-above> --query 'id' -o tsv)
    
    # Set the Azure Key Vault Access Policies for the new app registration
    az keyvault set-policy -n <key-vault-name> -g <resource-group-name> --object-id "$OBJECTID" --secret-permissions get list --key-permissions get list --certificate-permissions get list
    ```
- The Azure Key Vault Secret Provider Arc Extension installed into the cluster.
  ```shell
  az k8s-extension create -g <resource-group-name> -c <arc-cluster-name> -n "aks-secrets-provider" -t "connectedClusters" --extension-type "Microsoft.AzureKeyVaultSecretsProvider"
  ```
  
Refer to [deploy/1-infra/scripts](./deploy/1-infra/scripts) and [deploy/1-infra/manifests](./deploy/1-infra/manifests) for additional required Kubernetes objects that must be present in the cluster before Azure IoT Operations can be installed.

### Steps

1. Refer to the [Quickstart](#quickstart) for instructions on setting up the root `.tfvars` file.
2. Add a `<unique-name>.auto.tfvars` to [2-aio](./deploy/2-aio-full) directory that contains the following:
   1. The `resource_group_name` unless different from `rg-<name>`.
   2. The `arc_cluster_name` unless different from `arc-<name>`.
   3. The `key_vault_name` unless different from `kv-<name>`.
   4. Disable any AIO components that are not needed, as an example `enable_aio_layered_network = false`.
   5. Any additional settings, such as the TLS secret or SecretProviderClass name, that is different than any of the defaults specified.
3. Execute the `terraform` commands for the [deploy/2-aio-full](deploy/2-aio-full) directory:
   ```shell
   terraform init
   terraform apply -var-file="../root-<unique-name>.tfvars"
   ```
