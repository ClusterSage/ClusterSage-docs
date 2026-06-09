resource "azurerm_container_registry" "main" {
  name                   = var.acr_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku                    = "Standard"
  admin_enabled          = false
  anonymous_pull_enabled = var.acr_anonymous_pull_enabled
  tags                   = var.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                      = var.aks_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  dns_prefix                = var.aks_name
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  sku_tier                  = "Free"
  tags                      = var.tags

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.vm_size
    vnet_subnet_id = var.aks_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings,
    ]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
