variable "should_create_storage_account"{ 
  description = "Creates a new Storage Account"
  type        = bool
  default     = false
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