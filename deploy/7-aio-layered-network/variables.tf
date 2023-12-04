variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "sample-aio" && length(var.name) < 15
    error_message = "Please update 'name' to a short, unique name."
  }
}

variable "location" {
  type    = string
  default = "westus3"
}

variable "aio_extension_version" {
  description = "The AIO Arc Extension version to install into the cluster."
  type        = string
  default     = "0.1.0-preview"
}

variable "aio_extension_release_train" {
  description = "The AIO Arc Extension release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}

variable "aio_cluster_namespace" {
  description = "The namespace in the Arc Cluster where AIO resources will be installed."
  type        = string
  default     = "aio"
}