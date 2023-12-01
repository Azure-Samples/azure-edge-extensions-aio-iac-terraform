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
      az provider register -n "${pr}"
      %{endfor~}

      SECONDS=0
      while :
      do
        if [[ $SECONDS -gt 300 ]]; then
          echo "Timed out..."
          exit 1
        fi
        NOT_REGISTERED=$(az provider list --query '
          [?contains(`[${join(", ", local.providers_to_register)}]`, @.namespace)]
          .{namespace: namespace, registrationState: registrationState}
          [?registrationState != `Registered`]
        ' -o json)
        if [[ "$NOT_REGISTERED" == "[]" ]]; then
          echo "All Registered!"
          break
        else
          echo "$NOT_REGISTERED"
          echo "Time elapsed in seconds: $SECONDS"
        fi
        sleep 1
      done
    EOT
  }
}