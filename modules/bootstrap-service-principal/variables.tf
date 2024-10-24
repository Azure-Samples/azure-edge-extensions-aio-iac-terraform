variable "postfix" {
  type        = string
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  nullable    = false
}

variable "onboard_sp_creation_enabled" {
  type        = bool
  description = <<-DESCRIPTION
  Whether or not to create a new Service Principal scoped to RG and with roles: 
  - 'Kubernetes Cluster - Azure Arc Onboarding'
  - 'Kubernetes Extension Contributor'"
  
  Used for onboarding the new cluster to Arc.
  DESCRIPTION
  default     = true
}

variable "owners_admin_object_ids" {
  type        = list(string)
  description = "The owners of the new Service Principals otherwise `data.azurerm_client_config.current.object_id` used."
  default     = null
  nullable    = true
}
