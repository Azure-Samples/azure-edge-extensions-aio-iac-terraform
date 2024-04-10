output "aio_mq_principal_id" {
  value = var.enable_aio_mq ? azurerm_arc_kubernetes_cluster_extension.mq[0].identity[0].principal_id : null
}
