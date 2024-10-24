variable "onboard_sp_object_id" {
  type        = string
  description = "The service principal object id for onboarding cluster with arc."
  default     = null
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
