variable "enable_aio_akri" {
  description = "Enables Azure IoT Akri. (default: 'true')"
  type        = bool
  default     = true
}

variable "aio_akri_extension_version" {
  description = "The Azure IoT Akri Arc Extension version to install into the cluster."
  type        = string
  default     = "0.1.0-preview"
}

variable "aio_akri_extension_release_train" {
  description = "The AIO Arc Extension release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}
