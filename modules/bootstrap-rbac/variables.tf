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
  type        = string
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group for the new resources."
  default     = null
}

variable "resource_group_id" {
  type        = string
  description = "The resource id of the resource group for the new resources."
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
