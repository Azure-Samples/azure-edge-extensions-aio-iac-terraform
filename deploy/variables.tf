variable "name" {
  description = "The unique primary name used when naming resources. (ex. 'test' makes 'rg-test' resource group)"
  type        = string
  nullable    = false
  validation {
    condition     = var.name != "sample-aio" && length(var.name) < 15 && can(regex("^[a-z0-9][a-z0-9-]{1,60}[a-z0-9]$", var.name))
    error_message = "Please update 'name' to a short, unique name, that only has lowercase letters, numbers, '-' hyphens."
  }
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "should_create_virtual_machine" {
  description = "(Optional) Create a virtual machine"
  type        = bool
  default     = false
}

variable "is_linux_server" {
  description = "The OS of the server."
  type        = bool
}

variable "should_create_storage_account"{ 
  description = "Creates a new Storage Account"
  type        = bool
  default     = false
}

variable "should_create_container_registry" {
  description = "Creates a new Container Registry"
  type        = bool
  default     = false
}

variable "should_use_event_hub" {
  description = "(Optional) Use Event Hub for AIO to send data to cloud"
  type        = bool
  default     = false
}

variable "should_use_event_grid" {
  description = "(Optional) Use Event Grid for AIO to send data to cloud"
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "(Optional) The size of the VM that will be deployed."
  type        = string
  default     = "Standard_D4_v4"
}

variable "vm_storage_account_type" {
  description = "(Optional) The OS Disk Storage Account Type."
  type        = string
  default     = "Standard_LRS"
}

variable "should_install_infra" {
  description = "(Optional) Installs the example VM infrastructure and configures Kubernetes cluster work with Azure IoT Operations. (Otherwise, 'true')"
  type        = bool
  default     = true
}

variable "should_install_aio" {
  description = "(Optional) Installs Azure IoT Operations into the configured Kubernetes cluster. (Otherwise, 'true')"
  type        = bool
  default     = true
}

variable "should_install_opc_plc_sim" {
  description = "(Optional) Installs OPC PLC Simulator into Azure IoT Operations. (Otherwise, 'true')"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "(Optional) The resource group name where the Azure Arc Cluster resource is located. (Otherwise, 'rg-<var.name>', only used when skipping infra install)"
  type        = string
  default     = null
}

variable "arc_cluster_name" {
  description = "(Optional) the Arc Cluster resource name. (Otherwise, 'arc-<var.name>', only used when skipping infra install)"
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "(Optional) the Azure Key Vault resource name. (Otherwise, 'kv-<var.name>', only used when skipping infra install)"
  type        = string
  default     = null
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