variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "sample-aio" && length(var.name) < 15 && can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.name))
    error_message = "Please update 'name' to a short, unique name, that only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "location" {
  type    = string
  default = "westus3"
}

variable "aio_cluster_namespace" {
  description = "The namespace in the cluster where AIO resources will be deployed."
  type        = string
  default     = "aio"
}

variable "aio_placeholder_secret_value" {
  description = "(Optional) The value for the placeholder secret that will be used by AIO, can be anything. (Otherwise, random string)"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "(Optional) The name of the Resource Group where all resources will be created. (If left blank, will use rg-<var.name>)"
  type        = string
  default     = null
  nullable    = true
}

variable "should_create_resource_group" {
  description = "Create and manage the Resource Group or use an existing Resource Group."
  type        = bool
  default     = true
}

variable "should_use_linux" {
  description = "Deploy a Linux VM or Windows VM"
  type        = bool
  default     = true

  validation {
    condition     = var.should_use_linux == true
    error_message = "Windows has not been implemented in Terraform just yet."
  }
}

variable "should_allow_list_wan_ip" {
  description = "Creates NSG security rules based on current or provided WAN IP address."
  type        = bool
  default     = false
}

variable "should_allow_list_ssh_port" {
  description = "Creates NSG rule to allow WAN IP address to access port 22."
  type        = bool
  default     = false
}

variable "should_allow_list_kubectl_port" {
  description = "Creates NSG rule to allow WAN IP address to access port 6443."
  type        = bool
  default     = false
}

variable "should_allow_list_rdp_port" {
  description = "Creates NSG rule to allow WAN IP address to access port 3389."
  type        = bool
  default     = false
}

variable "should_create_aio_onboard_sp" {
  description = "Creates a new Service Principal with 'Kubernetes Cluster - Azure Arc Onboarding' and 'Kubernetes Extension Contributor' roles for onboarding the new cluster to Arc."
  type        = bool
  default     = true
}

variable "should_create_aio_akv_sp" {
  description = "Creates a new Service Principal with 'Get' and 'List' permissions on Azure Key Vault for AIO to use in the cluster."
  type        = bool
  default     = true
}

variable "should_create_aio_resource_provider_register_role" {
  description = "Creates a new role that has permissions to register all of the AIO resources."
  type        = bool
  default     = true
}

variable "aio_resource_provider_register_role_name" {
  description = "(Optional) The name for the role that has permissions to register all of the AIO resources."
  type        = string
  default     = null
}

variable "vm_computer_name" {
  description = "The Computer Name for the VM."
  type        = string
  nullable    = false
}

variable "vm_username" {
  description = "The Username used to login to the VM."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.vm_username))
    error_message = "Please update 'vm_username' which only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "vm_ssh_pub_key_file" {
  description = "(Required for Linux VMs) The file path to the SSH public key."
  type        = string
  default     = null
}

variable "vm_password" {
  description = "(Required for Windows VMs) The Password used to login to the VM."
  type        = string
  default     = ""
  sensitive   = true
}

variable "vm_size" {
  description = "(Optional) The size of the VM that will be deployed."
  type        = string
  default     = "Standard_D4_v4"
}

variable "admin_object_id" {
  description = "(Optional) The Client ID that will have admin privileges to the new Kubernetes cluster and Azure Key Vault. (Otherwise, uses current logged in user)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_onboard_sp_object_id" {
  description = "(Optional) The Service Principal Object ID for onboarding the cluster to Arc. (Otherwise, creates new one)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_onboard_sp_client_id" {
  description = "(Optional) The Service Principal Client ID for onboarding the cluster to Arc. (Otherwise, creates new one)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_onboard_sp_client_secret" {
  description = "(Optional) The Service Principal Client Secret for onboarding the cluster to Arc. (Otherwise, creates new one)"
  type        = string
  default     = null
  sensitive   = true
  nullable    = true
}

variable "aio_akv_sp_object_id" {
  description = "(Optional) The Service Principal Object ID for AIO to use with Azure Key Vault. (Otherwise, creates new one)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_akv_sp_client_id" {
  description = "(Optional) The Service Principal Client ID for AIO to use with Azure Key Vault. (Otherwise, creates new one)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_akv_sp_client_secret" {
  description = "(Optional) The Service Principal Client Secret for AIO to use with Azure Key Vault. (Otherwise, creates new one)"
  type        = string
  default     = null
  sensitive   = true
  nullable    = true
}

variable "aio_ca_secret_name" {
  description = "(Optional) The name of the Kubernetes TLS secret that has the CA cert and key. (Otherwise, 'secret-tls')"
  type        = string
  default     = "secret-tls"
  nullable    = false
}

variable "aio_akv_sp_secret_name" {
  description = "(Optional) The name of the Secret that stores the Service Principal Client ID and Client Secret for the Azure Key Vault Secret Provider Extension. (Otherwise, 'aio-secrets-store-creds')"
  type        = string
  default     = "aio-secrets-store-creds"
  nullable    = false
}

variable "aio_spc_name" {
  description = "(Optional) The name of the SecretProviderClass Kubernetes object that's required by AIO. (Otherwise, 'aio-default-spc')"
  type        = string
  default     = "aio-default-spc"
  nullable    = false
}

variable "vnet_address_space" {
  description = "(Optional) The VNET address space for the VM. (Otherwise, '10.0.0.0/16')"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_space" {
  description = "(Optional) The subnet address in the VNET for the VM. (Otherwise, '10.0.2.0/24')"
  type        = string
  default     = "10.0.2.0/24"
}

variable "current_wan_ip" {
  description = "(Optional) Current WAN IP address to allow list, if left blank then current WAN IP will be used. (Only needed when adding NSG security rules)"
  type        = string
  default     = null
}