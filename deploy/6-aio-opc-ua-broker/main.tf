locals {
  custom_locations_id = "${data.azurerm_resource_group.this.id}/providers/Microsoft.ExtendedLocation/customLocations/cl-${var.name}"
}

locals {
  resource_group_id = data.azurerm_resource_group.this.id
  cluster_id        = "${data.azurerm_resource_group.this.id}/providers/Microsoft.Kubernetes/connectedClusters/arc-${var.name}"

  aio_otel_collector_address_no_protocol   = "aio-otel-collector.${var.aio_cluster_namespace}.svc.cluster.local:4317"
  aio_geneva_collector_address_no_protocol = "geneva-metrics-service.${var.aio_cluster_namespace}.svc.cluster.local:4317"

  aio_otel_collector_address   = "http://${local.aio_otel_collector_address_no_protocol}"
  aio_geneva_collector_address = "http://${local.aio_geneva_collector_address_no_protocol}"

  aio_mq_domain    = "${var.aio_mq_frontend_server}.${var.aio_cluster_namespace}"
  aio_mq_local_url = "mqtts://${local.aio_mq_domain}:8883"
}

data "azurerm_resource_group" "this" {
  name = "rg-${var.name}"
}