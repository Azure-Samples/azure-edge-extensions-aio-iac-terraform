locals {
  custom_locations_id = "${data.azurerm_resource_group.this.id}/providers/Microsoft.ExtendedLocation/customLocations/cl-${var.name}"
}

locals {
  resource_group_id = data.azurerm_resource_group.this.id
  cluster_id        = "${data.azurerm_resource_group.this.id}/providers/Microsoft.Kubernetes/connectedClusters/arc-${var.name}"
}

data "azurerm_resource_group" "this" {
  name = "rg-${var.name}"
}