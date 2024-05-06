variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "sample-aio" && length(var.name) <= 18 && can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.name))
    error_message = "Please update 'name' to a short, unique name, that only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "aio_mq_broker_auth_non_tls_enabled" {
  description = "Flag to create a non-tls mq broker"
  type        = bool
  default     = false
}

variable "kubernetes_distro" {
  description = "(Optional) The Kubernetes distro to run AIO on. (Otherwise, 'k3s', the infra deploys k3s or AKS EE)"
  type        = string
  default     = "k3s"
  validation {
    condition     = contains(["k3s", "k8s", "microk8s"], var.kubernetes_distro)
    error_message = "Currently only supports [k3s, k8s, microk8s] Kubernetes distros."
  }
}