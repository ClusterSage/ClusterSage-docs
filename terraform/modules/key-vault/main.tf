resource "azurerm_key_vault" "main" {
  name                       = substr(replace("kv-${var.name_prefix}", "-", ""), 0, 24)
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  rbac_authorization_enabled = true
  tags                       = var.tags
}
