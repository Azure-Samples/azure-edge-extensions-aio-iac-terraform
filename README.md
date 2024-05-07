# Azure Edge Extensions AIO IaC Terraform

Infrastructure as Code (IaC) Terraform to install all Azure IoT Operations (AIO) components. Provides an optional infrastructure deployment that configures a Kubernetes cluster connected to Azure Arc. Includes Terraform module for deploying each part; Infra, Azure IoT Operations, and/or OPC PLC Simulator easy and reusable.

## Features

This project utilizes Terraform to do the following:

* (Optional) Provision an appropriately sized VM in Azure for Kubernetes and AIO.
* (Optional) Provision necessary service principals for onboarding Arc and Azure Key Vault Secrets Provider access in the cluster.
* (Optional) Creates self-signed certificates used within AIO.
* Install Azure IoT Orchestrator into the cluster.
* Install Azure IoT MQ into the cluster.
* Install Azure IoT Data Processor into the cluster.
* Install Azure IoT Akri agent into the cluster.
* Install Azure IoT OPC UA Broker into the cluster.
* Install Azure IoT Layered Network Management into the cluster.
* Install IoT OPC PLC Simulator managed through Terraform.

## Getting Started

### Prerequisites

- (Optionally for Windows) [WSL](https://learn.microsoft.com/windows/wsl/install) installed and setup.
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) available on the command line where this will be deployed.
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) available on the command line where this will be deployed.
- (Optional) Owner access to a Subscription to deploy the infrastructure.
  - (Or) Owner access to a Resource Group with an existing cluster configured and connected to Azure Arc. 

### Providers Registered

You may need to manually register the providers. This can be achieved by running the following Azure CLI commands from the command line (after `az login`):

```shell
az provider register -n "Microsoft.ExtendedLocation"
az provider register -n "Microsoft.Kubernetes"
az provider register -n "Microsoft.KubernetesConfiguration"
az provider register -n "Microsoft.IoTOperationsOrchestrator"
az provider register -n "Microsoft.IoTOperationsMQ"
az provider register -n "Microsoft.IoTOperationsDataProcessor"
az provider register -n "Microsoft.DeviceRegistry"

# Verify the providers are registered with the following commands
az provider show -n "Microsoft.ExtendedLocation" --query "registrationState"
az provider show -n "Microsoft.Kubernetes" --query "registrationState"
az provider show -n "Microsoft.KubernetesConfiguration" --query "registrationState"
az provider show -n "Microsoft.IoTOperationsOrchestrator" --query "registrationState"
az provider show -n "Microsoft.IoTOperationsMQ" --query "registrationState"
az provider show -n "Microsoft.IoTOperationsDataProcessor" --query "registrationState"
az provider show -n "Microsoft.DeviceRegistry" --query "registrationState"
```

### Quickstart

1. Login to the AZ CLI:
    ```shell
    az login --tenant <tenant>.onmicrosoft.com
    ```
   - Make sure your subscription is the one that you would like to use: `az account show`.
   - Change to the subscription that you would like to use if needed:
     ```shell
     az account set -s <subscription-id>
     ```
1. Add a `<unique-name>.auto.tfvars` file to the root of the [deploy](deploy) directory that contains the following (refer to [deploy/sample-aio.auto.tfvars.example](deploy/sample-aio.auto.tfvars.example) for an example):
    ```hcl
    // <project-root>/deploy/<unique-name>.auto.tfvars

    name     = "sample-aio"
    location = "westus3"

    should_create_virtual_machine = "<true/false>"
    is_linux_server               = "<true/false>"
    should_use_event_hub          = "<true/false>"
    ```
1. From the [deploy](deploy) directory execute the following (the `<unique-name>.auto.tfvars` created earlier will automatically be applied):
   ```shell
   terraform init
   terraform apply
   ```
   
## Deploying into an Existing Arc Connected Cluster

> NOTE: Follow these instructions if you want to skip deploying `infra` and are only wanting to use `aio-full` and/or `opc-plc-sim`.

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
  
Refer to [deploy/modules/infra/scripts](./deploy/modules/infra/scripts) and [deploy/modules/infra/manifests](./deploy/modules/infra/manifests) for additional required Kubernetes objects that must be present in the cluster before Azure IoT Operations can be installed.

### Steps

1. Refer to the [Quickstart](#quickstart) for instructions on setting up the root `.tfvars` file.
2. Update the new `<unique-name>.auto.tfvars` with the following (unless defaults were used):
   1. The `resource_group_name`.
   2. The `arc_cluster_name`.
   3. The `key_vault_name`.
3. Execute the `terraform` commands the same way in the [deploy](deploy) directory:
   ```shell
   terraform init
   terraform apply"
   ```

## Using Terraform Modules

It is possible to use the Terraform modules directly from this repository using the [module](https://developer.hashicorp.com/terraform/language/modules/syntax) primitive supported by HCL syntax.

An example of deploying just `aio-full` using Terraform from another repo would look like the following:

```hcl
module "aio_full" {
  source = "github.com/azure-samples/azure-edge-extensions-aio-iac-terraform//deploy/modules/aio-full"

  name     = var.name
  location = var.location
}
```

If you would like to lock the module on a particular tag that's possible by adding a `?ref=<tag>` version to the end of the `source` field.

```hcl
module "aio_full_with_tag" {
  source = "github.com/azure-samples/azure-edge-extensions-aio-iac-terraform//deploy/modules/aio-full?ref=0.1.4"

  name     = var.name
  location = var.location
}
```