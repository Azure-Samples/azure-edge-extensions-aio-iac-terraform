variable "enable_aio_dataprocessor" {
  description = "Enables Azure IoT Data Processor. (default: 'true')"
  type        = bool
  default     = true
}

variable "aio_dataprocessor_extension_version" {
  description = "The Azure IoT Data Processor Arc Extension version to install into the cluster."
  type        = string
  default     = "0.2.0-preview"
}

variable "aio_dataprocessor_extension_release_train" {
  description = "The Azure IoT Data Processor Arc Extension release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}