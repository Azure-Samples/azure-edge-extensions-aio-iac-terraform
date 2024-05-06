locals {
  arc_resource_name    = "arc-${var.name}"
  custom_location_name = "cl-${var.name}-aio"
  cluster_id           = var.arc_cluster_name != null ? "${module.resource_group.resource_group_id}/providers/Microsoft.Kubernetes/connectedClusters/${var.arc_cluster_name}" : "${module.resource_group.resource_group_id}/providers/Microsoft.Kubernetes/connectedClusters/${local.arc_resource_name}"
  custom_locations_id  = var.custom_locations_name != null ? "${module.resource_group.resource_group_id}/providers/Microsoft.ExtendedLocation/customLocations/${var.custom_locations_name}" : "${module.resource_group.resource_group_id}/providers/Microsoft.ExtendedLocation/customLocations/${local.custom_location_name}"
}

module "resource_group" {
  source                       = "../resources/resource-group"
  should_create_resource_group = false

  name     = var.name
  location = var.location
}
