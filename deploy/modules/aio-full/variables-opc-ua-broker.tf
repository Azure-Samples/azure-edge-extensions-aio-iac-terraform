variable "enable_aio_opc_ua_broker" {
  description = "Enables Azure IoT OPC UA Broker. (default: 'true')"
  type        = bool
  default     = true
}

variable "aio_opc_ua_broker_extension_version" {
  description = "The Azure IoT OPC UA Broker version to install into the cluster."
  type        = string
  default     = "0.3.0-preview"
}

variable "aio_opc_ua_broker_extension_release_train" {
  description = "The Azure IoT OPC UA Broker release train to use when installing into the cluster."
  type        = string
  default     = "preview"
}

variable "aio_ca_cm_cert_name" {
  description = "The name of the cert in the trust bundle ConfigMap."
  type        = string
  default     = "ca.crt"
}

variable "should_simulate_plc" {
  description = "Enables the OPC UA Broker PLC simulator. (Note: If deploying OPC PLC Sim from this repo then leave this as 'false' otherwise there will be multiple OPC PLC Simulators)"
  type        = bool
  default     = false
}

variable "aio_mq_frontend_server" {
  description = "The AIO MQ Listener frontend service name. (Currently hardcoded in preview)"
  type        = string
  default     = "aio-mq-dmqtt-frontend"
}