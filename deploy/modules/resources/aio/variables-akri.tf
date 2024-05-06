variable "enable_aio_akri" {
  description = "Enables Azure IoT Akri. (default: 'true')"
  type        = bool
  default     = true
}

variable "aio_akri_extension_version" {
  description = "The Azure IoT Akri Arc Extension version to install into the cluster."
  type        = string
  default     = "0.2.1-preview"
}

variable "aio_akri_extension_release_train" {
  description = "The AIO Arc Extension release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}

variable "aio_akri_container_runtime_socket" {
  description = "(Optional) The default node path of the container runtime socket. The default is empty.\nIf it's empty, socket path is determined by param var.aio_akri_kubernetes_distro."
  type        = string
  default     = ""
}

variable "aio_akri_kubernetes_distro" {
  description = "(Optional) The Kubernetes distro to run AIO on. The default is k8s."
  type        = string
  default     = "k8s"
  validation {
    condition     = contains(["k3s", "k8s", "microk8s"], var.aio_akri_kubernetes_distro)
    error_message = "Currently only supports [k3s, k8s, microk8s] Kubernetes distros."
  }
}
