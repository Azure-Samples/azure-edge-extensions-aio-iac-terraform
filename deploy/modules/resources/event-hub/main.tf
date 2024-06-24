locals {
  eventhub_name = "ehn-${var.name}"

  eventhub_namespace_id     = var.should_create_event_hub_namespace ? azurerm_eventhub_namespace.eventhub_namespace[0].id : data.azurerm_eventhub_namespace.eventhub_namespace[0].id
  default_policy_key        = var.should_create_event_hub_namespace ? azurerm_eventhub_namespace.eventhub_namespace[0].default_primary_key : data.azurerm_eventhub_namespace.eventhub_namespace[0].default_primary_key
  primary_connection_string = var.should_create_event_hub_namespace ? azurerm_eventhub_namespace.eventhub_namespace[0].default_primary_connection_string : data.azurerm_eventhub_namespace.eventhub_namespace[0].default_primary_connection_string
}

resource "azurerm_eventhub_namespace" "eventhub_namespace" {
  count = var.should_create_event_hub_namespace ? 1 : 0

  name                = local.eventhub_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags
}

data "azurerm_eventhub_namespace" "eventhub_namespace" {
  count = var.should_create_event_hub_namespace ? 0 : 1

  name                = local.eventhub_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub" "eventhub" {
  count = var.should_create_event_hub ? length(var.eventhub_names) : 0

  name                = var.eventhub_names[count.index]
  namespace_name      = local.eventhub_name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = var.message_retention
}

