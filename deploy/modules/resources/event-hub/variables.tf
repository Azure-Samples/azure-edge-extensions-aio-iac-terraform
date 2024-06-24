variable "should_create_event_hub_namespace" {
  description = "Flag to create Event Hub Namespace"
  type        = bool
  default     = false
}

variable "should_create_event_hub" {
  description = "Flag to create Event Hub"
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

variable "resource_group_name" {
  description = "Name of the resource group where the resources will be created"
  type        = string
}

variable "sku" {
  description = "Event Hub SKU"
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "eventhub_names" {
  description = "List of Event Hub names"
  type        = list(string)
  default     = []
}

variable "message_retention" {
  description = "Number of days to retain the events for this Event Hub"
  type        = number
  default     = 1
}

variable "partition_count" {
  description = "Number of partitions for the Event Hub"
  type        = number
  default     = 1
}