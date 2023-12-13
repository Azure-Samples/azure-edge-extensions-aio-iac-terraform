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
  default = "westus3"
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

variable "custom_locations_name" {
  description = "(Optional) the Custom Locations resource name. (Otherwise, 'cl-<var.name>-aio')"
  type        = string
  default     = null
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

variable "should_install_opc_plc_simulator" {
  description = "Sets up the OPC PLC Simulator if needed. (`opcPlcSimulation.deploy = false` on the OPC UA Broker)"
  type        = bool
  default     = true
}

variable "should_install_insecure_mqtt_client_for_mqttui" {
  description = "Sets up a Deployment that contains mqttui for the purpose of debugging MQTT messages in the cluster."
  type        = bool
  default     = true
}

variable "opc_plc_sim_server_name" {
  description = "The name of the OPC PLC Simulator Service and Pod."
  type        = string
  default     = "opcplc-sim"
}

variable "opc_plc_sim_image_version" {
  description = "The version of the OPC PLC Simulator image."
  type        = string
  default     = "2.9.10"
}

variable "aio_mq_auth_sat_audience" {
  description = "The AIO MQ broker Service Account Token audience for authentication."
  type        = string
  default     = "aio-mq"
}

variable "aio_ca_cm_name" {
  description = "The trust bundle ConfigMap name."
  type        = string
  default     = "aio-ca-trust-bundle"
}

variable "opc_sim_endpoint_name" {
  description = "The name of the Asset Endpoint Profile for the OPC PLC Simulator."
  type        = string
  default     = "opc-sim-connector"
}

variable "opc_sim_asset_name" {
  description = "The name of the OPC PLC Simulator Asset."
  type        = string
  default     = "thermostat"
}

variable "opc_sim_asset_defaults" {
  description = "The publishing, sampling, and queue size defaults for the OPC PLC Simulator Asset."
  type = object({
    publishingInterval = number
    samplingInterval   = number
    queueSize          = number
  })
  default = {
    publishingInterval = 1000
    samplingInterval   = 500
    queueSize          = 1
  }
}
