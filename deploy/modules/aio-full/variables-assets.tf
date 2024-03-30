variable "enable_aio_assets" {
  description = "Enables Azure IoT Assets. (default: 'true')"
  type        = bool
  default     = true
}

variable "aio_assets_extension_version" {
  description = "The Azure IoT Assets Arc Extension version to install into the cluster."
  type        = string
  default     = "0.1.0-preview"
}

variable "aio_assets_extension_release_train" {
  description = "The Azure IoT Assets Arc Extension release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}
