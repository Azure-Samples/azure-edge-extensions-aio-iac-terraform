variable "should_deploy_mqtt_client" {
  description = "Flag to deploy the mqtt client"
  type        = bool
  default     = false
}

variable "aio_mq_auth_sat_audience" {
  description = "The AIO MQ broker Service Account Token audience for authentication."
  type        = string
  default     = "aio-mq"
}