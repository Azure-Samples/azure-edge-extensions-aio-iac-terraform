variable "should_create_resource_group" {
  type        = bool
  description = "Flag to determine if the resource group should be created"
  default     = false
}

variable "name" {
  description = "The name of the resource group to create."
  type = string
}

variable "resource_group_name" {
  description = "The name of the existing resource group."
  type        = string
}

variable "location" {
  type        = string
  description = "The Azure region that items should be provisioned in."
}

variable "tags" {
  description = "The list of default tags to apply to a given resource"
  type        = map(string)
  default     = {}
}
