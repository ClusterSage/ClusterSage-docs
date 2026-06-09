output "vnet_id" { value = azurerm_virtual_network.main.id }
output "aks_subnet_id" { value = azurerm_subnet.aks.id }
output "private_endpoint_subnet_id" {
  value = length(azurerm_subnet.private_endpoints) > 0 ? azurerm_subnet.private_endpoints[0].id : null
}
output "management_subnet_id" {
  value = length(azurerm_subnet.management) > 0 ? azurerm_subnet.management[0].id : null
}
