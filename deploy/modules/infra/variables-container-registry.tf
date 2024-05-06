variable "should_create_container_registry" {
  description = "Creates a new Container Registry"
  type        = bool
  default     = false
}

variable "container_registry_sku" {
  type        = string
  description = "The SKU of the container registry"
  default     = "Basic"
}