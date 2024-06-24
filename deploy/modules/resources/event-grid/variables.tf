variable "should_create_eventgrid_namespace" {
  description = "Flag to create Event Grid Namespace"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the Event Hub namespace"
  type        = string
}

variable "location" {
  description = "Azure region where the resources will be provisioned"
  type        = string
}

variable "resource_group_id" {
  description = "Id of the resource group where the resources will be created"
  type        = string
}

variable "sku_name" {
  description = "Event Hub SKU"
  type        = string
  default     = "Standard"
}

variable "sku_capacity" {
  description = "Event Hub capacity"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "enable_mqtt_broker" {
  description = "Enable MQTT broker"
  type        = bool
  default     = false
}

variable "alternative_authentication_name_sources" {
  description = "Alternative authentication name sources"
  type        = list(string)
  default     = ["ClientCertificateSubject"]
}

variable "maximum_client_sessions_per_authentication_name" {
  description = "Maximum client sessions per authentication name"
  type        = number
  default     = 5
}

variable "maximum_session_expiry_in_hours" {
  description = "Maximum session expiry in hours"
  type        = number
  default     = 1
}

variable "should_create_event_grid_topics" {
  description = "Flag to create Event Grid topics"
  type        = bool
  default     = false
}

variable "eventgrid_topic_space_name" {
  description = "Name of the Event Grid topic space"
  type        = string
  default     = "event-grid-topic-space"
}

variable "eventgrid_topic_templates" {
  description = "List of Event Grid topic templates"
  type        = list(string)
  default     = []
}

variable "eventgrid_permission_binder_subscriber_name" {
  description = "Name of the Event Grid permission binder for subscriber"
  type        = string
  default     = "eg-permission-binder-subscriber"
}

variable "eventgrid_permission_binder_publisher_name" {
  description = "Name of the Event Grid permission binder for publisher"
  type        = string
  default     = "eg-permission-binder-publisher"
}

variable "eventgrid_permission_binder_subscriber_client_group_name" {
  description = "Name of the Event Grid subscriber permission binder for client group"
  type        = string
  default     = "$all"
}

variable "eventgrid_permission_binder_publisher_client_group_name" {
  description = "Name of the Event Grid publisher permission binder for client group"
  type        = string
  default     = "$all"
}
