variable "admin_object_id" {
  description = "The object id that will be given full permissions to key vault otherwise `data.azurerm_client_config.current.object_id`"
  type        = string
  default     = null
}

variable "admin_policy_creation_enabled" {
  type        = bool
  description = "Flag to determine if the key vault policies should be applied"
  default     = true
}

variable "aio_policy_creation_enabled" {
  type        = bool
  description = "Flag to determine if the key vault policies should be applied"
  default     = true
}

variable "aio_sp_object_id" {
  description = "The service principal object id for aio in the cluster."
  type        = string
  default     = null
}

variable "creation_enabled" {
  type        = bool
  description = "Whether or not the key vault should be created."
  default     = true
}

variable "location" {
  description = "The azure region where the resources will be provisioned."
  type        = string
}

variable "name" {
  description = "The name of the key vault otherwise `kv-{var.postfix}`"
  type        = string
  default     = null
}

variable "onboard_object_id" {
  description = "The object id that will be given set permissions to key vault otherwise `data.azurerm_client_config.current.object_id`"
  type        = string
  default     = null
}

variable "onboard_policy_creation_enabled" {
  type        = bool
  description = "Whether or not to create the access policy for the onboard object id."
  default     = true
}

variable "postfix" {
  type        = string
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  default     = null
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = null
}

variable "sku" {
  type        = string
  description = "The sku used on key vault creation."
  default     = "standard"
}

