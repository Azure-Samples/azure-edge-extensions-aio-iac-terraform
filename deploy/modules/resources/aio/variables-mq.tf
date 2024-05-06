variable "enable_aio_mq" {
  description = "Enables Azure IoT MQ. (default: 'true')"
  type        = bool
  default     = true
}

variable "aio_mq_extension_version" {
  description = "The Azure IoT MQ Arc Extension version to install into the cluster."
  type        = string
  default     = "0.3.0-preview"
}

variable "aio_mq_extension_release_train" {
  description = "The Azure IoT MQ Arc Extension release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}

variable "aio_mq_auth_sat_audience" {
  description = "The AIO MQ broker Service Account Token audience for authentication."
  type        = string
  default     = "aio-mq"
}

variable "aio_mq_mode" {
  description = "The AIO MQ mode that the broker will use (auto, distributed)."
  type        = string
  default     = "distributed"
  validation {
    condition     = contains(["auto", "distributed"], var.aio_mq_mode)
    error_message = "Allowed values: auto, distributed"
  }
}

variable "aio_mq_memory_profile" {
  description = "The AIO MQ memory profile that the broker will use (tiny, low, medium, high)."
  type        = string
  default     = "medium"
  validation {
    condition     = contains(["tiny", "low", "medium", "high"], var.aio_mq_memory_profile)
    error_message = "Allowed values: tiny, low, medium, high"
  }
}

variable "aio_mq_backend_partition_count" {
  description = "The number of AIO MQ backend partitions that the broker will use."
  type        = number
  default     = 2
}

variable "aio_mq_backend_worker_count" {
  description = "The number of AIO MQ backend workers that the broker will use."
  type        = number
  default     = 2
}

variable "aio_mq_backend_redundancy_factor_count" {
  description = "The factor of redundancy for the AIO MQ backend broker."
  type        = number
  default     = 2
}

variable "aio_mq_frontend_replica_count" {
  description = "The number of AIO MQ frontend replicas that the broker will use."
  type        = number
  default     = 2
}

variable "aio_mq_frontend_worker_count" {
  description = "The number of AIO MQ frontend workers that the broker will use."
  type        = number
  default     = 2
}

variable "aio_mq_diag_log_level" {
  description = "The log level for the AIO MQ diagnostics service."
  type        = string
  default     = "info"
}

variable "aio_mq_diag_log_format" {
  description = "The log format for the AIO MQ diagnostics service."
  type        = string
  default     = "text"
}

variable "aio_mq_broker_service_type" {
  description = "The AIO MQ broker Kubernetes Service type."
  type        = string
  default     = "clusterIp"
  validation {
    condition     = contains(["clusterIp", "loadBalancer", "nodePort"], var.aio_mq_broker_service_type)
    error_message = "Allowed values: clusterIp, loadBalancer, nodePort"
  }
}

variable "aio_mq_broker_frontend_server_name" {
  description = "The name of the AIO MQ broker frontend server."
  type        = string
  default     = "mq-dmqtt-frontend"
}

variable "aio_mq_broker_auth_non_tls_enabled" {
  description = "The flag to create a non-tls AIO MQ Broker."
  type        = bool
  default     = false
}