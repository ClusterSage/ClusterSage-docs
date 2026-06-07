resource "azurerm_servicebus_namespace" "main" {
  name                = "sb-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_servicebus_queue" "cluster_connected" {
  name                                    = var.queue_name
  namespace_id                            = azurerm_servicebus_namespace.main.id
  lock_duration                           = "PT1M"
  max_delivery_count                      = 10
  requires_duplicate_detection            = true
  duplicate_detection_history_time_window = "PT10M"
}
