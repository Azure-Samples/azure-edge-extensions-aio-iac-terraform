locals {
  resource_group_id   = data.azurerm_resource_group.this.id
  cluster_id          = var.arc_cluster_name != null ? "${local.resource_group_id}/providers/Microsoft.Kubernetes/connectedClusters/${var.arc_cluster_name}" : "${local.resource_group_id}/providers/Microsoft.Kubernetes/connectedClusters/arc-${var.name}"
  custom_locations_id = var.custom_locations_name != null ? "${data.azurerm_resource_group.this.id}/providers/Microsoft.ExtendedLocation/customLocations/${var.custom_locations_name}" : "${data.azurerm_resource_group.this.id}/providers/Microsoft.ExtendedLocation/customLocations/cl-${var.name}-aio"
}
data "azurerm_resource_group" "this" {
  name = var.resource_group_name != null ? var.resource_group_name : "rg-${var.name}"
}
