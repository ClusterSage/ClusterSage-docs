output "resource_group_name" { value = module.resource_group.name }
output "aks_name" { value = module.app_hosting.aks_name }
output "acr_login_server" { value = module.app_hosting.acr_login_server }
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
output "key_vault_uri" { value = module.key_vault.vault_uri }
output "application_insights_connection_string" {
  value     = module.monitoring.application_insights_connection_string
  sensitive = true
}
output "postgres_fqdn" { value = var.create_database ? module.database[0].fqdn : null }
