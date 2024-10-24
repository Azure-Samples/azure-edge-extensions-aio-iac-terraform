variable "location" {
  type        = string
  description = "The location where to deploy the new resources."
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