variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "aio-smpl" && length(var.name) < 14
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

variable "aio_targets_main_version" {
  description = "The version of the Targets that's deployed using AIO."
  type        = string
  default     = "1.0.0"
}

variable "aio_mq_auth_sat_audience" {
  description = "The AIO MQ broker Service Account Token audience for authentication."
  type        = string
  default     = "aio-mq"
}

variable "aio_processor_reader_count" {
  description = "The number of AIO Data Processor Reader Workers."
  type        = number
  default     = 1
}

variable "aio_processor_runner_count" {
  description = "The number of AIO Data Processor Runner Workers."
  type        = number
  default     = 1
}

variable "aio_processor_message_store_count" {
  description = "The number of AIO Data Processor Message Stores."
  type        = number
  default     = 1
}

variable "aio_ca_cm_name" {
  description = "The name of the Kubernetes ConfigMap that has the CA cert."
  type        = string
  default     = "aio-ca-trust-bundle"
}