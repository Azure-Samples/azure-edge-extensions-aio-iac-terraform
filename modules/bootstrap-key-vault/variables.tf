variable "location" {
  description = "The azure region where the resources will be provisioned."
  type        = string
}

variable "name" {
  description = "The name of the key vault otherwise `kv-{var.postfix}`"
  type        = string
  default     = null
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

