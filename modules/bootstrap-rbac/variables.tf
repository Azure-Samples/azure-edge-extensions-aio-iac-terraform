variable "admin_object_id" {
  type        = string
  description = "The object id of the admin that will have key vault secrets access."
  default     = null
}

variable "admin_role_assignment_enabled" {
  type        = bool
  description = "Whether to create the role assignment for key vault secrets officer role to the admin object id."
  default     = true
}

variable "location" {
  type        = string
  description = "The location for the new resources."
}

variable "key_vault_id" {
  type        = string
  description = "The azure key vault id that will scope the key vault secrets officer."
  default     = null
}

variable "onboard_sp_object_id" {
  type        = string
  description = "The service principal object id for onboarding cluster with arc."
  default     = null
}

variable "postfix" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = length(var.postfix) < 15 && can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.postfix))
    error_message = "Please update 'postfix' to a short, unique name, that only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group for the new resources otherwise `rg-{var.postfix}."
  default     = null
}

variable "secret_sync_msi_name" {
  type        = string
  description = "The name for the managed identity that will be created for the secret sync controller in the cluster."
  default     = null
}

variable "secret_sync_msi_creation_enabled" {
  type        = bool
  description = "Whether to create the managed identity for the secret sync controller."
  default     = true
}
