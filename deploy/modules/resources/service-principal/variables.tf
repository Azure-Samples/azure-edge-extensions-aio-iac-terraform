
variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
}

variable "should_create_aio_akv_sp" {
  description = "Creates a new Service Principal with 'Get' and 'List' permissions on Azure Key Vault for AIO to use in the cluster."
  type        = bool
  default     = true
}

variable "should_create_aio_onboard_sp" {
  description = "Creates a new Service Principal with 'Kubernetes Cluster - Azure Arc Onboarding' and 'Kubernetes Extension Contributor' roles for onboarding the new cluster to Arc."
  type        = bool
  default     = true
}

variable "admin_object_id" {
  description = "(Optional) The Client ID that will have admin privileges to the new Kubernetes cluster and Azure Key Vault. (Otherwise, uses current logged in user)"
  type        = string
  default     = null
  nullable    = true
}

variable "key_vault_name_onboard" {
  description = "The name of the onboard Service Principal."
  type        = string
  default     = "kv-onboard-sp"
}

variable "key_vault_name_akv" {
  description = "The name of the AIO Service Principal."
  type        = string
  default     = "kv-aio-sp"
}