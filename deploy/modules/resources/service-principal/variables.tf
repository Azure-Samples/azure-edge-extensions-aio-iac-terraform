
variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
}

variable "should_create_onboard_sp" {
  description = "Creates a new Service Principal with 'Kubernetes Cluster - Azure Arc Onboarding' and 'Kubernetes Extension Contributor' roles for onboarding the new cluster to Arc."
  type        = bool
  default     = true
}

variable "should_create_sp" {
  description = "Creates a new Service Principal with 'Get' and 'List' permissions on Azure Key Vault for AIO to use in the cluster."
  type        = bool
  default     = true
}

variable "should_create_onboard_sp_secret"{
  description = "Creates a new RBAC secret for the AIO Onboarding Service Principal."
  type        = bool
  default     = true
}

variable "should_create_sp_secret"{
  description = "Creates a new RBAC secret for the AIO Service Principal."
  type        = bool
  default     = true
}

variable "admin_object_id" {
  description = "(Optional) The Client ID that will have admin privileges to the new Kubernetes cluster and Azure Key Vault. (Otherwise, uses current logged in user)"
  type        = string
  default     = null
  nullable    = true
}

variable "sp_onboard_client_id" {
  description = "The name of the Azure Key Vault to create the onboard SP secret in."
  type        = string
  default     = null
}

variable "sp_client_id" {
  description = "The name of the Azure Key Vault to create the SP secret in."
  type        = string
  default     = null
}
