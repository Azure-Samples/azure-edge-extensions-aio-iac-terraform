variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
}

variable "location" {
  type    = string
  default = "westus3"
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

variable "should_register_azure_providers" {
  description = "Registers all AIO 'Microsoft.*' providers to the subscription. (Not needed if this was done previously)"
  type        = bool
  default     = true
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

variable "admin_object_id" {
  description = "The Client ID that will have admin privileges to the new Kubernetes cluster and Azure Key Vault. (Optional, use current logged in user)"
  type        = string
  default     = null
}

variable "aio_onboard_sp_client_id" {
  description = "The Service Principal Client ID for onboarding the cluster to Arc. (Optional, creates new one)"
  type        = string
  default     = null
}

variable "aio_onboard_sp_client_secret" {
  description = "The Service Principal Client Secret for onboarding the cluster to Arc. (Optional, create new one)"
  type        = string
  default     = null
  sensitive   = true
}

variable "aio_akv_sp_object_id" {
  description = "The Service Principal Object ID for AIO to use with Azure Key Vault. (Optional, creates new one)"
  type        = string
  default     = null
}

variable "aio_akv_sp_client_id" {
  description = "The Service Principal Client ID for AIO to use with Azure Key Vault. (Optional, creates new one)"
  type        = string
  default     = null
}

variable "aio_akv_sp_client_secret" {
  description = "The Service Principal Client Secret for AIO to use with Azure Key Vault. (Optional, creates new one)"
  type        = string
  default     = null
  sensitive   = true
}

variable "aio_cluster_namespace" {
  description = "The namespace in the cluster where AIO resources will be deployed."
  type        = string
  default     = "aio"
}

variable "aio_ca_secret_name" {
  description = "The name of the Kubernetes TLS secret that has the CA cert and key."
  type        = string
  default     = "secret-tls"
}

variable "aio_akv_sp_secret_name" {
  description = "The name of the Secret that stores the Service Principal Client ID and Client Secret for the Azure Key Vault Secret Provider Extension."
  type        = string
  default     = "aio-secrets-store-creds"
}

variable "aio_placeholder_secret_value" {
  description = "The value for the placeholder secret that will be used by AIO (can be anything)."
  type        = string
  nullable    = false
}

variable "vm_ssh_pub_key_file" {
  description = "The file path to the SSH public key. (Only for Linux VMs)"
  type        = string
  nullable    = false
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
}

variable "vm_password" {
  description = "The Password used to login to the VM. (Only for Windows VMs)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vnet_address_space" {
  description = "The VNET address space for the VM."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_space" {
  description = "The subnet address in the VNET for the VM."
  type        = string
  default     = "10.0.2.0/24"
}

variable "current_wan_ip" {
  description = "Current WAN IP address to allow list, if left blank then current IP will be determined."
  type        = string
  default     = null
}