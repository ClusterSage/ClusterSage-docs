output "communication_service_id" { value = azurerm_communication_service.main.id }
output "communication_service_name" { value = azurerm_communication_service.main.name }
output "communication_service_endpoint" { value = "https://${azurerm_communication_service.main.hostname}" }
output "email_service_id" { value = azurerm_email_communication_service.main.id }
output "sender_address" { value = "${azurerm_email_communication_service_domain_sender_username.noreply.name}@${azurerm_email_communication_service_domain.managed.from_sender_domain}" }
