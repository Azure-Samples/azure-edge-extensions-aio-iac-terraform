variable "bootstrap_key_vault_admin_policy_creation_enabled" {
  type        = bool
  description = "Flag to determine if the key vault policies should be applied"
  default     = true
}

variable "bootstrap_key_vault_aio_policy_creation_enabled" {
  type        = bool
  description = "Flag to determine if the key vault policies should be applied"
  default     = true
}

variable "bootstrap_key_vault_aio_sp_object_id" {
  description = "The service principal object id for aio in the cluster."
  type        = string
  default     = null
}

variable "bootstrap_key_vault_creation_enabled" {
  type        = bool
  description = "Whether or not the key vault should be created."
  default     = true
}

variable "bootstrap_key_vault_name" {
  description = "The name of the key vault otherwise `kv-{var.postfix}`"
  type        = string
  default     = null
}

variable "bootstrap_key_vault_onboard_object_id" {
  description = "The object id that will be given set permissions to key vault otherwise `data.azurerm_client_config.current.object_id`"
  type        = string
  default     = null
}

variable "bootstrap_key_vault_onboard_policy_creation_enabled" {
  type        = bool
  description = "Whether or not to create the access policy for the onboard object id."
  default     = true
}

variable "bootstrap_key_vault_resource_group_name" {
  description = "The name of the key vault resource group otherwise `var.resource_group_name`"
  type        = string
  default     = null
}

variable "bootstrap_key_vault_sku" {
  type        = string
  description = "The sku used on key vault creation."
  default     = "standard"
}
