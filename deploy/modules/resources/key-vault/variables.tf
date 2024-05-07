variable "should_create_key_vault" {
  type        = bool
  description = "Flag to determine if the resource group should be created"
  default     = false
}

variable "should_create_key_vault_policies" {
  type        = bool
  description = "Flag to determine if the key vault policies should be applied"
  default     = false
}

variable "name" {
  description = "Name of the key vault"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the existing key vault"
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the resources will be provisioned"
  type        = string
}

variable "admin_object_id" {
  description = "(Optional) The Client ID that will have admin privileges to the new Kubernetes cluster and Azure Key Vault. (Otherwise, uses current logged in user)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_placeholder_secret_value" {
  description = "(Optional) The value for the placeholder secret that will be used by AIO, can be anything. (Otherwise, random string)"
  type        = string
  default     = null
  nullable    = true
}

variable "aio_sp_object_id" {
  description = "(Optional) The value for the service principal object id that will be used by AIO, can be anything. (Otherwise, random string)"
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
