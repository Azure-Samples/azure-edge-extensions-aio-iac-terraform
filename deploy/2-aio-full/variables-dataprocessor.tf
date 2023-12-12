variable "enable_aio_dataprocessor" {
  description = "Enables Azure IoT Data Processor. (default: 'true')"
  type        = bool
  default     = true
}

variable "aio_dataprocessor_extension_version" {
  description = "The Azure IoT Data Processor Arc Extension version to install into the cluster."
  type        = string
  default     = "0.1.1-preview"
}

variable "aio_dataprocessor_extension_release_train" {
  description = "The Azure IoT Data Processor Arc Extension release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}

variable "aio_dataprocessor_reader_count" {
  description = "The number of AIO Data Processor Reader Workers."
  type        = number
  default     = 1
}

variable "aio_dataprocessor_runner_count" {
  description = "The number of AIO Data Processor Runner Workers."
  type        = number
  default     = 1
}

variable "aio_dataprocessor_message_store_count" {
  description = "The number of AIO Data Processor Message Stores."
  type        = number
  default     = 1
}
