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

variable "resource_group_name" {
  description = "(Optional) The resource group name where the Azure Arc Cluster resource is located. (Otherwise, 'rg-<var.name>')"
  type        = string
  default     = null
}

variable "arc_cluster_name" {
  description = "(Optional) the Arc Cluster resource name. (Otherwise, 'arc-<var.name>')"
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "(Optional) the Azure Key Vault resource name. (Otherwise, 'kv-<var.name>')"
  type        = string
  default     = null
}

variable "aio_extension_version" {
  description = "The AIO Arc Extension version to install into the cluster."
  type        = string
  default     = "0.4.0-preview"
}

variable "aio_observability_version" {
  description = "The AIO OTel observability version to install into the cluster."
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
  default     = "azure-iot-operations"
}

variable "aio_spc_name" {
  description = "(Optional) The name of the SecretProviderClass Kubernetes object that's required by AIO. (Otherwise, 'aio-default-spc')"
  type        = string
  default     = "aio-default-spc"
  nullable    = false
}

variable "aio_csi_secret_name" {
  description = "The name of the Secret for the CSI driver."
  type        = string
  default     = "aio-akv-sp"
}

variable "aio_trust_secret_name" {
  description = "The name of the Kubernetes TLS secret that has the CA cert and key."
  type        = string
  default     = "aio-ca-key-pair-test-only"
}

variable "aio_trust_config_map_name" {
  description = "The name of the Kubernetes ConfigMap that has the CA cert."
  type        = string
  default     = "aio-ca-trust-bundle-test-only"
}

variable "aio_trust_issuer_name" {
  description = "The name of the CA Issuer used by AIO."
  type        = string
  default     = "aio-ca-issuer"
}

variable "aio_targets_main_version" {
  description = "The version of the Targets that's deployed using AIO."
  type        = string
  default     = "1.0.0"
}
