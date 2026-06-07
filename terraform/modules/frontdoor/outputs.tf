output "profile_id" { value = azurerm_cdn_frontdoor_profile.main.id }
output "endpoint_hostname" { value = azurerm_cdn_frontdoor_endpoint.main.host_name }
output "custom_domain_id" { value = var.domain_name == "" ? null : azurerm_cdn_frontdoor_custom_domain.main[0].id }
output "custom_domain_validation_token" { value = var.domain_name == "" ? null : azurerm_cdn_frontdoor_custom_domain.main[0].validation_token }
