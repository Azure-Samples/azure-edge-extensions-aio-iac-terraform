//noinspection HILUnresolvedReference
locals {
  existing_cluster_extension_ids = jsondecode(data.azapi_resource.aio_custom_locations.output).properties.clusterExtensionIds
}

resource "azurerm_arc_kubernetes_cluster_extension" "assets" {
  name           = "assets"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.deviceregistry.assets"

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_extension_release_train
  version       = var.aio_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "Microsoft.CustomLocation.ServiceAccount" = "default"
  }

  provisioner "local-exec" {
    command = <<-EOT
      az customlocation patch -n ${data.azapi_resource.aio_custom_locations.name} -g ${data.azurerm_resource_group.this.name} \
        -c ${join(" ", setunion(local.existing_cluster_extension_ids, [self.id]))}
      SECONDS=0
      while :
      do
        STATE="$(az customlocation show -n cl-awg-aio-smpl-aio -g rg-awg-aio-smpl --query 'provisioningState' -o json)"
        if [[ "$STATE" = '"Succeeded"' ]]; then
          exit 0
        fi
        if [[ $SECONDS -gt 300 ]]; then
          echo "Timed out..."
          exit 1
        fi
        echo "Provisioning State: $STATE"
        sleep 1
      done
    EOT
  }
}

resource "azurerm_arc_kubernetes_cluster_extension" "akri" {
  name           = "akri"
  cluster_id     = local.cluster_id
  extension_type = "microsoft.iotoperations.akri"

  identity {
    type = "SystemAssigned"
  }

  release_train = var.aio_extension_release_train
  version       = var.aio_extension_version

  release_namespace = var.aio_cluster_namespace

  configuration_settings = {
    "webhookConfiguration.enabled" = "false"
  }
}
