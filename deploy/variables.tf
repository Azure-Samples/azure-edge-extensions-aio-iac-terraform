variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "sample-aio" && length(var.name) < 15 && can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.name))
    error_message = "Please update 'name' to a short, unique name, that only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "location" {
  type    = string
  default = "westus3"
}

variable "vm_computer_name" {
  description = "The Computer Name for the VM."
  type        = string
  nullable    = false
}

variable "vm_username" {
  description = "The Username used to login to the VM."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.vm_username))
    error_message = "Please update 'vm_username' which only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "vm_ssh_pub_key_file" {
  description = "(Required for Linux VMs) The file path to the SSH public key."
  type        = string
  default     = null
}

variable "vm_size" {
  description = "(Optional) The size of the VM that will be deployed."
  type        = string
  default     = "Standard_D4_v4"
}

variable "vm_storage_account_type" {
  description = "(Optional) The OS Disk Storage Account Type."
  type        = string
  default     = "Standard_LRS"
}
