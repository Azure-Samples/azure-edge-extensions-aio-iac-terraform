variable "should_create_storage_account" {
  description = "(Optional) Create a storage account"
  type        = bool
  default     = false
}

variable "should_create_storage_account_containers" {
  description = "(Optional) Create storage account containers"
  type        = bool
  default     = false
}

variable "name" {
  type = string
  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 24 && can(regex("^[a-z0-9][a-z0-9]{1,60}[a-z0-9]$", var.name))
    error_message = "Please update 'name' to a short, unique name, that only has lowercase letters, numbers."
  }
}

variable "resource_group_name" {
  type = string
}

variable "storage_account_tier" {
  type        = string
  default     = "Standard"
  description = "The tier that the storage account should be set to."
}

variable "storage_account_replication_type" {
  type        = string
  default     = "LRS"
  description = "The replication type that the storage account should be set to."
}

variable "containers" {
  type        = list(string)
  description = "The list of container names to be created"
  default     = []
}

variable "container_access_type" {
  type        = string
  description = "(Optional) The Access Level configured for this Container. Possible values are blob, container or private. Defaults to private"
  default     = "private"
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

variable "filesystems" {
  description = "List of Azure Storage Data Lake Gen2 filesystems to create"
  type        = list(string)
  default     = []
}
