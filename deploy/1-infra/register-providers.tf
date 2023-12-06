///
// Registers all service providers that are needed for AIO.
///

locals {
  providers_to_register = [
    "Microsoft.ExtendedLocation",
    "Microsoft.Kubernetes",
    "Microsoft.KubernetesConfiguration",
    "Microsoft.IoTOperationsOrchestrator",
    "Microsoft.IoTOperationsMQ",
    "Microsoft.IoTOperationsDataProcessor",
    "Microsoft.DeviceRegistry",
  ]
}

resource "terraform_data" "register_providers" {
  count = var.should_register_azure_providers ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
      az extension add --upgrade --name customlocation -y
      %{for pr in local.providers_to_register~}
      echo "Registering ${pr}..."
      az provider register -n "${pr}" --wait
      %{endfor~}
    EOT
  }
}