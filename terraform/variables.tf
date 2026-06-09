variable "project" {
  type    = string
  default = "clustersage"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "resource_name_prefix" {
  type        = string
  default     = null
  description = "Optional existing Azure resource name prefix. Use only to preserve already-deployed resource names."
}

variable "application_tag" {
  type    = string
  default = "ClusterSage"
}

variable "environment_tag" {
  type    = string
  default = null
}

variable "domain_name" {
  type    = string
  default = "dev.nexaflow.site"
}

variable "origin_host_name" {
  type    = string
  default = ""
}

variable "origin_host_header" {
  type    = string
  default = ""
}

variable "frontdoor_origin_name" {
  type    = string
  default = "clustersage-origin"
}

variable "frontdoor_sku_name" {
  type    = string
  default = "Premium_AzureFrontDoor"
}

variable "communication_data_location" {
  type    = string
  default = "United States"
}

variable "email_sender_display_name" {
  type    = string
  default = "ClusterSage"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.44.0.0/16"]
}

variable "aks_subnet_prefix" {
  type    = list(string)
  default = ["10.44.0.0/24"]
}

variable "private_endpoint_subnet_prefix" {
  type    = list(string)
  default = ["10.44.10.0/24"]
}

variable "management_subnet_prefix" {
  type    = list(string)
  default = []
}

variable "acr_name" {
  type    = string
  default = "acrclustersagedev"
}

variable "acr_anonymous_pull_enabled" {
  type        = bool
  default     = false
  description = "Enable unauthenticated pulls from the ACR. Keep true only for registries intentionally publishing public agent images."
}

variable "aks_name" {
  type    = string
  default = "aks-clustersage-dev"
}

variable "aks_node_count" {
  type    = number
  default = 2
}

variable "aks_vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "postgres_admin_login" {
  type    = string
  default = "clustersageadmin"
}

variable "postgres_server_name" {
  type    = string
  default = null
}

variable "postgres_database_name" {
  type    = string
  default = "clustersage"
}

variable "database_location" {
  type    = string
  default = null
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

variable "postgres_sku_name" {
  type    = string
  default = "B_Standard_B2s"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "create_database" {
  type    = bool
  default = true
}

variable "key_vault_secrets_officer_principal_id" {
  type        = string
  default     = null
  description = "Optional principal ID to receive Key Vault Secrets Officer. Use for existing environments so CI does not replace a human/admin assignment."
}

variable "storage_container_name" {
  type    = string
  default = "clustersage-data"
}

variable "deploy_kubernetes" {
  type        = bool
  default     = true
  description = "Deploy kgateway and the ClusterSage platform Helm chart into AKS."
}

variable "kgateway_namespace" {
  type    = string
  default = "kgateway-system"
}

variable "kgateway_chart_version" {
  type    = string
  default = "v2.3.0"
}

variable "gateway_api_crds_url" {
  type    = string
  default = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml"
}

variable "platform_namespace" {
  type    = string
  default = "clustersage"
}

variable "platform_release_name" {
  type    = string
  default = "clustersage-platform"
}

variable "platform_service_account_name" {
  type    = string
  default = "clustersage-workloads"
}

variable "platform_gateway_name" {
  type    = string
  default = "clustersage-public"
}

variable "platform_gateway_hostname" {
  type    = string
  default = ""
}

variable "frontend_image_repository" {
  type    = string
  default = null
}

variable "frontend_image_tag" {
  type    = string
  default = "0.1.3"
}

variable "backend_image_repository" {
  type    = string
  default = null
}

variable "backend_image_tag" {
  type    = string
  default = "0.1.5"
}

variable "frontend_replica_count" {
  type    = number
  default = 2
}

variable "backend_replica_count" {
  type    = number
  default = 2
}

variable "email_worker_replica_count" {
  type    = number
  default = 1
}
