variable "should_use_event_hub" {
  description = "(Optional) Use Event Hub for AIO to send data to cloud"
  type        = bool
  default     = false
}

variable "aio_eh_kafka_connector_name" {
  description = "The name of the Kafka connector."
  type        = string
  default     = "aio-kafka-connector"
}

variable "aio_eh_names" {
  description = "(Optional) The names of the Event Hubs."
  type        = list(string)
  default     = ["edge_to_cloud", "cloud_to_edge"]
}

variable "aio_eh_kafka_connector_topic_map_name" {
  description = "The name of the Kafka connector topic map."
  type        = string
  default     = "aio-kafka-topic-map"
}

variable "aio_eh_edge_to_cloud_mqtt_topic" {
  description = "The MQTT topic to use for the AIO MQ Broker."
  type        = string
  default     = "azure-iot-operations/data/opc-sim-connector/thermostat"
}

variable "aio_eh_edge_to_cloud_kafka_topic" {
  description = "The MQTT topic to use for the AIO MQ Broker."
  type        = string
  default     = "edge_to_cloud"
}

variable "aio_eh_cloud_to_edge_mqtt_topic" {
  description = "The MQTT topic to use for the AIO MQ Broker."
  type        = string
  default     = "cloud/data"
}

variable "aio_eh_cloud_to_edge_kafka_topic" {
  description = "The MQTT topic to use for the AIO MQ Broker."
  type        = string
  default     = "cloud_to_edge"
}

variable "event_hub_message_retention" {
  description = "Number of days to retain the events for this Event Hub"
  type        = number
  default     = 1
}

variable "event_hub_partition_count" {
  description = "Number of partitions for the Event Hub"
  type        = number
  default     = 1
}
