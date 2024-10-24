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
