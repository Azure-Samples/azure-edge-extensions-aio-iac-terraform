variable "admin_password" {
  description = "The password used to log in to the vm."
  type        = string
  default     = null
}

variable "admin_password_creation_enabled" {
  type        = bool
  description = "Whether to create the admin password for the vm."
  default     = false
}

variable "admin_username" {
  description = "The admin username used to log in to the vm."
  type        = string
  default     = "azureuser"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.admin_username))
    error_message = "Please update 'admin_username' which only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "computer_name" {
  type        = string
  description = "The name of the virtual machine resource otherwise `vm-{var.postfix}`."
  default     = null
}

variable "key_vault_id" {
  type        = string
  description = "The key vault id that will have the admin password after generation."
  default     = null
}

variable "location" {
  type        = string
  description = "The azure region that resources should be provisioned in."
}

variable "network_creation_enabled" {
  type        = bool
  description = "Whether to create the vnet, subnet, and ip"
  default     = true
}

variable "postfix" {
  type        = string
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that will have the new resources."
}

variable "setup_script" {
  description = "The script to run on the vm."
  type        = string
  default     = null
}

variable "setup_script_enabled" {
  type        = bool
  description = "Whether to install an extension that will run the script on the vm (only supports linux)."
  default     = false
}

variable "size" {
  description = "(Optional) The size of the VM that will be deployed."
  type        = string
  default     = "Standard_D4_v4"
}

variable "subnet_address_space" {
  description = "(Optional) The subnet address in the VNET for the VM. (Otherwise, '10.0.2.0/24')"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vnet_address_space" {
  description = "(Optional) The VNET address space for the VM. (Otherwise, '10.0.0.0/16')"
  type        = string
  default     = "10.0.0.0/16"
}

