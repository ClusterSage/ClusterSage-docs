data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

module "resource_group" {
  source   = "./modules/resource-group"
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

module "networking" {
  source                           = "./modules/networking"
  name_prefix                      = local.name_prefix
  resource_group_name              = module.resource_group.name
  location                         = module.resource_group.location
  address_space                    = var.vnet_address_space
  aks_subnet_prefixes              = var.aks_subnet_prefix
  private_endpoint_subnet_prefixes = var.private_endpoint_subnet_prefix
  management_subnet_prefixes       = var.management_subnet_prefix
  tags                             = local.tags
}

module "managed_identity" {
  source              = "./modules/managed-identity"
  name                = "id-${local.name_prefix}-workloads"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "service_bus" {
  source              = "./modules/service-bus"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  queue_name          = "cluster-connected"
  tags                = local.tags
}

module "email" {
  source              = "./modules/email"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  data_location       = var.communication_data_location
  sender_display_name = var.email_sender_display_name
  tags                = local.tags
}

module "storage" {
  source              = "./modules/storage"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  container_name      = "clusterwatch-data"
  tags                = local.tags
}

module "key_vault" {
  source              = "./modules/key-vault"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags
}

module "app_hosting" {
  source                     = "./modules/app-hosting"
  acr_name                   = var.acr_name
  aks_name                   = var.aks_name
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  aks_subnet_id              = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  node_count                 = var.aks_node_count
  vm_size                    = var.aks_vm_size
  tags                       = local.tags
}

module "database" {
  count                  = var.create_database ? 1 : 0
  source                 = "./modules/database"
  name_prefix            = local.name_prefix
  server_name            = var.postgres_server_name
  resource_group_name    = module.resource_group.name
  location               = coalesce(var.database_location, module.resource_group.location)
  administrator_login    = var.postgres_admin_login
  administrator_password = var.postgres_admin_password
  sku_name               = var.postgres_sku_name
  storage_mb             = var.postgres_storage_mb
  tags                   = local.tags
}

module "waf" {
  source              = "./modules/waf"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  sku_name            = var.frontdoor_sku_name
  tags                = local.tags
}

module "frontdoor" {
  source              = "./modules/frontdoor"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  sku_name            = var.frontdoor_sku_name
  origin_host_name    = var.origin_host_name
  origin_host_header  = var.origin_host_header
  domain_name         = var.domain_name
  waf_policy_id       = module.waf.policy_id
  tags                = local.tags
}

resource "azurerm_role_assignment" "servicebus_sender" {
  scope                = module.service_bus.namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_role_assignment" "servicebus_receiver" {
  scope                = module.service_bus.namespace_id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_role_assignment" "communication_email_owner" {
  scope                = module.resource_group.id
  role_definition_name = "Communication and Email Service Owner"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                = module.storage.account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_federated_identity_credential" "clusterwatch_workloads" {
  name                      = "fic-${local.name_prefix}-clusterwatch-workloads"
  user_assigned_identity_id = module.managed_identity.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = module.app_hosting.aks_oidc_issuer_url
  subject                   = "system:serviceaccount:clusterwatch:clusterwatch-workloads"
}

resource "azurerm_role_assignment" "keyvault_current_user" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
