output "resource_group_name" { value = module.resource_group.name }
output "aks_name" { value = module.app_hosting.aks_name }
output "acr_login_server" { value = module.app_hosting.acr_login_server }
output "vnet_id" { value = module.networking.vnet_id }
output "aks_subnet_id" { value = module.networking.aks_subnet_id }
output "private_endpoint_subnet_id" { value = module.networking.private_endpoint_subnet_id }
output "management_subnet_id" { value = module.networking.management_subnet_id }
output "frontdoor_endpoint_hostname" { value = module.frontdoor.endpoint_hostname }
output "frontdoor_custom_domain_validation_token" { value = module.frontdoor.custom_domain_validation_token }
output "service_bus_namespace" { value = module.service_bus.namespace_name }
output "service_bus_queue_name" { value = module.service_bus.queue_name }
output "storage_account_name" { value = module.storage.account_name }
output "storage_container_name" { value = module.storage.container_name }
output "storage_connection_string" {
  value     = module.storage.primary_connection_string
  sensitive = true
}
output "managed_identity_client_id" { value = module.managed_identity.client_id }
output "communication_email_endpoint" { value = module.email.communication_service_endpoint }
output "communication_email_sender_address" { value = module.email.sender_address }
output "key_vault_uri" { value = module.key_vault.vault_uri }
output "application_insights_connection_string" {
  value     = module.monitoring.application_insights_connection_string
  sensitive = true
}
output "postgres_fqdn" { value = var.create_database ? module.database[0].fqdn : null }
output "kgateway_namespace" { value = var.kgateway_namespace }
output "platform_namespace" { value = var.platform_namespace }
output "platform_gateway_name" { value = var.platform_gateway_name }
