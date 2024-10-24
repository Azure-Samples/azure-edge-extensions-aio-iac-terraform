variable "postfix" {
  type        = string
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  nullable    = false
}

variable "owners_admin_object_ids" {
  type        = list(string)
  description = "The owners of the new Service Principals otherwise `data.azurerm_client_config.current.object_id` used."
  default     = null
  nullable    = true
}
