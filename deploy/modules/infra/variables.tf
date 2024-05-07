variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "sample-aio" && length(var.name) <= 18 && can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.name))
    error_message = "Please update 'name' to a short, unique name, that only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "location" {
  type    = string
  description = "The Azure region that items should be provisioned in."
  default = "eastus2"
}

variable "aio_cluster_namespace" {
  description = "The namespace in the cluster where AIO resources will be deployed."
  type        = string
  default     = "azure-iot-operations"
}

variable "aio_placeholder_secret_value" {
  description = "(Optional) The value for the placeholder secret that will be used by AIO, can be anything. (Otherwise, random string)"
  type        = string
  default     = null
}

variable "should_create_aio_onboard_sp" {
  description = "Creates a new Service Principal with 'Kubernetes Cluster - Azure Arc Onboarding' and 'Kubernetes Extension Contributor' roles for onboarding the new cluster to Arc."
  type        = bool
  default     = true
}

variable "should_create_aio_sp" {
  description = "Creates a new Service Principal with 'Get' and 'List' permissions on Azure Key Vault for AIO to use in the cluster."
  type        = bool
  default     = true
}

variable "admin_object_id" {
  description = "(Optional) The Client ID that will have admin privileges to the new Kubernetes cluster and Azure Key Vault. (Otherwise, uses current logged in user)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_sp_onboard_client_id" {
  description = "(Optional) The Service Principal Client ID for onboarding the cluster to Arc. (Otherwise, creates new one)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_sp_onboard_client_secret" {
  description = "(Optional) The Service Principal Client Secret for onboarding the cluster to Arc. (Otherwise, creates new one)"
  type        = string
  default     = null
  sensitive   = true
  nullable    = true
}

variable "aio_sp_client_id" {
  description = "(Optional) The Service Principal Client ID for AIO to use with Azure Key Vault. (Otherwise, creates new one)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_sp_client_secret" {
  description = "(Optional) The Service Principal Client Secret for AIO to use with Azure Key Vault. (Otherwise, creates new one)"
  type        = string
  default     = null
  sensitive   = true
  nullable    = true
}

variable "aio_trust_secret_name" {
  description = "(Optional) The name of the Kubernetes TLS secret that has the CA cert and key. (Otherwise, 'secret-tls')"
  type        = string
  default     = "aio-ca-key-pair-test-only"
  nullable    = false
}

variable "aio_akv_sp_secret_name" {
  description = "(Optional) The name of the Secret that stores the Service Principal Client ID and Client Secret for the Azure Key Vault Secret Provider Extension. (Otherwise, 'aio-secrets-store-creds')"
  type        = string
  default     = "aio-akv-sp"
  nullable    = false
}

variable "aio_spc_name" {
  description = "(Optional) The name of the SecretProviderClass Kubernetes object that's required by AIO. (Otherwise, 'aio-default-spc')"
  type        = string
  default     = "aio-default-spc"
  nullable    = false
}

variable "aio_trust_config_map_name" {
  description = "(Optional) The name of the ConfigMap for CA. (Otherwise, 'aio-ca-trust-bundle-test-only')"
  type        = string
  default     = "aio-ca-trust-bundle-test-only"
  nullable    = false
}

variable "is_linux_server" {
  description = "Is the server a Linux server?"
  type        = bool
}
