variable "enable_aio_layered_network" {
  description = "Enables Azure IoT Layered Network Management. (default: 'true')"
  type        = bool
  default     = true
}

variable "aio_layered_network_extension_version" {
  description = "The Azure IoT Layered Network Management Arc Extension version to install into the cluster."
  type        = string
  default     = "0.1.0-preview"
}

variable "aio_layered_network_extension_release_train" {
  description = "The Azure IoT Layered Network Management Arc Extension release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}
