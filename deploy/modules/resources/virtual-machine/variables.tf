variable "should_create_virtual_machine" {
  description = "(Optional) Create a virtual machine."
  type        = bool
  default     = false
}

variable "should_create_network" {
  description = "(Optional) Create a network."
  type        = bool
  default     = false
}

variable "name" {
  type        = string
  description = "Name of the virtual machine resource."
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type        = string
  description = "The Azure region that items should be provisioned in."
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

# variable "vm_ssh_pub_key_file" {
#   description = "(Required for Linux VMs) The file path to the SSH public key."
#   type        = string
#   default     = null
# }

variable "vm_password" {
  description = "The Password used to login to the VM."
  type        = string
  nullable    = false
}

variable "vm_size" {
  description = "(Optional) The size of the VM that will be deployed."
  type        = string
  default     = "Standard_D4_v4"
}

variable "should_allow_list_wan_ip" {
  description = "Creates NSG security rules based on current or provided WAN IP address."
  type        = bool
  default     = false
}

variable "should_allow_list_ssh_port" {
  description = "Creates NSG rule to allow WAN IP address to access port 22."
  type        = bool
  default     = false
}

variable "should_allow_list_kubectl_port" {
  description = "Creates NSG rule to allow WAN IP address to access port 6443."
  type        = bool
  default     = false
}

variable "current_wan_ip" {
  description = "(Optional) Current WAN IP address to allow list, if left blank then current WAN IP will be used. (Only needed when adding NSG security rules)"
  type        = string
  default     = null
}

variable "vm_setup_script" {
  description = "The script to run on the VM."
  type        = string
  nullable    = false
}

variable "vnet_address_space" {
  description = "(Optional) The VNET address space for the VM. (Otherwise, '10.0.0.0/16')"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_space" {
  description = "(Optional) The subnet address in the VNET for the VM. (Otherwise, '10.0.2.0/24')"
  type        = string
  default     = "10.0.2.0/24"
}
