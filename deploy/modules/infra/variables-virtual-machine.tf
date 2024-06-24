variable "should_create_virtual_machine" {
  description = "(Optional) Create a virtual machine"
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "(Optional) The size of the VM that will be deployed."
  type        = string
  default     = "Standard_D4_v4"
}
