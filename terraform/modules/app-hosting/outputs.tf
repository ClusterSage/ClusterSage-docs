output "aks_id" { value = azurerm_kubernetes_cluster.main.id }
output "aks_name" { value = azurerm_kubernetes_cluster.main.name }
output "aks_oidc_issuer_url" { value = azurerm_kubernetes_cluster.main.oidc_issuer_url }
output "acr_id" { value = azurerm_container_registry.main.id }
output "acr_login_server" { value = azurerm_container_registry.main.login_server }
