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

variable "aio_opc_ua_trust_ca_upload_list" {
  description = "(Optional) The list of certificates for the AIO OPC UA Broker to trust for mutual trust with OPC UA Servers. (Otherwise, 'null', empty trust list implies either anonymous access or will be added later) [Updates 'aio-opc-ua-broker-trust-list' used by AIO OPC UA Broker]"
  type        = list(string)
  default     = null
}

variable "aio_opc_ua_should_upload_trust_ca_list" {
  description = "(Optional) Should upload the list of certificates from 'aio_opc_ua_trust_ca_upload_list'. (Otherwise 'true', will ignore 'aio_opc_ua_trust_ca_spc_list')"
  type        = bool
  default     = true
}

variable "aio_opc_ua_trust_ca_spc_list" {
  description = "(Optional) The list of certificates for the AIO OPC UA Broker to trust for mutual trust with OPC UA Servers that are already stored in Azure Key Vault. (Otherwise, 'null', setting this value will ignore 'aio_opc_ua_trust_ca_upload_list') [Updates 'aio-opc-ua-broker-trust-list' used by AIO OPC UA Broker]"
  type = list(object({
    name     = string
    filename = string
    encoding = string
  }))
  default = null
  validation {
    condition     = can([for item in coalesce(var.aio_opc_ua_trust_ca_spc_list, []) : contains(["hex", "base64"], item.encoding)])
    error_message = "The 'encoding' field can only be ['hex', 'base64']"
  }
}

variable "aio_opc_ua_issuer_ca_upload_list" {
  description = "(Optional) The list of issuer certificates for the AIO OPC UA Broker. (Otherwise, 'null', empty issuer list implies either anonymous access or will be added later) [Updates 'aio-opc-ua-broker-issuer-list' used by AIO OPC UA Broker]"
  type        = list(string)
  default     = null
}

variable "aio_opc_ua_should_upload_issuer_ca_list" {
  description = "(Optional) Should upload the list of issuer certificates from 'aio_opc_ua_issuer_ca_upload_list'. (Otherwise 'true', will ignore 'aio_opc_ua_issuer_ca_spc_list')"
  type        = bool
  default     = true
}

variable "aio_opc_ua_issuer_ca_spc_list" {
  description = "(Optional) The list of issuer certificates for the AIO OPC UA Broker that are already stored in Azure Key Vault. (Otherwise, 'null', setting this value will ignore 'aio_opc_ua_issuer_ca_upload_list') [Updates 'aio-opc-ua-broker-issuer-list' used by AIO OPC UA Broker]"
  type = list(object({
    name     = string
    filename = string
    encoding = string
  }))
  default = null
  validation {
    condition     = can([for item in coalesce(var.aio_opc_ua_issuer_ca_spc_list, []) : contains(["hex", "base64"], item.encoding)])
    error_message = "The 'encoding' field can only be ['hex', 'base64']"
  }
}

variable "aio_opc_ua_client_ca_upload_list" {
  description = "(Optional) The list of OPC UA Broker client certificates for the AIO OPC UA Broker to use for its own trust. (Otherwise, 'null', empty will have the AIO OPC UA Broker generate and control its own certificates)"
  type        = list(string)
  default     = null
}

variable "aio_opc_ua_should_upload_client_ca_list" {
  description = "(Optional) Should upload the list of OPC UA Broker client certificates from 'aio_opc_ua_broker_client_ca_upload_list'. (Otherwise 'true', will ignore 'aio_opc_ua_client_ca_spc_list')"
  type        = bool
  default     = true
}

variable "aio_opc_ua_client_ca_spc_list" {
  description = "(Optional) The list of OPC UA Broker client certificates for the AIO OPC UA Broker to use for its own trust that are already stored in Azure Key Vault. (Otherwise, 'null', setting this value will ignore 'aio_opc_ua_client_ca_upload_list')"
  type = list(object({
    name     = string
    filename = string
    encoding = string
  }))
  default = null
  validation {
    condition     = can([for item in coalesce(var.aio_opc_ua_client_ca_spc_list, []) : contains(["hex", "base64"], item.encoding)])
    error_message = "The 'encoding' field can only be ['hex', 'base64']"
  }
}

variable "aio_opc_ua_should_use_client_ca_spc" {
  description = "(Optional) Should use the OPC UA Broker client certificates uploaded in the SecretProviderClass. (Otherwise 'false', will generate and use its own)"
  type        = bool
  default     = false
}

variable "aio_opc_ua_client_ca_subject_name" {
  description = "(Optional) The Subject Name (CN) for the OPC UA Broker client certificate that AIO OPC UA Broker will use. (Otherwise 'null', will generate and use its own)"
  type        = string
  default     = null
}

variable "aio_opc_ua_client_ca_application_uri" {
  description = "(Optional) The Application URI for the OPC UA Broker client certificate that AIO OPC UA Broker will use. (Otherwise 'null', will generate and use its own)"
  type        = string
  default     = null
}

variable "aio_opc_ua_client_ca_spc_name" {
  description = "(Optional) The SecretProviderClass name for the OPC UA Broker client certificate that AIO OPC UA Broker will use. (Otherwise 'aio-opc-ua-broker-client-certificate', ignored if not using SPC)"
  type        = string
  default     = "aio-opc-ua-broker-client-certificate"
}
