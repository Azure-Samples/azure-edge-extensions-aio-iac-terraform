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
2. Login to the AZ CLI, `az login --tenant <tenant>.onmicrosoft.com`.
3. Add a <name>.tfvars to the [deploy](deploy) directory that contains the following (replace `<unique-name>` and `<location>` with a name used by the resources and a location of where to deploy the resources):
    ```hcl
    name = "<unique-name>"
    location = "<location>"
    ```
4. Add a <name>.auto.tfvars to the [deploy](deploy/1-infra) directory that contains the following required variables (replace the values with your own values):
    ```hcl
    vm_computer_name             = "<computer-name>"
    vm_username                  = "<computer-username>"
    vm_ssh_pub_key_file          = "~/.ssh/<generated-public-ssh-key>.pub"
    aio_placeholder_secret_value = "<placeholder-secret-value"
    ```
5. From the [deploy/1-infra](deploy/1-infra) directory execute `terraform init` to pull down the latest Terraform providers.
   ```shell
   terraform init
   ```
6. From the [deploy/1-infra](deploy/1-infra) directory apply the terraform (the `<name>.auto.tfvars` will automatically be applied, you will still need to reference the `<name>.tfvars` file directly):
    ```shell
    terraform apply -var-file="../<name>.tfvars"
    ```
7. Repeat the same process for each of the additional *deploy/* directories, as an example, navigate to [deploy/2-aio-orchestrator](deploy/2-aio-orchestrator) and execute:
    ```shell
    terraform apply -var-file="../<name>.tfvars"
    ```