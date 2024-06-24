variable "should_create_container_registry" {
  description = "Flag to create container registry"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the container registry"
  type        = string
}

variable "location" {
  description = "Azure region where the resources will be provisioned"
  type        = string
}


variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku" {
  description = "SKU of the container registry"
  type        = string
  default     = "Basic"
}