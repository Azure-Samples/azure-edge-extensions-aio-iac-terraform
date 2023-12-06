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

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) available on the command line where this will be deployed.
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) available on the command line where this will be deployed.
- (Optional) Owner access to a Subscription to deploy the infrastructure.
- (Or) Owner access to a Resource Group with an existing cluster configured and connected to Azure Arc. 

### Quickstart

1. Generate a new ssh key to use with the new VM (replace the `<computer-username>` with the username that will be used for the VM):
    ```shell
    ssh-keygen -t rsa -b 4096 -C "<computer-username>"
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
    vm_ssh_pub_key_file          = "~/.ssh/<generated-public-ssh-key>.pub"
    aio_placeholder_secret_value = "<placeholder-secret-value"
    ```
5. For each Azure IoT Operations component directory under `deploy`, execute the following commands in order (using `deploy/1-infra` as an example):
   1. From the [deploy/1-infra](deploy/1-infra) directory execute `terraform init` to pull down the latest Terraform providers.
      ```shell
      terraform init
      ```
   2. From the [deploy/1-infra](deploy/1-infra) directory apply the terraform (the `<unique-name>.auto.tfvars` will automatically be applied):
       ```shell
       terraform apply -var-file="../root-<unique-name>.tfvars"
       ```
6. Repeat the same process for each of the additional `deploy` directories, as an example, navigate to [deploy/2-aio-orchestrator](deploy/2-aio-orchestrator) and execute:
    ```shell
    terraform init -var-file="../root-<unique-name>.tfvars"
    terraform apply -var-file="../root-<unique-name>.tfvars"
    ```