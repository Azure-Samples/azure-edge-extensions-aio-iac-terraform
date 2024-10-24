variable "bootstrap_service_principal_creation_enabled" {
  type        = bool
  description = "Whether or not to create new Service Principals"
  default     = true
}

variable "bootstrap_service_principal_onboard_sp_creation_enabled" {
  type        = bool
  description = <<-DESCRIPTION
  Whether or not to create a new Service Principal scoped to RG and with roles: 
  - 'Kubernetes Cluster - Azure Arc Onboarding'
  - 'Kubernetes Extension Contributor'"
  
  Used for onboarding the new cluster to Arc.
  DESCRIPTION
  default     = true
}

variable "bootstrap_service_principal_aio_sp_creation_enabled" {
  type        = bool
  description = <<-DESCRIPTION
  Whether or not to create a new Service Principals with: 
  - 'Get' and 'List' permissions on Azure Key Vault

  Needed by AIO to access AKV.
  DESCRIPTION
  default     = true
}

variable "bootstrap_service_principal_owners_admin_object_id" {
  type        = string
  description = "The owners of the new Service Principals otherwise `data.azurerm_client_config.current.object_id` used."
  default     = null
  nullable    = true
}