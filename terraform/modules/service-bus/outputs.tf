output "namespace_id" { value = azurerm_servicebus_namespace.main.id }
output "namespace_name" { value = azurerm_servicebus_namespace.main.name }
output "fully_qualified_namespace" { value = "${azurerm_servicebus_namespace.main.name}.servicebus.windows.net" }
output "queue_name" { value = azurerm_servicebus_queue.cluster_connected.name }
