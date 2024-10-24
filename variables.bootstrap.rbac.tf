variable "bootstrap_rbac_admin_role_assignment_enabled" {
  type        = bool
  description = "Whether to create the role assignment for key vault secrets officer role to the admin object id."
  default     = true
}

variable "bootstrap_rbac_creation_enabled" {
  type        = bool
  description = "Whether to create role assignments."
  default     = true
}

variable "bootstrap_rbac_secret_sync_msi_name" {
  type        = string
  description = "The name for the managed identity that will be created for the secret sync controller in the cluster."
  default     = null
}

variable "bootstrap_rbac_secret_sync_msi_creation_enabled" {
  type        = bool
  description = "Whether to create the managed identity for the secret sync controller."
  default     = true
}