variable "should_use_event_grid" {
  description = "(Optional) Use Event Grid for AIO to send data to cloud"
  type        = bool
  default     = false
}

variable "aio_eg_topic_space_name" {
  description = "The name of the Event Grid Topic Space."
  type        = string
  default     = "aio-event-grid-topic-space"
}

variable "aio_eg_topic_templates" {
  description = "Topic Templates for the Event Grid Topic Space."
  type        = list(string)
  default     = ["data/edge", "data/cloud"]
}

variable "aio_eg_permission_binder_subscriber_name" {
  description = "The name of the Event Grid Permission Binder for the Subscriber."
  type        = string
  default     = "aio-eg-permission-binder-subscriber"
}

variable "aio_eg_permission_binder_publisher_name" {
  description = "The name of the Event Grid Permission Binder for the Publisher."
  type        = string
  default     = "aio-eg-permission-binder-publisher"
}

variable "aio_mqtt_bridge_connector_name" {
  description = "The name of the MQTT Bridge Connector."
  type        = string
  default     = "aio-mqtt-bridge-connector"
}

variable "aio_mqtt_bridge_topic_map_name" {
  description = "The name of the MQTT Bridge Topic Map."
  type        = string
  default     = "aio-mqtt-bridge-topic-map"
}

variable "aio_eg_remote_to_local_source_topic" {
  description = "The source topic for remote to local MQTT Bridge."
  type        = string
  default     = "data/cloud"
}

variable "aio_eg_remote_to_local_target_topic" {
  description = "The target topic for remote to local MQTT Bridge."
  type        = string
  default     = "cloud/data"
}

variable "aio_eg_local_to_remote_source_topic" {
  description = "The source topic for local to remote MQTT Bridge."
  type        = string
  default     = "azure-iot-operations/data/opc-sim-connector/thermostat"
}

variable "aio_eg_local_to_remote_target_topic" {
  description = "The target topic for local to remote MQTT Bridge."
  type        = string
  default     = "data/edge"
}