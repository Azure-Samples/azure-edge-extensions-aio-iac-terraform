variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "sample-aio" && length(var.name) < 15
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

variable "should_simulate_plc" {
  description = "Enables the OPC UA Broker PLC simulator. (Note: If deploying 8-opc-plc-sim then leave this as 'false' otherwise there will be multiple OPC PLC Simulators)"
  type        = bool
  default     = false
}

variable "aio_ca_cm_name" {
  description = "The trust bundle ConfigMap name."
  type        = string
  default     = "aio-ca-trust-bundle"
}

variable "aio_ca_cm_cert_name" {
  description = "The name of the cert in the trust bundle ConfigMap."
  type        = string
  default     = "ca.crt"
}

variable "aio_csi_secret_name" {
  description = "The name of the Secret for the CSI driver."
  type        = string
  default     = "aio-secrets-store-creds"
}

variable "aio_mq_auth_sat_audience" {
  description = "The AIO MQ broker Service Account Token audience for authentication."
  type        = string
  default     = "aio-mq"
}

variable "aio_mq_frontend_server" {
  description = "The AIO MQ Listener frontend service name. (Currently hardcoded in preview)"
  type        = string
  default     = "aio-mq-dmqtt-frontend"
}