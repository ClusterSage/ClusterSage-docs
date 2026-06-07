output "account_id" { value = azurerm_storage_account.main.id }
output "account_name" { value = azurerm_storage_account.main.name }
output "container_name" { value = azurerm_storage_container.main.name }
output "primary_connection_string" {
  value     = azurerm_storage_account.main.primary_connection_string
  sensitive = true
}
