variable "bootstrap_enabled" {
  type        = bool
  description = "Whether to bootstrap AIO with a VM, Key Vault, and/or Service Principals."
  default     = true
}

variable "bootstrap_admin_object_id" {
  description = "The object id that will be given full permissions to key vault otherwise `data.azurerm_client_config.current.object_id`"
  type        = string
  default     = null
}

variable "bootstrap_aio_sp_object_id" {
  type        = string
  description = "The service principal object id for aio in cluster."
  default     = null
}

variable "bootstrap_aio_sp_client_id" {
  type        = string
  description = "The service principal client id for aio in cluster."
  default     = null
}

variable "bootstrap_aio_sp_application_password" {
  type        = string
  description = "The service principal secret for aio in cluster."
  default     = null
  sensitive   = true
}

variable "bootstrap_arc_resource_name" {
  type        = string
  description = "The name for the new arc cluster resource otherwise `arc-{var.postfix}`"
  default     = null
}

variable "bootstrap_onboard_sp_object_id" {
  type        = string
  description = "The service principal object id for onboarding cluster with arc."
  default     = null
}

variable "bootstrap_onboard_sp_client_id" {
  type        = string
  description = "The service principal client id for onboarding cluster with arc."
  default     = null
}

variable "bootstrap_onboard_sp_application_password" {
  type        = string
  description = "The service principal secret for onboarding cluster with arc."
  default     = null
  sensitive   = true
}

variable "bootstrap_output_server_setup_script_enabled" {
  type        = string
  description = "Whether to output the server setup script that will need to be ran on the server that will have AIO."
  default     = true
}

variable "bootstrap_output_server_setup_script_path" {
  type        = string
  description = "The file path on your computer where the server setup script will be output."
  default     = "./out/server-setup-script.sh"
}

variable "location" {
  type        = string
  description = "The location where to deploy the new resources."
  default     = "eastus2"
}

variable "postfix" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = length(var.postfix) < 15 && can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.postfix))
    error_message = "Please update 'postfix' to a short, unique name, that only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group for the new resources otherwise `rg-{var.postfix}."
  default     = null
}

variable "resource_group_creation_enabled" {
  type        = bool
  description = "Whether to create the resource group."
  default     = true
}